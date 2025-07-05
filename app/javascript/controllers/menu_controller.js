// app/javascript/controllers/menu_controller.js
import { Controller } from "@hotwired/stimulus"
import PerfectScrollbar from "perfect-scrollbar"

export default class extends Controller {
  connect() {
    this.toggleMenu()
    window.addEventListener("resize", this.toggleMenu.bind(this))

    // inicializar tooltips y popovers de Bootstrap
    document.querySelectorAll('[data-toggle="tooltip"]').forEach(el =>
      new bootstrap.Tooltip(el)
    )
    document.querySelectorAll('[data-toggle="popover"]').forEach(el =>
      new bootstrap.Popover(el)
    )

    // preloader
    setTimeout(() => {
      document.querySelectorAll('.loader-bg').forEach(el => el.remove())
    }, 400)

    // inicializa perfect-scrollbar si hay noti-body
    if (document.querySelector('.noti-body')) {
      new PerfectScrollbar('.notification .noti-body', { wheelSpeed: .5 })
    }
  }

  // Acción disparada al hacer click en el botón mobile-menu
  toggleMobileMenu(event) {
    event.currentTarget.classList.toggle("on")
  }

  // Acción disparada al hacer click en #mobile-collapse
  collapseNavbar(event) {
    const vw = window.innerWidth
    if (vw < 992) {
      document.querySelector(".pcoded-navbar").classList.toggle("mob-open")
      event.stopPropagation()
    }
  }

  // Lógica de colapso automático según tamaño
  toggleMenu() {
    const vw = window.innerWidth
    const nav = document.querySelector(".pcoded-navbar:not(.theme-horizontal)")
    if (!nav) return

    if (vw <= 1200 && vw >= 992) {
      nav.classList.add("navbar-collapsed")
    } else if (vw < 992) {
      nav.classList.remove("navbar-collapsed")
    }
  }
}
