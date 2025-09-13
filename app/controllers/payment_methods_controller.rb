class PaymentMethodsController < ApplicationController
  before_action :set_circus

  def index
    @payment_methods = @circus.payment_methods
  end

  def new
    # Prepara un SetupIntent para Stripe Elements
    @setup_intent = Stripe::SetupIntent.create(customer: @circus.stripe_customer_id)
  end

  def create
    pm_id = params[:payment_method_id]
    # Attacha método de pago
    Stripe::PaymentMethod.attach(pm_id, { customer: @circus.stripe_customer_id })
    Stripe::Customer.update(
      @circus.stripe_customer_id,
      invoice_settings: { default_payment_method: pm_id }
    )
    # Guarda en DB
    @circus.payment_methods.update_all(default: false)
    @circus.payment_methods.create!(
      stripe_payment_method_id: pm_id,
      card_brand:               params[:card_brand],
      last4:                    params[:last4],
      exp_month:                params[:exp_month],
      exp_year:                 params[:exp_year],
      default:                  true
    )
    redirect_to circus_payment_methods_path(@circus), notice: "Método agregado"
  end

  def destroy
    pm = @circus.payment_methods.find(params[:id])
    Stripe::PaymentMethod.detach(pm.stripe_payment_method_id)
    pm.destroy
    redirect_to circus_payment_methods_path(@circus), notice: "Método eliminado"
  end

  private

  def set_circus
    @circus = Circus.find(params[:circus_id])
  end
end
