// app/javascript/controllers/preloader_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.element.classList.add("fade")
      setTimeout(() => this.element.remove(), 500)
    }, 400)
  }
}
