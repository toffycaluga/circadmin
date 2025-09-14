# app/controllers/billing_controller.rb
# Flujo: Stripe Checkout (suscripciones) + Billing Portal
# Requisitos:
# - Modelo Plan con columnas: key, stripe_price_id, price_cents, trial_days, active:boolean
# - current_user autenticado (Devise u otro)
# - ENV (Figaro/Credentials): STRIPE_SECRET_KEY, STRIPE_PUBLISHABLE_KEY, STRIPE_WEBHOOK_SECRET
#
# Rutas esperadas en config/routes.rb:
#   post "billing/checkout", to: "billing#create_checkout_session"
#   get  "billing/success",  to: "billing#success"
#   get  "billing/cancel",   to: "billing#cancel"
#   get  "billing/portal",   to: "billing#portal"
#
# Webhook (en otro controller):
#   post "/webhooks/stripe", to: "webhooks/stripe#receive"

class BillingController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  # POST /billing/checkout
  def create_checkout_session
    plan_key = plan_param
    plan     = find_plan!(plan_key)

    price_id = plan.stripe_price_id.to_s
    if price_id.blank?
      Rails.logger.error("[Checkout] Plan '#{plan.key}' sin stripe_price_id")
      return redirect_to fallback_path, alert: "El plan '#{plan.key}' no tiene Price configurado en Stripe."
    end

    # 🔒 Si guardaron un prod_ por error, conviértelo a price_ usando el default_price
    if price_id.start_with?("prod_")
      product = Stripe::Product.retrieve(price_id)
      price_id = product.default_price
      Rails.logger.warn("[Checkout] Plan '#{plan.key}' tenía prod_ en vez de price_. Usando default_price=#{price_id}")
    end

    unless price_id.start_with?("price_")
      return redirect_to fallback_path, alert: "El ID configurado para el plan '#{plan.key}' no es un Price válido de Stripe."
    end

    # Trial opcional
    subscription_data = {}
    subscription_data[:trial_period_days] = plan.trial_days if plan.trial_days.to_i.positive?

    Rails.logger.info("[Checkout] user=#{current_user.id} plan=#{plan.key} price_id=#{price_id}")

    session = Stripe::Checkout::Session.create(
      mode: "subscription",
      line_items: [ { price: price_id, quantity: 1 } ],
      client_reference_id: current_user.id.to_s,
      customer_email: current_user.email,
      subscription_data: subscription_data.presence,
      success_url: billing_success_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url:  billing_cancel_url
    )

    redirect_to session.url, allow_other_host: true, status: :see_other

  rescue ActiveRecord::RecordNotFound
    redirect_to fallback_path, alert: "Plan inválido o inactivo."
  rescue Stripe::InvalidRequestError => e
    Rails.logger.error("[Stripe Checkout Error] #{e.message} (plan=#{plan_key} price_id=#{price_id})")
    msg =
      if e.code == "resource_missing" && e.param.to_s.include?("line_items[0][price]")
        "El Price ID de Stripe para el plan '#{plan_key}' no existe en tu cuenta/modo actual."
      else
        "No se pudo iniciar el checkout: #{e.message}"
      end
    redirect_to fallback_path, alert: msg
  end

  # GET /billing/success
  def success
    @session_id = params[:session_id]
    # Ejemplo opcional:
    # @session = Stripe::Checkout::Session.retrieve(@session_id) if @session_id.present?
  end

  # GET /billing/cancel
  def cancel
  end

  # GET /billing/portal
  def portal
    unless current_user.stripe_customer_id.present?
      return redirect_to fallback_path, alert: "Aún no hay un cliente de Stripe asociado. Completa una suscripción primero."
    end

    portal_session = Stripe::BillingPortal::Session.create(
      customer: current_user.stripe_customer_id,
      return_url: root_url
    )

    redirect_to portal_session.url, allow_other_host: true, status: :see_other

  rescue Stripe::InvalidRequestError => e
    Rails.logger.error("[Stripe Portal Error] #{e.message}")
    redirect_to fallback_path, alert: "No se pudo abrir el portal de facturación: #{e.message}"
  end

  private

  def plan_param
    params[:plan].presence || params[:plan_choice].presence || (raise ActionController::ParameterMissing, :plan)
  end

  def find_plan!(key)
    Plan.find_by!(key: key.to_s, active: true)
  end

  def fallback_path
    if respond_to?(:subscriptions_new_path)
      subscriptions_new_path
    else
      root_path
    end
  end
end
