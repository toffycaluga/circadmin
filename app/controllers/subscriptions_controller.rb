# app/controllers/subscriptions_controller.rb
class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_circus
  before_action :set_current_subscription, only: [ :show, :pause, :resume, :check_availability ]
  layout "dashboard"

  def new
    @plans = Plan.active.order(:price_cents) rescue []
  end

  def create
    render json: {
      error: "Este endpoint ya no crea suscripciones. Usa el checkout (BillingController) para completar la compra."
    }, status: :unprocessable_entity
  end

  def show
    @subscription ||= @circus.subscriptions.order(current_period_end: :desc).first
  end

  def pause
    return redirect_to(circus_subscription_path(@circus), alert: I18n.t("subscriptions.not_found")) unless @subscription

    stripe_sub = Stripe::Subscription.update(
      @subscription.stripe_subscription_id,
      pause_collection: { behavior: "void" }
    )
    @subscription.update!(status: stripe_sub.status, active: active_like_status?(stripe_sub.status))

    redirect_to circus_subscription_path(@circus), notice: I18n.t("subscriptions.pause.success")
  rescue Stripe::StripeError => e
    redirect_to circus_subscription_path(@circus), alert: I18n.t("subscriptions.pause.error", error: e.message)
  end

  def resume
    return redirect_to(circus_subscription_path(@circus), alert: I18n.t("subscriptions.not_found")) unless @subscription

    stripe_sub = Stripe::Subscription.update(@subscription.stripe_subscription_id, pause_collection: nil)
    @subscription.update!(status: stripe_sub.status, active: active_like_status?(stripe_sub.status))

    redirect_to circus_subscription_path(@circus), notice: I18n.t("subscriptions.resume.success")
  rescue Stripe::StripeError => e
    redirect_to circus_subscription_path(@circus), alert: I18n.t("subscriptions.resume.error", error: e.message)
  end

  # JSON: ¿puede usar el/los servicio(s) requerido(s)?
  # Soporta keys variadas (service/item/feature/module/capability/required/needs...),
  # arrays o CSV, anidamientos y booleanos estilo ?ticketing=1.
  def check_availability
    Rails.logger.info("[check_availability] circus=#{@circus.id} sub=#{@subscription&.id} status=#{@subscription&.status} active_col=#{@subscription&.read_attribute(:active)}")

    # 1) Suscripción activa (columna booleana o status active-like)
    unless @subscription && (@subscription.read_attribute(:active) || active_like_status?(@subscription.status))
      Rails.logger.info("[check_availability] circus=#{@circus.id} => NO ACTIVE SUBSCRIPTION")
      return render json: {
        allowed: false,
        title:   I18n.t("subscriptions.check_availability.subscription_needed.title", default: "Necesitas una suscripción activa"),
        body:    I18n.t("subscriptions.check_availability.subscription_needed.body",  default: "Activa un plan para continuar."),
        action:  new_circus_subscription_path(@circus)
      }, status: :ok
    end

    # 2) Detectar requerimientos (agresivo)
    required = aggressively_normalize_required_services(params)
    required = canonicalize_items(required)
    Rails.logger.info("[check_availability] required(normalized)=#{required.inspect}")

    # 👉 Default: si no se pidió nada, exigir 'core'
    required = [ "core" ] if required.empty?

    if required.any?
      included = included_items_for(@subscription) # fusiona múltiples fuentes y canoniza
      has_all  = (required - included).empty?
      Rails.logger.info("[check_availability] included=#{included.inspect} has_all=#{has_all}")

      unless has_all
        missing = (required - included)
        return render json: {
          allowed: false,
          title:   I18n.t("subscriptions.check_availability.service_needed.title",
                          default: "Falta(n) módulo(s) requerido(s)"),
          body:    I18n.t("subscriptions.check_availability.service_needed.body",
                          default: "Tu suscripción actual no incluye todos los servicios requeridos."),
          missing: missing,
          action:  new_circus_subscription_path(@circus)
        }, status: :ok
      end
    end

    render json: { allowed: true }, status: :ok
  rescue => e
    Rails.logger.error("[check_availability] #{e.class}: #{e.message}")
    render json: {
      allowed: false,
      title:   "Ups, ocurrió un problema",
      body:    "No pudimos verificar tu suscripción. Intenta nuevamente.",
      action:  new_circus_subscription_path(@circus)
    }, status: :ok
  end

  private

  def set_circus
    @circus = current_user.circuses.find(params[:circus_id] || params[:id])
  end

  # Intenta por active=true; si no, auto-sana promoviendo la última con estado válido
  def set_current_subscription
    @subscription = @circus.subscriptions
                           .where(active: true)
                           .order(current_period_end: :desc)
                           .first
    Rails.logger.debug("[set_current_subscription] try-active-first => #{@subscription&.id || 'nil'}")
    return if @subscription.present?

    fallback = @circus.subscriptions
                      .where(status: %w[active trialing])
                      .order(current_period_end: :desc)
                      .first
    Rails.logger.debug("[set_current_subscription] fallback-status => #{fallback&.id || 'nil'}")

    if fallback.present?
      Subscription.where(circus_id: @circus.id, active: true)
                  .where.not(id: fallback.id)
                  .update_all(active: false)
      fallback.update_column(:active, true)
      @subscription = fallback
      Rails.logger.warn("[set_current_subscription] Auto-fixed active flag: circus=#{@circus.id} sub=#{fallback.id}")
    end
  end

  def active_like_status?(status)
    %w[active trialing].include?(status.to_s)
  end

  def pause_like_status?(status)
    %w[paused].include?(status.to_s)
  end

  def subscription_params
    params.permit(:plan_id, :payment_method_id)
  end

  # === Helpers de check_availability ===

  # Recorrido profundo de params para extraer requerimientos, admitiendo:
  # - Keys que "suenen" a feature/servicio: /(feature|item|service|module|capability|require|need)/i
  # - Values string/array (CSV o lista) o booleanos (?ticketing=1 -> agrega "ticketing")
  # - Ignora keys estándar (controller, action, format, id, circus_id)
  def aggressively_normalize_required_services(params)
    allowed_key_regex = /(feature|item|service|module|capability|require|need)/i
    ignore_keys = %w[controller action format id circus_id subscription subscriptions]
    acc = []

    walker = lambda do |obj, key_path = []|
      case obj
      when ActionController::Parameters, Hash
        obj.each do |k, v|
          k_str = k.to_s
          next if ignore_keys.include?(k_str)

          if allowed_key_regex.match?(k_str)
            if v == true || v == "1" || v == 1
              acc << k_str
            end
            walker.call(v, key_path + [ k_str ])
          else
            if v == true || v == "1" || v == 1
              acc << k_str
            end
            walker.call(v, key_path + [ k_str ])
          end
        end
      when Array
        obj.each { |e| walker.call(e, key_path) }
      else
        parent_key = key_path.last.to_s
        if allowed_key_regex.match?(parent_key)
          if obj.is_a?(String)
            obj.split(",").each { |piece| acc << piece }
          else
            acc << obj
          end
        end
      end
    end

    walker.call(params.to_unsafe_h)

    acc.flatten!
    acc = acc.map { |s| s.to_s.strip.downcase }.reject(&:blank?).uniq
    acc
  end

  # Canoniza nombres: tickets/ticket/ticketing => ticketing, report/reports/reporting => reporting, etc.
  def canonicalize_items(items)
    items.map { |it| canonicalize_item(it) }.uniq
  end

  def canonicalize_item(item)
    s = item.to_s.strip.downcase
    return "core"        if %w[core base basics].include?(s)
    return "ticketing"   if %w[ticket tickets ticketing entradas boleteria].include?(s)
    return "concessions" if %w[concession concessions candy dulceria].include?(s)
    return "reporting"   if %w[report reports reporting analytics informes].include?(s)
    s
  end

  # ¿La suscripción incluye TODOS los items requeridos?
  def subscription_includes_all_items?(subscription, required_items)
    included = included_items_for(subscription)
    (required_items - included).empty?
  end

  # Items faltantes para la suscripción dada
  def missing_items(subscription, required_items)
    included = included_items_for(subscription)
    (required_items - included)
  end

  # Obtiene los items incluidos por la suscripción actual desde múltiples fuentes y canoniza:
  # - subscription.subscription_items.active.service_key
  # - subscription.plan.items / plan.features
  # - subscription.items / subscription.features (si existen)
  def included_items_for(subscription)
    included = []

    if subscription.respond_to?(:subscription_items)
      included += subscription.subscription_items
                              .where(active: true)
                              .pluck(:service_key)
    end

    if subscription.respond_to?(:plan) && subscription.plan
      if subscription.plan.respond_to?(:items)
        included += Array(subscription.plan.items)
      end
      if subscription.plan.respond_to?(:features)
        included += Array(subscription.plan.features)
      end
    end

    if subscription.respond_to?(:items)
      included += Array(subscription.items)
    end

    if subscription.respond_to?(:features)
      included += Array(subscription.features)
    end

    included = included.map { |s| s.to_s.downcase }.reject(&:blank?)
    canonicalize_items(included)
  end
end
