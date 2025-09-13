class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = Stripe::Webhook.construct_event(payload, sig_header, ENV['STRIPE_WEBHOOK_SECRET'])

    case event.type
    when 'invoice.paid', 'customer.subscription.updated'
      sub = event.data.object
      record = Subscription.find_by(stripe_subscription_id: sub.id)
      record.update!(
        status:               sub.status,
        current_period_start: Time.at(sub.current_period_start),
        current_period_end:   Time.at(sub.current_period_end)
      )
    when 'invoice.payment_failed', 'customer.subscription.deleted'
      sub = event.data.object
      record = Subscription.find_by(stripe_subscription_id: sub.id)
      record.update!(status: sub.status)
    end

    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError
    head :bad_request
  end
end
