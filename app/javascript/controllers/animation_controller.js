import { Controller } from "@hotwired/stimulus"
import ScrollReveal from "scrollreveal"
import anime        from "animejs"

export default class extends Controller {
  connect() {
    document.documentElement.classList.replace('no-js','js')
    if (document.body.classList.contains('has-animations')) {
      const sr = ScrollReveal()
      // …
      document.documentElement.classList.add('anime-ready')
      // …
    }
  }
}
