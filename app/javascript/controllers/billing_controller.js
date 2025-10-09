import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "body", "actionButton"]

  connect() {
    // si la página incluyó un data-modal="true", lo mostramos
    const modalData = JSON.parse(this.element.dataset.modal || "null")
    if (modalData) {
      this.titleTarget.textContent        = modalData.title
      this.bodyTarget.textContent         = modalData.body
      this.actionButtonTarget.href        = modalData.action
      this.actionButtonTarget.textContent = modalData.buttonText || "Ir a suscripción"
      new bootstrap.Modal(this.element).show()
    }
  }
}
