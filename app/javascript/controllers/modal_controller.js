import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  close(event) {
    // Si el click llega aquí, cerramos el modal
    this.element.innerHTML = ""
  }

  stop(event) {
    // Evitamos que clicks dentro del modal lleguen a `close`
    event.stopPropagation()
  }
}
