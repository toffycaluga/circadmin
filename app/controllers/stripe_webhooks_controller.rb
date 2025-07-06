class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    event = Stripe::Webhook.construct_event(payload, sig_header, ENV["STRIPE_WEBHOOK_SECRET"])

    case event.type
    when "invoice.payment_succeeded"
      handle_payment_succeeded(event.data.object)
    when "invoice.payment_failed"
      handle_payment_failed(event.data.object)
    end

    head :ok
  end

  private

  def handle_payment_succeeded(invoice)
    user = User.find_by(stripe_customer_id: invoice.customer)
    user.update(had_trial: true)
    # marca la suscripción como activa…
  end

  def handle_payment_failed(invoice)
    # notifica morosidad…
  end
end
