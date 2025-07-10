// app/javascript/controllers/subscription_check_controller.js
import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  static targets = ["modal", "title", "body", "actionButton"]

  connect() {
    // Creamos la instancia de Bootstrap Modal
    this.bsModal = new Modal(this.modalTarget)
  }

  check(event) {
    event.preventDefault()
    console.log("–> disparó subscription-check#check")

    const destination = event.currentTarget.getAttribute("href")

    fetch("/subscriptions/check_availability", {
      headers: { Accept: "application/json" }
    })
      .then(r => r.json())
      .then(json => {
        console.log("RESPUESTA CHECK:", json)
        if (json.allowed) {
          window.location = destination
        } else {
          // Rellenamos el modal
          this.titleTarget.textContent        = json.title
          this.bodyTarget.textContent         = json.body
          this.actionButtonTarget.href        = json.action
          // Y lo mostramos
          this.bsModal.show()
        }
      })
  }
}
