# app/controllers/subscriptions_controller.rb
class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_circus
  before_action :set_current_subscription, only: [ :show, :pause, :resume, :check_availability ]
  layout "dashboard"

  # 1) Vista para elegir plan/servicios (UI)
  def new
    @plans = Plan.active.order(:price_cents) rescue []
  end

  # 2) (Legado) Si tu flujo usa Stripe Checkout en BillingController,
  #    no crees aquí la suscripción para evitar estados inconsistentes.
  def create
    render json: {
      error: "Este endpoint ya no crea suscripciones. Usa el checkout (BillingController) para completar la compra."
    }, status: :unprocessable_entity
  end

  # 3) Estado de la suscripción actual
  def show
    # Si no hay activa, mostramos la última como fallback para no romper la vista
    @subscription ||= @circus.subscriptions.order(current_period_end: :desc).first
  end

  # 4) Pausar suscripción en Stripe
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

  # 5) Reanudar suscripción en Stripe
  def resume
    return redirect_to(circus_subscription_path(@circus), alert: I18n.t("subscriptions.not_found")) unless @subscription

    stripe_sub = Stripe::Subscription.update(
      @subscription.stripe_subscription_id,
      pause_collection: nil
    )
    @subscription.update!(status: stripe_sub.status, active: active_like_status?(stripe_sub.status))

    redirect_to circus_subscription_path(@circus), notice: I18n.t("subscriptions.resume.success")
  rescue Stripe::StripeError => e
    redirect_to circus_subscription_path(@circus), alert: I18n.t("subscriptions.resume.error", error: e.message)
  end

  # 6) Chequear disponibilidad (SIEMPRE JSON).
  #    Devuelve allowed=true cuando:
  #      - Hay suscripción activa
  #      - (si se pasa ?service=) existe un item activo con ese service_key
  #      - (opcional) respeta límites si puedes mapear el plan a partir del price_id
  def check_availability
    # 1) Debe existir una suscripción activa
    # después: chequea el booleano crudo O estado considerado activo
    unless @subscription && (@subscription.read_attribute(:active) || active_like_status?(@subscription.status))

      Rails.logger.info("[check_availability] circus=#{@circus.id} => NO ACTIVE SUBSCRIPTION")
      return render json: {
        allowed: false,
        title:   I18n.t("subscriptions.check_availability.subscription_needed.title", default: "Necesitas una suscripción activa"),
        body:    I18n.t("subscriptions.check_availability.subscription_needed.body",  default: "Activa un plan para continuar."),
        action:  new_circus_subscription_path(@circus)
      }, status: :ok
    end

    # 2) Validar servicio requerido (opcional)
    required_service = params[:service].presence
    if required_service
      has_service = @subscription.subscription_items
                                 .where(active: true, service_key: required_service)
                                 .exists?
      Rails.logger.info("[check_availability] circus=#{@circus.id} sub=#{@subscription.id} service=#{required_service} has_service=#{has_service}")
      unless has_service
        return render json: {
          allowed: false,
          title:   I18n.t("subscriptions.check_availability.service_needed.title",
                          default: "Necesitas el módulo #{required_service}"),
          body:    I18n.t("subscriptions.check_availability.service_needed.body",
                          default: "Tu suscripción actual no incluye el servicio requerido."),
          action:  new_circus_subscription_path(@circus)
        }, status: :ok
      end
    end

    # 3) (Opcional) Límite por plan
    begin
      plan = nil

      # Preferimos resolver por el item 'core' activo
      core_item = @subscription.subscription_items.where(active: true, service_key: "core").first

      # Resolver Plan por price_id
      if defined?(Plan) && Plan.respond_to?(:find_by)
        if core_item&.price_id.present?
          plan = Plan.find_by(stripe_price_id: core_item.price_id)
        end

        # Fallbacks de compatibilidad por si existen esas columnas en tu modelo
        if plan.nil? && @subscription.respond_to?(:price_id) && @subscription.price_id.present?
          plan = Plan.find_by(stripe_price_id: @subscription.price_id)
        end
        if plan.nil? && @subscription.respond_to?(:plan_key) && @subscription.plan_key.present?
          plan = Plan.find_by(key: @subscription.plan_key)
        end
      end

      if plan&.respond_to?(:allowed_circuses) && plan.allowed_circuses.present?
        current_qty = @circus.respond_to?(:some_count_method) ? @circus.some_count_method : 0
        allowed     = current_qty < plan.allowed_circuses.to_i
        Rails.logger.info("[check_availability] circus=#{@circus.id} limit allowed=#{allowed} current=#{current_qty} limit=#{plan.allowed_circuses}")
        unless allowed
          return render json: {
            allowed: false,
            title:   I18n.t("subscriptions.check_availability.limit_reached.title", default: "Has alcanzado el límite de tu plan"),
            body:    I18n.t("subscriptions.check_availability.limit_reached.body",
                            default: "Actualmente tienes %{current} de %{allowed} permitidos.", current: current_qty, allowed: plan.allowed_circuses.to_i),
            action:  new_circus_subscription_path(@circus)
          }, status: :ok
        end
      else
        Rails.logger.info("[check_availability] circus=#{@circus.id} no plan/limit resolved -> allowed=true")
      end
    rescue => e
      Rails.logger.error("[check_availability] limit-check error: #{e.class}: #{e.message}")
      # En caso de error al calcular límites, no bloqueamos al usuario.
    end

    # 4) Todo ok
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

  # Usa circos del usuario para evitar acceso a otros circos
  def set_circus
    @circus = current_user.circuses.find(params[:circus_id] || params[:id])
  end

  # Toma la suscripción ACTIVA más nueva; si no hay activa, intenta auto-sanar
  def set_current_subscription
    # 1) Intento normal: buscar por active: true
    @subscription = @circus.subscriptions
                           .where(active: true)
                           .order(current_period_end: :desc)
                           .first
    Rails.logger.debug("[set_current_subscription] try-active-first => #{@subscription&.id || 'nil'}")
    return if @subscription.present?

    # 2) Auto-fix: si no hay 'active', promueve la última con estado válido
    fallback = @circus.subscriptions
                      .where(status: %w[active trialing])
                      .order(current_period_end: :desc)
                      .first
    Rails.logger.debug("[set_current_subscription] fallback-status => #{fallback&.id || 'nil'}")

    if fallback.present?
      Subscription.where(circus_id: @circus.id, active: true)
                  .where.not(id: fallback.id)
                  .update_all(active: false)
      fallback.update_column(:active, true) # fuerza el flag
      @subscription = fallback
      Rails.logger.warn("[set_current_subscription] Auto-fixed active flag: circus=#{@circus.id} sub=#{fallback.id}")
    end
  end

  # Estados que consideramos "activos"
  def active_like_status?(status)
    %w[active trialing].include?(status.to_s)
  end

  # Estados que consideramos "pausados"
  def pause_like_status?(status)
    %w[paused].include?(status.to_s)
  end

  def subscription_params
    params.permit(:plan_id, :payment_method_id)
  end
end
