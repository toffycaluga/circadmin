// app/javascript/controllers/fullscreen_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle() {
    if (!document.fullscreenElement) {
      document.documentElement.requestFullscreen()
    } else {
      document.exitFullscreen()
    }
    this.element.querySelector("i").classList.toggle("icon-maximize")
    this.element.querySelector("i").classList.toggle("icon-minimize")
  }
}
