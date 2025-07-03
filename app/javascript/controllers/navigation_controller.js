// app/javascript/controllers/navigation_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.updateMenu()
    window.addEventListener("resize", () => this.updateMenu())
    window.addEventListener("scroll", () => this.onScroll())
  }

  updateMenu() {
    const vw = window.innerWidth
    const navbar = document.querySelector(".pcoded-navbar:not(.theme-horizontal)")
    if (!navbar) return

    if (vw <= 1200 && vw >= 992) {
      navbar.classList.add("navbar-collapsed")
    } else if (vw < 992) {
      navbar.classList.remove("navbar-collapsed")
    }
    // horizontal wrapper
    this.toggleHorizontal(vw)
  }

  toggleHorizontal(vw) {
    const wrap = document.querySelector(".sidenav-horizontal-wrapper")
    const wrapDis = document.querySelector(".sidenav-horizontal-wrapper-dis")
    if (vw < 992) {
      wrap?.classList.replace("sidenav-horizontal-wrapper", "sidenav-horizontal-wrapper-dis")
      document.querySelectorAll(".theme-horizontal")
        .forEach(el => el.classList.replace("theme-horizontal", "theme-horizontal-dis"))
    } else {
      wrapDis?.classList.replace("sidenav-horizontal-wrapper-dis", "sidenav-horizontal-wrapper")
      document.querySelectorAll(".theme-horizontal-dis")
        .forEach(el => el.classList.replace("theme-horizontal-dis", "theme-horizontal"))
    }
  }

  onScroll() {
    const vw = window.innerWidth
    if (vw < 768) return
    const cOst = window.scrollY
    const nav = document.querySelector(".theme-horizontal")
    if (!nav) return

    if (cOst >= 400) {
      nav.classList.add("top-nav-collapse")
    } else {
      nav.classList.add("default")
      nav.classList.remove("top-nav-collapse")
    }
  }
}
