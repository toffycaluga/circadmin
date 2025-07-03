// app/javascript/controllers/navigation_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.navbar = this.element.querySelector('.pcoded-navbar')
    this.updateMenu()
    window.addEventListener("resize", this.updateMenu.bind(this))
  }

  disconnect() {
    window.removeEventListener("resize", this.updateMenu.bind(this))
  }

  toggle(event) {
    event.preventDefault()
    this.navbar?.classList.toggle("collapsed")
  }

  updateMenu() {
    if (!this.navbar) return
    if (window.innerWidth >= 992) {
      this.navbar.classList.remove("collapsed")
    } else {
      this.navbar.classList.add("collapsed")
    }
  }
}
