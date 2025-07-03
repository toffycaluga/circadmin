// app/javascript/controllers/card_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["body", "block", "spinner"]

  close() {
    this.element.classList.add("anim-close-card")
    setTimeout(() => this.element.remove(), 1500)
  }

  reload() {
    this.element.classList.add("card-load")
    this.spinnerTarget.classList.remove("d-none")
    setTimeout(() => {
      this.spinnerTarget.classList.add("d-none")
      this.element.classList.remove("card-load")
    }, 3000)
  }

  toggle() {
    this.bodyTarget.classList.toggle("d-none")
  }

  fullscreen() {
    this.element.classList.toggle("full-card")
    document.body.style.overflow = this.element.classList.contains("full-card") ? "hidden" : ""
  }
}
