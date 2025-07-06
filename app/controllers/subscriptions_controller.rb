class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

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
end
