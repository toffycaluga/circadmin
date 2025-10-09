// app/javascript/controllers/subscription_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["planInput", "submitButton", "plansContainer", "planRadio"]
  static values  = { selectPlanMessage: String }

  selectPlan(event) {
    const card = event.currentTarget
    const planKey = card.dataset.planKey
    if (!planKey) return

    // Setea hidden field para el POST
    if (this.hasPlanInputTarget) {
      this.planInputTarget.value = planKey
    }

    // Marca el radio visual
    const radio = card.querySelector('input[type="radio"]')
    if (radio) radio.checked = true

    // Quita selección previa y marca la card actual
    if (this.hasPlansContainerTarget) {
      this.plansContainerTarget
        .querySelectorAll(".plan-card.selected")
        .forEach(el => el.classList.remove("selected"))
    }
    card.classList.add("selected")

    // Habilita el submit
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = false
    }
  }

  validate(event) {
    // Evita submit si no hay plan
    if (!this.hasPlanInputTarget || !this.planInputTarget.value) {
      event.preventDefault()
      const msg = this.hasSelectPlanMessageValue ? this.selectPlanMessageValue : ""
      alert(msg)
    }
  }
}
