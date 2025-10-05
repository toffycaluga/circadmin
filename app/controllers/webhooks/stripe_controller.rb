# app/controllers/webhooks/stripe_controller.rb
class Webhooks::StripeController < ApplicationController
  # Evita que filtros globales bloqueen el webhook
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :redirect_if_profile_incomplete, raise: false
  # si tienes otros before_action globales (set_locale, etc.), sáltalos aquí también

  def receive
    payload = request.body.read
    sig     = request.env["HTTP_STRIPE_SIGNATURE"]
    secret  = ENV["STRIPE_WEBHOOK_SECRET"]

    event =
      if secret.present?
        Stripe::Webhook.construct_event(payload, sig, secret) # => Stripe::Event
      else
        JSON.parse(payload, symbolize_names: true)             # DevOnly: si aún no configuras secret
      end

    type = event.is_a?(Stripe::Event) ? event.type        : event[:type]
    obj  = event.is_a?(Stripe::Event) ? event.data.object : event[:data][:object]

    case type
    when "checkout.session.completed"
      on_checkout_session_completed(obj)
    when "customer.subscription.created",
         "customer.subscription.updated",
         "customer.subscription.deleted"
      on_subscription_changed(obj)
    when "invoice.payment_succeeded"
      on_invoice_payment_succeeded(obj)
    when "invoice.payment_failed"
      on_invoice_payment_failed(obj)
    else
      Rails.logger.info("[Stripe] Ignored #{type}")
    end

    render json: { ok: true }
  rescue JSON::ParserError, Stripe::SignatureVerificationError => e
    Rails.logger.error("[Stripe Webhook] #{e.class}: #{e.message}")
    render json: { error: e.message }, status: :bad_request
  end

  private

  # -----------------------
  # Event handlers
  # -----------------------

  def on_checkout_session_completed(session)
    circus = circus_from_session(session)
    return unless circus

    # Guarda customer en Circus
    if session.customer.present? && circus.stripe_customer_id != session.customer
      circus.update!(stripe_customer_id: session.customer)
    end

    # Crea/actualiza la Subscription del circo
    if session.subscription.present?
      subscription = Stripe::Subscription.retrieve(session.subscription)
      upsert_subscription!(circus, subscription)
    end

    Rails.logger.info("[Stripe] checkout.session.completed circus=#{circus.id}")
  end

  def on_subscription_changed(subscription)
    circus = Circus.find_by(stripe_customer_id: subscription.customer)
    return unless circus

    upsert_subscription!(circus, subscription)
    Rails.logger.info("[Stripe] subscription.changed circus=#{circus.id} status=#{subscription.status}")
  end

  def on_invoice_payment_succeeded(invoice)
    circus = Circus.find_by(stripe_customer_id: invoice.customer)
    return unless circus

    if (sub_id = invoice.subscription).present?
      subscription = Stripe::Subscription.retrieve(sub_id)
      upsert_subscription!(circus, subscription)
    end

    Rails.logger.info("[Stripe] invoice.payment_succeeded circus=#{circus.id}")
  end

  def on_invoice_payment_failed(invoice)
    circus = Circus.find_by(stripe_customer_id: invoice.customer)
    return unless circus

    if (sub = circus.subscriptions.order(id: :desc).first)
      sub.update!(status: "past_due")
    end

    Rails.logger.warn("[Stripe] invoice.payment_failed circus=#{circus.id} -> past_due")
  end

  # -----------------------
  # Helpers
  # -----------------------

  def circus_from_session(session)
    circus_id = (session.respond_to?(:metadata) ? session.metadata&.[]("circus_id") : session[:metadata]&.[](:circus_id)) ||
                parse_circus_from_client_ref(session.respond_to?(:client_reference_id) ? session.client_reference_id : session[:client_reference_id])

    return unless circus_id
    Circus.find_by(id: circus_id.to_i)
  end

  # client_reference_id = "#{current_user.id}:#{@circus.id}"
  def parse_circus_from_client_ref(client_ref)
    return nil if client_ref.blank?
    parts = client_ref.to_s.split(":")
    parts[1] # lo casteamos a entero al usarlo
  end

  def upsert_subscription!(circus, subscription)
    first_item = subscription.items&.data&.first
    price_id   = first_item&.price&.id

    attrs = {
      circus_id:             circus.id,
      stripe_subscription_id: subscription.id,
      status:                subscription.status, # "trialing", "active", etc.
      current_period_start:  Time.at(subscription.current_period_start),
      current_period_end:    Time.at(subscription.current_period_end),
      price_id:              price_id,
      updated_at:            Time.current,
      created_at:            Time.current
    }

    # Requiere que tengas el índice único en stripe_subscription_id
    # (lo tienes: "index_subscriptions_on_stripe_subscription_id")
    Subscription.upsert(
      attrs,
      unique_by: :index_subscriptions_on_stripe_subscription_id
    )
  end
end
