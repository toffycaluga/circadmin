# app/controllers/stripe_webhooks_controller.rb
class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    payload    = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    secret     = ENV["STRIPE_WEBHOOK_SECRET"]

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      Rails.logger.warn("[stripe.webhook] invalid: #{e.message}")
      return head :bad_request
    end

    case event.type
    when "invoice.payment_succeeded", "invoice.payment_failed"
      invoice = event.data.object
      sync_subscription(invoice.subscription)
    when "customer.subscription.created", "customer.subscription.updated", "customer.subscription.deleted"
      upsert_subscription(event.data.object)
    else
      Rails.logger.info("[stripe.webhook] unhandled #{event.type}")
    end

    head :ok
  end

  private

  def sync_subscription(sub_id)
    return if sub_id.blank?
    stripe_sub = Stripe::Subscription.retrieve(sub_id)
    upsert_subscription(stripe_sub)
  rescue Stripe::StripeError => e
    Rails.logger.error("[stripe.webhook] retrieve #{sub_id}: #{e.message}")
  end

  def upsert_subscription(stripe_sub)
    return unless stripe_sub.present?
    local = Subscription.find_or_initialize_by(stripe_subscription_id: stripe_sub.id)
    local.assign_attributes(
      status:               stripe_sub.status,
      current_period_start: Time.at(stripe_sub.current_period_start),
      current_period_end:   Time.at(stripe_sub.current_period_end)
    )
    if stripe_sub.items&.data&.first
      local.price_id = stripe_sub.items.data.first.price.id if local.respond_to?(:price_id)
    end
    local.save!
  end
end
