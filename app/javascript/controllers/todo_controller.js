// app/javascript/controllers/todo_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.querySelectorAll("input[type=checkbox]").forEach(cb =>
      cb.addEventListener("click", () => {
        cb.parentElement.classList.toggle("done-task", cb.checked)
      })
    )
  }
}
