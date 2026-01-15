// app/javascript/controllers/mobile_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.querySelectorAll(".mobile-menu").forEach(btn =>
      btn.addEventListener("click", () => btn.classList.toggle("on"))
    )
    document.querySelectorAll("#mobile-collapse").forEach(btn =>
      btn.addEventListener("click", () => {
        const vw = window.innerWidth
        if (vw > 991) {
          document.querySelector(".pcoded-navbar:not(.theme-horizontal)")
            .classList.toggle("navbar-collapsed")
        }
      })
    )
    document.querySelectorAll(".mob-toggler").forEach(btn =>
      btn.addEventListener("click", () => {
        document.querySelectorAll(".pcoded-header .collapse")
          .forEach(c => c.classList.toggle("d-flex"))
      })
    )
    // close on outside tap
    document.addEventListener("click", (e) => {
      if (window.innerWidth < 992 &&
          !e.target.closest(".pcoded-navbar") &&
          document.querySelector(".pcoded-navbar.mob-open")) {
        document.querySelector(".pcoded-navbar").classList.remove("mob-open")
      }
    })
  }
}
