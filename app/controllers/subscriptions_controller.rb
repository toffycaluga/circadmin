# app/controllers/subscriptions_controller.rb
class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_circus
  before_action :set_current_subscription, only: [
    :show, :pause, :resume, :cancel, :cancel_at_period_end, :uncancel, :sync, :check_availability
  ]
  layout "dashboard"

  # ====== Alta / selección de plan ======
  def new
    @plans = Plan.active.order(:price_cents) rescue []
  end

  # (Deprecated) API legacy
  def create
    render json: { error: t("subscriptions.api.create_deprecated") },
           status: :unprocessable_entity
  end

  # ====== Vista de estado ======
 # app/controllers/subscriptions_controller.rb
  def show
    @subscription ||= @circus.subscriptions.order(current_period_end: :desc).first
    @stripe_sub = nil

    if @subscription&.stripe_subscription_id.present?
      @stripe_sub = Stripe::Subscription.retrieve(@subscription.stripe_subscription_id)
    end
  rescue Stripe::StripeError => e
    Rails.logger.warn("[subscriptions#show] stripe_error=#{e.message}")
    @stripe_error = e.message
  end


  # ====== Acciones Stripe: pausa / reanuda / cancelaciones ======
  def pause
    return redirect_to(circus_subscription_path(@circus), alert: t("flash.subscriptions.not_found")) unless @subscription

    stripe_sub = Stripe::Subscription.update(
      @subscription.stripe_subscription_id,
      pause_collection: { behavior: "void" } # otras opciones: 'mark_uncollectible', 'keep_as_draft'
    )
    apply_status_from_stripe!(stripe_sub)

    redirect_to circus_subscription_path(@circus), notice: t("flash.subscriptions.pause.success")
  rescue Stripe::StripeError => e
    redirect_to circus_subscription_path(@circus), alert: t("flash.subscriptions.pause.error", error: e.message)
  end

  def resume
    return redirect_to(circus_subscription_path(@circus), alert: t("flash.subscriptions.not_found")) unless @subscription

    stripe_sub = Stripe::Subscription.update(
      @subscription.stripe_subscription_id,
      pause_collection: nil
    )
    apply_status_from_stripe!(stripe_sub)

    redirect_to circus_subscription_path(@circus), notice: t("flash.subscriptions.resume.success")
  rescue Stripe::StripeError => e
    redirect_to circus_subscription_path(@circus), alert: t("flash.subscriptions.resume.error", error: e.message)
  end

  # Cancelación inmediata
  def cancel
    return redirect_to(circus_subscription_path(@circus), alert: t("flash.subscriptions.not_found")) unless @subscription

    stripe_sub = Stripe::Subscription.cancel(@subscription.stripe_subscription_id)
    apply_status_from_stripe!(stripe_sub, force_inactive: true)

    redirect_to circus_subscription_path(@circus), notice: t("flash.subscriptions.cancel_now.success")
  rescue Stripe::StripeError => e
    redirect_to circus_subscription_path(@circus), alert: t("flash.subscriptions.cancel_now.error", error: e.message)
  end

  # Programar cancelación al final del período
  def cancel_at_period_end
    return redirect_to(circus_subscription_path(@circus), alert: t("flash.subscriptions.not_found")) unless @subscription

    stripe_sub = Stripe::Subscription.update(
      @subscription.stripe_subscription_id,
      cancel_at_period_end: true
    )
    apply_status_from_stripe!(stripe_sub) # queda active hasta el fin del período

    redirect_to circus_subscription_path(@circus), notice: t("flash.subscriptions.cancel_at_period_end.success")
  rescue Stripe::StripeError => e
    redirect_to circus_subscription_path(@circus), alert: t("flash.subscriptions.cancel_at_period_end.error", error: e.message)
  end

  # Revertir cancelación diferida
  def uncancel
    return redirect_to(circus_subscription_path(@circus), alert: t("flash.subscriptions.not_found")) unless @subscription

    stripe_sub = Stripe::Subscription.update(
      @subscription.stripe_subscription_id,
      cancel_at_period_end: false
    )
    apply_status_from_stripe!(stripe_sub)

    redirect_to circus_subscription_path(@circus), notice: t("flash.subscriptions.uncancel.success")
  rescue Stripe::StripeError => e
    redirect_to circus_subscription_path(@circus), alert: t("flash.subscriptions.uncancel.error", error: e.message)
  end

  # Sincroniza estado y bandera active con Stripe (por si hubo cambios en Dashboard)
  def sync
    return redirect_to(circus_subscription_path(@circus), alert: t("flash.subscriptions.not_found")) unless @subscription

    stripe_sub = Stripe::Subscription.retrieve(@subscription.stripe_subscription_id)
    apply_status_from_stripe!(stripe_sub)

    redirect_to circus_subscription_path(@circus), notice: t("flash.subscriptions.sync.success")
  rescue Stripe::StripeError => e
    redirect_to circus_subscription_path(@circus), alert: t("flash.subscriptions.sync.error", error: e.message)
  end

  # ====== JSON: ¿puede usar el/los servicio(s) requerido(s)? ======
  def check_availability
    Rails.logger.info("[check_availability] circus=#{@circus.id} sub=#{@subscription&.id} status=#{@subscription&.status} active_col=#{@subscription&.read_attribute(:active)}")

    # 1) Suscripción activa (col boolean o status active-like)
    unless @subscription && (@subscription.read_attribute(:active) || active_like_status?(@subscription.status))
      Rails.logger.info("[check_availability] circus=#{@circus.id} => NO ACTIVE SUBSCRIPTION")
      return render json: {
        allowed: false,
        title:  t("subscriptions.check_availability.subscription_needed.title"),
        body:   t("subscriptions.check_availability.subscription_needed.body"),
        action: new_circus_subscription_path(@circus)
      }, status: :ok
    end

    # 2) Detectar requerimientos (agresivo)
    required = aggressively_normalize_required_services(params)
    required = canonicalize_items(required)
    Rails.logger.info("[check_availability] required(normalized)=#{required.inspect}")

    # 👉 Default: si no se pidió nada, exigir 'core'
    required = [ "core" ] if required.empty?

    if required.any?
      included = included_items_for(@subscription)
      has_all  = (required - included).empty?
      Rails.logger.info("[check_availability] included=#{included.inspect} has_all=#{has_all}")

      unless has_all
        missing = (required - included)
        return render json: {
          allowed: false,
          title:   t("subscriptions.check_availability.service_needed.title"),
          body:    t("subscriptions.check_availability.service_needed.body"),
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
      title:  t("subscriptions.check_availability.error.title"),
      body:   t("subscriptions.check_availability.error.body"),
      action: new_circus_subscription_path(@circus)
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

  # === Normalizadores de estado ===
  def apply_status_from_stripe!(stripe_sub, force_inactive: false)
    status = stripe_sub.status.to_s
    active_flag = force_inactive ? false : active_like_status?(status)
    # Solo tocamos columnas existentes y seguras
    @subscription.update!(
      status: status,
      active: active_flag
    )
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

  # === Helpers de check_availability (tus versiones) ===
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
            acc << k_str if v == true || v == "1" || v == 1
            walker.call(v, key_path + [ k_str ])
          else
            acc << k_str if v == true || v == "1" || v == 1
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

  def subscription_includes_all_items?(subscription, required_items)
    included = included_items_for(subscription)
    (required_items - included).empty?
  end

  def missing_items(subscription, required_items)
    included = included_items_for(subscription)
    (required_items - included)
  end

  def included_items_for(subscription)
    included = []

    if subscription.respond_to?(:subscription_items)
      included += subscription.subscription_items.where(active: true).pluck(:service_key)
    end

    if subscription.respond_to?(:plan) && subscription.plan
      included += Array(subscription.plan.items)    if subscription.plan.respond_to?(:items)
      included += Array(subscription.plan.features) if subscription.plan.respond_to?(:features)
    end

    included += Array(subscription.items)    if subscription.respond_to?(:items)
    included += Array(subscription.features) if subscription.respond_to?(:features)

    included = included.map { |s| s.to_s.downcase }.reject(&:blank?)
    canonicalize_items(included)
  end
end
