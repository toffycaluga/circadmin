import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  static targets = ["modal", "title", "body", "actionButton"]
  static values  = { circusId: Number }

  connect() {
    // Si el target no está aún disponible, fallback por id del modal
    if (this.hasModalTarget) {
      this.bsModal = new Modal(this.modalTarget)
    } else {
      const el = document.getElementById("subscriptionModal")
      if (el) this.bsModal = new Modal(el)
    }
  }

  async check(event) {
    event.preventDefault()
    const destination = event.currentTarget.getAttribute("href")
    const circusId =
      this.hasCircusIdValue ? this.circusIdValue : document.body.dataset.circusId

    if (!circusId) {
      console.error("subscription-check: circusId no definido")
      return this._showFallbackModal()
    }

    try {
      const res = await fetch(`/circuses/${circusId}/subscription/check_availability.json`, {
        headers: { "Accept": "application/json" }
      })

      const contentType = res.headers.get("content-type") || ""
      if (!contentType.includes("application/json")) {
        console.warn("subscription-check: respuesta NO JSON")
        return this._showFallbackModal()
      }

      const json = await res.json()

      if (json.allowed) {
        window.location = destination
      } else {
        this._showModal(json.title, json.body, json.action)
      }
    } catch (err) {
      console.error("subscription-check error:", err)
      this._showFallbackModal()
    }
  }

  _showModal(title = "", body = "", actionHref = null) {
    const modalEl = this.hasModalTarget ? this.modalTarget : document.getElementById("subscriptionModal")
    if (!modalEl) {
      console.error("subscription-check: modalTarget no encontrado en el DOM")
      return
    }

    const titleEl  = this.hasTitleTarget ? this.titleTarget  : modalEl.querySelector('[data-subscription-check-target="title"]')
    const bodyEl   = this.hasBodyTarget  ? this.bodyTarget   : modalEl.querySelector('[data-subscription-check-target="body"]')
    const actionEl = this.hasActionButtonTarget ? this.actionButtonTarget : modalEl.querySelector('[data-subscription-check-target="actionButton"]')

    if (titleEl) titleEl.textContent = title || ""
    if (bodyEl)  bodyEl.textContent  = body  || ""
    if (actionEl && actionHref) actionEl.href = actionHref

    if (!this.bsModal) this.bsModal = new Modal(modalEl)
    this.bsModal.show()
  }

  _showFallbackModal() {
    this._showModal(
      "Ups, ocurrió un problema",
      "No pudimos verificar tu suscripción. Intenta nuevamente.",
      null
    )
  }
}
