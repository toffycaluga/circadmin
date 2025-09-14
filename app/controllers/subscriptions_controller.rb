# app/controllers/subscriptions_controller.rb
class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_circus
  before_action :set_current_subscription, only: [ :show, :pause, :resume, :check_availability ]
  layout "dashboard"

  # 1) Formulario de selección de plan
  def new
    @plans = Plan.active.order(:price_cents)
  end

  # 2) Crear/actualizar suscripción en Stripe y en nuestra BD (SCA/3DS ready)
  def create
    Subscription.transaction do
      plan = Plan.active.find(subscription_params[:plan_id])

      # 2.1 Customer (crear/recuperar) + metadata útil
      customer =
        if @circus.stripe_customer_id.present?
          Stripe::Customer.retrieve(@circus.stripe_customer_id)
        else
          c = Stripe::Customer.create(
            email: current_user.email,
            metadata: { circus_id: @circus.id, user_id: current_user.id }
          )
          @circus.update!(stripe_customer_id: c.id)
          c
        end

      # 2.2 Método de pago por defecto
      Stripe::PaymentMethod.attach(subscription_params[:payment_method_id], { customer: customer.id })
      Stripe::Customer.update(
        customer.id,
        invoice_settings: { default_payment_method: subscription_params[:payment_method_id] }
      )

      # 2.3 Trial solo 1ª vez
      trial_days = @circus.had_trial ? 0 : plan.trial_days.to_i

      # 2.4 Crear suscripción en Stripe
      #     - con trial => allow_incomplete (no cobra de inmediato)
      #     - sin trial => default_incomplete (requiere confirmar PaymentIntent)
      payment_behavior = trial_days.positive? ? "allow_incomplete" : "default_incomplete"

      stripe_sub = Stripe::Subscription.create(
        {
          customer: customer.id,
          items:    [ { price: plan.stripe_price_id, quantity: 1 } ],
          trial_period_days: trial_days,
          payment_behavior:  payment_behavior,
          expand: [ "latest_invoice.payment_intent" ],
          metadata: { circus_id: @circus.id, plan_key: plan.key }
        },
        { idempotency_key: "sub-create:circus=#{@circus.id}:plan=#{plan.id}" }
      )

      # 2.5 Persistir/actualizar en BD
      sub = @circus.subscriptions.find_or_initialize_by(stripe_subscription_id: stripe_sub.id)
      sub.update!(
        plan_key:             plan.key,
        status:               stripe_sub.status,
        current_period_start: Time.at(stripe_sub.current_period_start),
        current_period_end:   Time.at(stripe_sub.current_period_end),
        price_id:             plan.stripe_price_id
      )

      # 2.6 Marcar trial como usado
      @circus.update!(had_trial: true) if trial_days.positive?

      # 2.7 Si NO hay trial, confirmar SCA/3DS en el front con client_secret
      if trial_days.zero?
        pi = stripe_sub.latest_invoice&.payment_intent
        if pi
          case pi.status
          when "requires_confirmation", "requires_action"
            return render json: {
              success:       true,
              client_secret: pi.client_secret,
              redirect_url:  circus_subscription_path(@circus)
            }, status: :ok
          when "requires_payment_method"
            msg = pi.last_payment_error&.message || I18n.t("subscriptions.create.error", error: "Método de pago rechazado")
            return render json: { error: msg }, status: :unprocessable_entity
          end
        end
      end

      # Trial o ya quedó pagada: redirigimos
      render json: { success: true, redirect_url: circus_subscription_path(@circus) }, status: :ok
    end
  rescue Stripe::StripeError => e
    render json: { error: I18n.t("subscriptions.create.error", error: e.message) }, status: :unprocessable_entity
  end

  # 3) Estado
  def show
    @subscription ||= @circus.subscriptions.order(:current_period_end).last
  end

  # 4) Pausar suscripción
  def pause
    return redirect_to(circus_subscription_path(@circus), alert: I18n.t("subscriptions.not_found")) unless @subscription

    stripe_sub = Stripe::Subscription.update(
      @subscription.stripe_subscription_id,
      pause_collection: { behavior: "void" }
    )
    @subscription.update!(status: stripe_sub.status)

    redirect_to circus_subscription_path(@circus), notice: I18n.t("subscriptions.pause.success")
  rescue Stripe::StripeError => e
    redirect_to circus_subscription_path(@circus), alert: I18n.t("subscriptions.pause.error", error: e.message)
  end

  # 5) Reanudar suscripción
  def resume
    return redirect_to(circus_subscription_path(@circus), alert: I18n.t("subscriptions.not_found")) unless @subscription

    stripe_sub = Stripe::Subscription.update(
      @subscription.stripe_subscription_id,
      pause_collection: nil # quita la pausa (más seguro que "")
    )
    @subscription.update!(status: stripe_sub.status)

    redirect_to circus_subscription_path(@circus), notice: I18n.t("subscriptions.resume.success")
  rescue Stripe::StripeError => e
    redirect_to circus_subscription_path(@circus), alert: I18n.t("subscriptions.resume.error", error: e.message)
  end

  # 6) Chequear límites (SIEMPRE devuelve JSON)
  def check_availability
    unless @subscription&.stripe_subscription_id.present?
      return render json: {
        allowed: false,
        title:   I18n.t("subscriptions.check_availability.subscription_needed.title"),
        body:    I18n.t("subscriptions.check_availability.subscription_needed.body"),
        action:  new_circus_subscription_path(@circus)
      }, status: :ok
    end

    # Límite desde tu Plan local (no dependas de quantity en Stripe)
    plan = Plan.find_by(key: @subscription.plan_key)
    allowed_qty = plan&.allowed_circuses.to_i

    # Métrica local a controlar (reemplaza 'some_count_method' por lo real)
    current_qty = @circus.respond_to?(:some_count_method) ? @circus.some_count_method : 0

    if current_qty < allowed_qty
      render json: { allowed: true }, status: :ok
    else
      render json: {
        allowed: false,
        title:   I18n.t("subscriptions.check_availability.limit_reached.title"),
        body:    I18n.t("subscriptions.check_availability.limit_reached.body",
                        current: current_qty, allowed: allowed_qty),
        action:  new_circus_subscription_path(@circus)
      }, status: :ok
    end
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
    @circus = Circus.find(params[:circus_id])
  end

  def set_current_subscription
    @subscription = @circus.subscriptions.order(:current_period_end).last
  end

  def subscription_params
    params.permit(:plan_id, :payment_method_id)
  end
end
