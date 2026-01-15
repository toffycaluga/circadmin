# app/controllers/billing_controller.rb
class BillingController < ApplicationController
  before_action :authenticate_user!
  before_action :load_circus!
  before_action :prevent_duplicate_checkout, only: [ :start_checkout, :create_checkout_session ]
  layout "dashboard"

  # ------------------------------------------------------------
  # CHECKOUT (1) — Multi-ítems: varios servicios/add-ons a la vez
  # POST /billing/start_checkout?circus_id=:id&service_keys[]=core&service_keys[]=ticketing
  # ------------------------------------------------------------
  def start_checkout
    customer_id = ensure_customer!(@circus)

    service_keys = Array(params[:service_keys]).presence
    unless service_keys
      return redirect_to fallback_path, alert: t("controllers.billing.start_checkout.select_service")
    end

    line_items = service_keys.map do |key|
      { price: price_for(key), quantity: 1 }
    rescue KeyError
      return redirect_to fallback_path, alert: t("controllers.billing.start_checkout.service_without_price", service: key)
    end

    session = Stripe::Checkout::Session.create(
      mode: "subscription",
      customer: customer_id,
      line_items: line_items,
      client_reference_id: "#{current_user.id}:#{@circus.id}",
      success_url: billing_success_url + "?session_id={CHECKOUT_SESSION_ID}&circus_id=#{@circus.id}",
      cancel_url:  billing_cancel_url(circus_id: @circus.id),
      metadata: { circus_id: @circus.id }
    )

    redirect_to session.url, allow_other_host: true, status: :see_other
  rescue Stripe::InvalidRequestError => e
    Rails.logger.error("[Stripe start_checkout] #{e.message} circus=#{@circus.id} keys=#{params[:service_keys].inspect}")
    redirect_to fallback_path, alert: t("controllers.billing.start_checkout.cannot_start", error: e.message)
  end

  # ------------------------------------------------------------
  # CHECKOUT (2) — Plan único (compatibilidad)
  # POST /billing/checkout?circus_id=:id&plan=key
  # ------------------------------------------------------------
  def create_checkout_session
    request.format = :html

    plan_key = plan_param
    plan     = Plan.find_by!(key: plan_key, active: true)

    price_id = plan.stripe_price_id.to_s
    if price_id.blank?
      Rails.logger.error("[Checkout] Plan '#{plan.key}' sin stripe_price_id")
      return redirect_to fallback_path, alert: t("controllers.billing.create_checkout_session.plan_without_price", plan: plan.key)
    end

    if price_id.start_with?("prod_")
      product  = Stripe::Product.retrieve(price_id)
      price_id = product.default_price
      Rails.logger.warn("[Checkout] Plan '#{plan.key}' tenía prod_. Usando default_price=#{price_id}")
    end

    unless price_id.start_with?("price_")
      return redirect_to fallback_path, alert: t("controllers.billing.create_checkout_session.invalid_price_id_type", plan: plan.key)
    end

    subscription_data = {}
    subscription_data[:trial_period_days] = plan.trial_days if plan.trial_days.to_i.positive?

    customer_id = ensure_customer!(@circus)

    metadata = {
      circus_id: @circus.id,
      plan_key:  plan.key,
      price_id:  price_id
    }

    Rails.logger.info("[Checkout] user=#{current_user.id} circus=#{@circus.id} plan=#{plan.key} price_id=#{price_id}")

    session = Stripe::Checkout::Session.create(
      mode: "subscription",
      line_items: [ { price: price_id, quantity: 1 } ],
      client_reference_id: "#{current_user.id}:#{@circus.id}",
      subscription_data: subscription_data.presence,
      success_url: billing_success_url + "?session_id={CHECKOUT_SESSION_ID}&circus_id=#{@circus.id}",
      cancel_url:  billing_cancel_url(circus_id: @circus.id),
      customer: customer_id,
      metadata: metadata
    )

    redirect_to session.url, allow_other_host: true, status: :see_other

  rescue ActiveRecord::RecordNotFound
    redirect_to fallback_path, alert: t("controllers.billing.create_checkout_session.invalid_plan_or_circus")
  rescue Stripe::InvalidRequestError => e
    Rails.logger.error("[Stripe Checkout Error] #{e.message} (circus=#{@circus&.id} plan=#{plan_key} price_id=#{price_id})")
    msg =
      if e.code == "resource_missing" && e.param.to_s.include?("line_items[0][price]")
        t("controllers.billing.create_checkout_session.price_missing_in_stripe", plan: plan_key)
      else
        t("controllers.billing.create_checkout_session.cannot_start", error: e.message)
      end
    redirect_to fallback_path, alert: msg
  end

  # ------------------------------------------------------------
  # SUCCESS — Upsert de suscripción madre e items (multi-ítems)
  # GET /billing/success?session_id=...&circus_id=:id
  # ------------------------------------------------------------
  def success
    session_id = params[:session_id].to_s
    raise ActiveRecord::RecordNotFound, "session_id missing" if session_id.blank?

    stripe_session = Stripe::Checkout::Session.retrieve(
      id: session_id,
      expand: [
        "subscription.items.data.price",
        "subscription.latest_invoice.payment_intent", # <- importante para estados “incomplete”
        "customer"
      ]
    )

    sub_obj = stripe_session.subscription
    raise ActiveRecord::RecordNotFound, "Subscription missing in session" if sub_obj.blank?

    local_status, will_be_active = map_status_from_subscription(sub_obj)

    upsert_subscription_and_items!(
      circus: @circus,
      sub_obj: sub_obj,
      paid_flag: will_be_active, # nombre legacy; usamos el boolean ya calculado
      checkout_session_id: session_id,
      stripe_customer_id: (stripe_session.customer.is_a?(String) ? stripe_session.customer : stripe_session.customer&.id)
    )

    Rails.logger.info("[Billing#success] circus=#{@circus.id} sub=#{sub_obj.id} status=#{local_status} active=#{will_be_active}")
    flash[:notice] = t("billing.success.title") # evita renderizar el hash entero
    redirect_to dashboard_index_path

  rescue Stripe::InvalidRequestError => e
    Rails.logger.error("[Billing#success] Stripe error: #{e.message}")
    flash[:alert] = t("billing.invalid_session")
    redirect_to dashboard_index_path
  end

  # ------------------------------------------------------------
  # CANCEL — Vista simple
  # GET /billing/cancel
  # ------------------------------------------------------------
  def cancel
  end

  # ------------------------------------------------------------
  # BILLING PORTAL
  # GET /billing/portal?circus_id=:id
  # ------------------------------------------------------------
  def portal
    customer_id = ensure_customer!(@circus)

    session = Stripe::BillingPortal::Session.create(
      customer: customer_id,
      return_url: dashboard_index_url
    )
    redirect_to session.url, allow_other_host: true
  rescue Stripe::InvalidRequestError => e
    if e.message&.include?("No configuration provided")
      redirect_to dashboard_index_path, alert: t("billing.portal_not_configured", default: "El portal de cliente de Stripe (modo test) no está configurado aún.")
    else
      Rails.logger.error("[Billing#portal] #{e.message}")
      redirect_to dashboard_index_path, alert: t("controllers.billing.portal.cannot_open", error: e.message)
    end
  end

  private

  # ===== Helpers de sincronización =====

  # Upsert de la suscripción madre e items. Desactiva items removidos y garantiza
  # una sola suscripción activa por circo.
  def upsert_subscription_and_items!(circus:, sub_obj:, paid_flag:, checkout_session_id:, stripe_customer_id:)
    stripe_sub_id = sub_obj.id

    # El estado local ahora viene decidido por map_status_from_subscription
    local_status  = paid_flag ? (sub_obj.status == "trialing" ? "trialing" : "active") : (sub_obj.status || "incomplete")

    Subscription.transaction do
      scope = Subscription.where(circus_id: circus.id).lock

      sub = scope.find_or_initialize_by(stripe_subscription_id: stripe_sub_id)

      will_be_active = %w[active trialing].include?(local_status)

      if will_be_active
        if sub.new_record?
          scope.where(active: true).update_all(active: false)
        else
          scope.where(active: true).where.not(id: sub.id).update_all(active: false)
        end
      end

      head_price_id = sub_obj.items&.data&.first&.price&.id

      sub.assign_attributes(
        circus_id:            circus.id,
        status:               local_status,
        current_period_start: to_dt(sub_obj.current_period_start) || sub.current_period_start || Time.current,
        current_period_end:   to_dt(sub_obj.current_period_end)   || sub.current_period_end   || Time.current,
        cancel_at_period_end: !!sub_obj.cancel_at_period_end,
        active:               will_be_active,
        checkout_session_id:  checkout_session_id.presence || sub.checkout_session_id,
        stripe_customer_id:   stripe_customer_id.presence   || sub.stripe_customer_id,
        price_id:             head_price_id.presence        || sub.price_id
      )
      sub.save!

      Rails.logger.info("[upsert_sub] circus=#{circus.id} saved sub id=#{sub.id} status=#{sub.status} active=#{sub.active}")

      seen_ids = []
      Array(sub_obj.items&.data).each do |it|
        price = it.price
        service_key =
          (price.metadata && price.metadata["service_key"]).presence ||
          map_product_to_service(price.product)

        attrs = {
          subscription_id:             sub.id,
          stripe_subscription_item_id: it.id,
          stripe_product_id:           (price.product.is_a?(String) ? price.product : price.product&.id),
          price_id:                    price.id,
          service_key:                 service_key,
          quantity:                    it.quantity || 1,
          active:                      true,
          unit_amount:                 price.unit_amount,
          currency:                    price.currency,
          interval:                    price.recurring&.interval,
          interval_count:              price.recurring&.interval_count
        }

        item = SubscriptionItem.lock.find_or_initialize_by(stripe_subscription_item_id: it.id)
        item.assign_attributes(attrs)
        item.save!
        seen_ids << item.id
      end

      sub.subscription_items.where.not(id: seen_ids).update_all(active: false)
      Rails.logger.info("[upsert_sub] items=#{seen_ids.size} active; deactivated=#{sub.subscription_items.where(active: false).count}")
    end
  end

  # Nuevo: inferimos estado fiable desde la suscripción de Stripe
  def map_status_from_subscription(sub)
    case sub.status
    when "active"   then [ "active",   true ]
    when "trialing" then [ "trialing", true ]
    when "past_due" then [ "past_due", true ]    # a tu criterio seguir permitiendo acceso
    when "canceled" then [ "canceled", false ]
    when "unpaid"   then [ "unpaid",   false ]
    when "paused"   then [ "paused",   false ]
    when "incomplete", "incomplete_expired", nil
      pi_ok   = sub.latest_invoice&.payment_intent&.status == "succeeded"
      inv_ok  = sub.latest_invoice&.paid
      active_now = pi_ok || inv_ok
      [ active_now ? "active" : (sub.status || "incomplete"), active_now ]
    else
      [ sub.status, false ]
    end
  end

  def to_dt(unix)
    Time.at(unix).to_datetime if unix.present?
  end

  # Usa 1 Customer por circo (crea si falta)
  def ensure_customer!(circus)
    return circus.stripe_customer_id if circus.respond_to?(:stripe_customer_id) && circus.stripe_customer_id.present?

    customer = Stripe::Customer.create({
      name: circus.name,
      email: current_user.email,
      metadata: { circus_id: circus.id }
    })
    circus.update!(stripe_customer_id: customer.id) if circus.respond_to?(:stripe_customer_id)
    customer.id
  end

  # Precio (Price ID) por servicio (usa ENV o tu persistencia preferida)
  def price_for(service_key)
    {
      "core"        => ENV.fetch("PRICE_CORE"),
      "ticketing"   => ENV.fetch("PRICE_TICKETING"),
      "concessions" => ENV.fetch("PRICE_CONCESSIONS"),
      "all_in_one"  => ENV.fetch("PRICE_ALL_IN_ONE")
    }.fetch(service_key)
  end

  # Si no pones metadata.service_key en el Price/Product, mapea por product_id aquí
  def map_product_to_service(product_id_or_obj)
    product_id = product_id_or_obj.is_a?(String) ? product_id_or_obj : product_id_or_obj&.id
    {
      # 'prod_xxx' => 'core',
      # 'prod_yyy' => 'ticketing',
    }[product_id] || "core"
  end

  # ===== Infra básica =====

  def load_circus!
    id = params[:circus_id] || params.dig(:circus, :id) || params[:id]
    if id.present?
      @circus = current_user.circuses.find(id)
    else
      case current_user.circuses.count
      when 1 then @circus = current_user.circuses.first
      when 0 then redirect_to dashboard_index_path, alert: t("controllers.shared.circus_required.none_created") and return
      else        redirect_to dashboard_index_path, alert: t("controllers.shared.circus_required.select_one") and return
      end
    end
  end

  def current_active_subscription
    @current_active_subscription ||= @circus.subscriptions.where(active: true).order(current_period_end: :desc).first
  end

  # Evita checkouts si ya hay una suscripción activa (protege de cobros duplicados)
  def prevent_duplicate_checkout
    return unless current_active_subscription.present?
    Rails.logger.info("[Billing] prevent_duplicate_checkout circus=#{@circus.id} sub_id=#{current_active_subscription.id}")
    redirect_to portal_billing_path(circus_id: @circus.id),
      notice: t("billing.already_active", default: "Ya tienes una suscripción activa. Adminístrala en el portal de facturación.")
  end

  def plan_param
    params[:plan].presence || params[:plan_choice].presence || (raise ActionController::ParameterMissing, :plan)
  end

  def fallback_path
    dashboard_index_path
  end
end
