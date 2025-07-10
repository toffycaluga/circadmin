class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  def new
    # muestra formulario con Stripe Elements
  end

  def create
    # crea o recupera Customer
    customer = current_user.stripe_customer_id.present? ?
      Stripe::Customer.retrieve(current_user.stripe_customer_id) :
      Stripe::Customer.create(email: current_user.email)
    current_user.update(stripe_customer_id: customer.id)

    # define si hay trial
    trial_days = current_user.had_trial ? 0 : 30
    subscription = Stripe::Subscription.create(
      customer: customer.id,
      items: [ { plan: "plan_XXXX", quantity: 1 } ],
      trial_period_days: trial_days
    )
    current_user.update(
      stripe_subscription_id: subscription.id,
      had_trial: true
    )

    redirect_to dashboard_path, notice: "¡Suscripción creada!"
  end
    def check_availability
    # Si no hay suscripción
    unless current_user.stripe_subscription_id.present?
        render json: {
        allowed: false,
        title:   "Suscripción necesaria",
        body:    "Debes elegir o actualizar tu plan antes de continuar.",
        action:  new_subscription_path
        }
        return
    end

    # Recupera y comprueba
    sub     = Stripe::Subscription.retrieve(current_user.stripe_subscription_id)
    allowed = sub.items.data.first.quantity.to_i
    current = current_user.circus_count

    if current < allowed
        render json: { allowed: true }
    else
        render json: {
        allowed: false,
        title:   "Límite alcanzado",
        body:    "Ya tienes #{current} de #{allowed} elementos permitidos. Actualiza tu plan.",
        action:  new_subscription_path
        }
    end

    rescue Stripe::InvalidRequestError
    render json: {
        allowed: false,
        title:   "Suscripción inválida",
        body:    "No encontramos tu suscripción. Por favor elige un plan.",
        action:  new_subscription_path
    }
    end
end
