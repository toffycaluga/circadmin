class Webhooks::StripeController < ApplicationController
  # Evita bloqueos por CSRF o autenticación
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :redirect_if_profile_incomplete, raise: false

  def receive
    payload = request.body.read
    sig     = request.env["HTTP_STRIPE_SIGNATURE"]
    secret  = ENV["STRIPE_WEBHOOK_SECRET"]

    event =
      if secret.present?
        Stripe::Webhook.construct_event(payload, sig, secret)
      else
        JSON.parse(payload, symbolize_names: true) # Dev-only si aún no configuras secret
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
    when "invoice.payment_succeeded", "invoice.paid"
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
  def on_checkout_session_completed(session)
    circus = circus_from_session(session)
    return unless circus

    customer_id    = session.respond_to?(:customer)     ? session.customer     : session[:customer]
    subscription_id = session.respond_to?(:subscription) ? session.subscription : session[:subscription]

    if customer_id.present? && circus.stripe_customer_id != customer_id
      circus.update!(stripe_customer_id: customer_id)
    end

    if subscription_id.present?
      subscription = Stripe::Subscription.retrieve(subscription_id)
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
    customer_id     = invoice.respond_to?(:customer)     ? invoice.customer     : invoice[:customer]
    subscription_id = invoice.respond_to?(:subscription) ? invoice.subscription : invoice[:subscription]

    circus = Circus.find_by(stripe_customer_id: customer_id)
    return unless circus

    if subscription_id.present?
      subscription = Stripe::Subscription.retrieve(subscription_id)
      upsert_subscription!(circus, subscription)
    end

      Rails.logger.info("[Stripe] invoice.payment_succeeded circus=#{circus.id}")
  end


  def on_invoice_payment_failed(invoice)
    customer_id = invoice.respond_to?(:customer) ? invoice.customer : invoice[:customer]
    circus = Circus.find_by(stripe_customer_id: customer_id)
    return unless circus

    latest_invoice_id     = invoice.respond_to?(:id)     ? invoice.id     : invoice[:id]
    latest_invoice_status = invoice.respond_to?(:status) ? invoice.status : invoice[:status]

    if (sub = circus.subscriptions.order(id: :desc).first)
      sub.update!(
        status:               "past_due",
        active:               false,
        latest_invoice_id:    latest_invoice_id,
        latest_invoice_status: latest_invoice_status
      )
    end

    Rails.logger.warn("[Stripe] invoice.payment_failed circus=#{circus.id} -> past_due")
  end

  # Helpers

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
    parts[1]
  end

  def upsert_subscription!(circus, subscription)
    first_item = subscription.items&.data&.first
    price_id   = first_item&.price&.id

    attrs = {
      circus_id:              circus.id,
      stripe_subscription_id: subscription.id,
      status:                 subscription.status,
      current_period_start:   Time.at(subscription.current_period_start),
      current_period_end:     Time.at(subscription.current_period_end),
      price_id:               price_id,
      latest_invoice_id:      subscription.latest_invoice&.id,
      latest_invoice_status:  subscription.latest_invoice&.status,
      paid_through_at:        Time.at(subscription.current_period_end),
      active:                 %w[active trialing].include?(subscription.status),
      updated_at:             Time.current,
      created_at:             Time.current
    }

    Subscription.upsert(
      attrs,
      unique_by: :index_subscriptions_on_stripe_subscription_id
    )

    # Items
    seen_ids = []
    subscription.items&.data&.each do |it|
      price = it.price
      service_key = (price.metadata && price.metadata["service_key"]).presence || map_product_to_service(price.product)

      item = SubscriptionItem.find_or_initialize_by(stripe_subscription_item_id: it.id)
      item.update!(
        subscription_id:   Subscription.find_by(stripe_subscription_id: subscription.id)&.id,
        stripe_product_id: (price.product.is_a?(String) ? price.product : price.product&.id),
        price_id:          price.id,
        service_key:       service_key,
        quantity:          it.quantity || 1,
        active:            true,
        unit_amount:       price.unit_amount,
        currency:          price.currency,
        interval:          price.recurring&.interval,
        interval_count:    price.recurring&.interval_count
      )
      seen_ids << item.id
    end
    Subscription.find_by(stripe_subscription_id: subscription.id)
                &.subscription_items
                &.where.not(id: seen_ids)
                &.update_all(active: false)
  end

  def map_product_to_service(product_id_or_obj)
    product_id = product_id_or_obj.is_a?(String) ? product_id_or_obj : product_id_or_obj&.id
    {}[product_id] || "core"
  end
end
