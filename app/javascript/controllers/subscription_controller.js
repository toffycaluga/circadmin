// app/javascript/controllers/subscription_controller.js
import { Controller } from "@hotwired/stimulus"
import { loadStripe } from "@stripe/stripe-js"

export default class extends Controller {
  static targets = [
    "plansContainer",
    "paymentContainer",
    "cardElement",
    "errors",
    "planInput",
    "paymentInput",
    "submitButton",
    "selectedName"
  ]

  connect() {
    this.stripePromise = loadStripe(this.data.get("subscription_publishable_key"))
  }

  selectPlan(e) {
    e.preventDefault()
    const card = e.currentTarget
    const planId   = card.dataset.planId
    const planName = card.dataset.planName

    // 1) Marca el radio dentro de la tarjeta
    const radio = card.querySelector(`input[value="${planId}"]`)
    if (radio) radio.checked = true

    // 2) Rellena el campo oculto y el nombre seleccionado
    this.planInputTarget.value       = planId
    this.selectedNameTarget.textContent = planName

    // 3) Muestra el contenedor de pago y configura Stripe Elements
    this.paymentContainerTarget.classList.remove("d-none")
    this.setupCard()
  }

  async setupCard() {
    if (this.card) return
    const stripe  = await this.stripePromise
    this.elements = stripe.elements()
    this.card     = this.elements.create("card")
    this.card.mount(this.cardElementTarget)
    this.card.on("change", e => {
      this.errorsTarget.textContent       = e.error ? e.error.message : ""
      this.submitButtonTarget.disabled = !!e.error
    })
  }


  async submit(e) {
    e.preventDefault()
    this.submitButtonTarget.disabled = true
    const stripe = await this.stripePromise
    const { paymentMethod, error } = await stripe.createPaymentMethod({
      type: "card",
      card: this.card
    })
    if (error) {
      this.errorsTarget.textContent = error.message
      this.submitButtonTarget.disabled = false
      return
    }
    this.paymentInputTarget.value = paymentMethod.id

    const resp = await fetch(this.element.action, {
      method: "POST",
      headers: { "Content-Type": "application/json", "Accept": "application/json" },
      body: JSON.stringify({
        plan_id:           this.planInputTarget.value,
        payment_method_id: this.paymentInputTarget.value
      })
    })
    const json = await resp.json()
    if (json.error) {
      this.errorsTarget.textContent = json.error
      this.submitButtonTarget.disabled = false
    } else {
      window.location = json.redirect_url
    }
  }

  closePayment() {
    this.paymentContainerTarget.classList.add("d-none")
  }
}
