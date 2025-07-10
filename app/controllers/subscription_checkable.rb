# app/controllers/concerns/subscription_checkable.rb
module SubscriptionCheckable
  extend ActiveSupport::Concern

  private

  def check_subscription
    unless current_user.stripe_subscription_id.present?
      return trigger_modal(
        title:  "Suscripción necesaria",
        body:   "Debes elegir o actualizar tu plan para acceder a esta sección.",
        action: new_subscription_path
      )
    end

    sub     = Stripe::Subscription.retrieve(current_user.stripe_subscription_id)
    allowed = sub.items.data.first.quantity.to_i

    if current_user.circus_count > allowed
      trigger_modal(
        title:  "Límite alcanzado",
        body:   "Tienes #{current_user.circus_count}/#{allowed}. Actualiza tu plan.",
        action: new_subscription_path
      )
    end

  rescue Stripe::InvalidRequestError
    trigger_modal(
      title:  "Suscripción inválida",
      body:   "No encontramos tu suscripción. Por favor elige un plan.",
      action: new_subscription_path
    )
  end

  # Si aún no lo tienes en ApplicationController, puedes moverlo aquí:
  def trigger_modal(title:, body:, action:)
    respond_to do |format|
      format.html { redirect_to action, alert: body }
      format.json { render json: { modal: true, title: title, body: body, action: action } }
    end
  end
end
