// app/javascript/controllers/floating_label_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.inputTargets.forEach(input => {
      this.update(input)
      input.addEventListener("focus", () => this.fill(input, true))
      input.addEventListener("blur", () => this.update(input))
    })
  }

  update(input) {
    const hasValue = input.value.length > 0 || (input.placeholder || "").length > 0
    input.parentElement.classList.toggle("fill", hasValue)
  }

  fill(input, state) {
    input.parentElement.classList.toggle("fill", state)
  }
}
