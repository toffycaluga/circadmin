// app/javascript/controllers/search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "bar"]

  connect() {
    this.openOnMobile()
  }

  open() {
    this.barTarget.classList.add("open")
    const width = window.innerWidth <= 991 ? 90 : 150
    this.inputTarget.style.width = `${width}px`
  }

  close() {
    this.barTarget.classList.remove("open")
    this.inputTarget.style.width = "0"
  }

  toggleBar() {
    this.barTarget.querySelector("input").focus()
    this.barTarget.classList.toggle("open")
  }

  openOnMobile() {
    if (window.innerWidth <= 991) {
      this.barTarget.classList.add("open")
      this.inputTarget.style.width = "100px"
    }
  }
}
