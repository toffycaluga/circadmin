// app/javascript/controllers/subscription_check_controller.js
import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  static targets = ["modal", "title", "body", "actionButton"]
  static values  = { circusId: Number, requiredService: String }

  connect() {
    // Instancia el modal ya sea por target o por id de respaldo
    if (this.hasModalTarget) {
      this.bsModal = new Modal(this.modalTarget)
    } else {
      const el = document.getElementById("subscriptionModal")
      if (el) this.bsModal = new Modal(el)
    }
  }

  async check(event) {
    event.preventDefault()

    // Destino de navegación
    const destination = event.currentTarget.getAttribute("href") || event.currentTarget.dataset?.destination
    if (!destination) {
      console.warn("subscription-check: no hay destino (href o data-destination)")
      return this._showFallbackModal()
    }

    // Circus ID
    const circusId = this.hasCircusIdValue
      ? this.circusIdValue
      : document.body.dataset.circusId
    if (!circusId) {
      console.error("subscription-check: circusId no definido")
      return this._showFallbackModal()
    }

    // Prevención doble click
    const el = event.currentTarget
    const prevDisabled = el.hasAttribute("disabled")
    el.setAttribute("disabled", "disabled")

    try {
      // Construye URL con ?service= si corresponde
      const url = new URL(`/circuses/${circusId}/subscription/check_availability.json`, window.location.origin)
      if (this.hasRequiredServiceValue && this.requiredServiceValue) {
        url.searchParams.set("service", this.requiredServiceValue)
      }

      const res = await fetch(url.toString(), {
        method: "GET",
        headers: { "Accept": "application/json" },
        credentials: "same-origin",
        cache: "no-store"
      })

      // Manejo de estados no-200 (401/403/500, etc.)
      if (!res.ok) {
        if (res.status === 401) {
          // No autenticado -> redirige a login si tu app usa Devise/Turbo
          return (window.Turbo?.visit ? Turbo.visit("/users/sign_in") : (window.location.href = "/users/sign_in"))
        }
        console.warn(`subscription-check: HTTP ${res.status}`)
        return this._showFallbackModal()
      }

      const contentType = res.headers.get("content-type") || ""
      if (!contentType.includes("application/json")) {
        console.warn("subscription-check: respuesta NO JSON")
        return this._showFallbackModal()
      }

      const json = await res.json()
      // Opcional: log de depuración
      // console.debug("subscription-check response:", json)

      if (json.allowed) {
        // Usa Turbo si está disponible para mantener estado Hotwire
        return (window.Turbo?.visit ? Turbo.visit(destination) : (window.location = destination))
      } else {
        this._showModal(json.title, json.body, json.action)
      }
    } catch (err) {
      console.error("subscription-check error:", err)
      this._showFallbackModal()
    } finally {
      if (!prevDisabled) el.removeAttribute("disabled")
    }
  }

  _showModal(title = "", body = "", actionHref = null) {
    const modalEl = this.hasModalTarget ? this.modalTarget : document.getElementById("subscriptionModal")
    if (!modalEl) {
      console.error("subscription-check: modalTarget no encontrado en el DOM")
      return
    }

    const titleEl  = this.hasTitleTarget  ? this.titleTarget  : modalEl.querySelector('[data-subscription-check-target="title"]')
    const bodyEl   = this.hasBodyTarget   ? this.bodyTarget   : modalEl.querySelector('[data-subscription-check-target="body"]')
    const actionEl = this.hasActionButtonTarget ? this.actionButtonTarget : modalEl.querySelector('[data-subscription-check-target="actionButton"]')

    if (titleEl) titleEl.textContent = title || ""
    if (bodyEl)  bodyEl.textContent  = body  || ""

    if (actionEl) {
      if (actionHref) {
        actionEl.classList.remove("d-none")
        actionEl.href = actionHref
      } else {
        actionEl.classList.add("d-none")
        actionEl.removeAttribute("href")
      }
    }

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
