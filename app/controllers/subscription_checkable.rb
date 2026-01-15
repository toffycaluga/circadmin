# app/controllers/concerns/subscription_checkable.rb
module SubscriptionCheckable
  extend ActiveSupport::Concern

  private

  def check_subscription
    unless current_user.stripe_subscription_id.present?
      return trigger_modal(
        title:  t("subscriptions.modal.required.title"),
        body:   t("subscriptions.modal.required.body"),
        action: new_subscription_path
      )
    end

    sub     = Stripe::Subscription.retrieve(current_user.stripe_subscription_id)
    allowed = sub.items.data.first.quantity.to_i

    if current_user.circus_count > allowed
      trigger_modal(
        title:  t("subscriptions.modal.limit_reached.title"),
        body:   t("subscriptions.modal.limit_reached.body",
                  current: current_user.circus_count,
                  allowed: allowed),
        action: new_subscription_path
      )
    end

  rescue Stripe::InvalidRequestError
    trigger_modal(
      title:  t("subscriptions.modal.invalid.title"),
      body:   t("subscriptions.modal.invalid.body"),
      action: new_subscription_path
    )
  end

  # Puedes mantener este método aquí o moverlo a ApplicationController
  def trigger_modal(title:, body:, action:)
    respond_to do |format|
      format.html { redirect_to action, alert: body }
      format.json { render json: { modal: true, title: title, body: body, action: action } }
    end
  end
end
