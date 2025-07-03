// app/javascript/controllers/side_nav_controller.js
import { Controller } from "@hotwired/stimulus"

// Si SideNav lo estás cargando como global (por CDN o por pack), apunta a window.SideNav.
// Si lo importas vía npm/pack, en lugar de window.SideNav, haz:
//    import { SideNav } from "nombre-del-paquete"
const SideNavClass = window.SideNav

export default class extends Controller {
  static values = {
    orientation: { type: String, default: "vertical" },
    animate:     { type: Boolean, default: true },
    accordion:   { type: Boolean, default: true },
    closeChildren: { type: Boolean, default: true },
    showDropdownOnHover: { type: Boolean, default: false }
  }

  connect() {
    // Esperamos un tick para asegurar que el DOM esté listo
    setTimeout(() => {
      this._initSideNav()
    }, 0)
  }

  disconnect() {
    // Si quieres destruirlo al salir de la página:
    if (this.instance && this.instance.destroy) {
      this.instance.destroy()
    }
  }

  _initSideNav() {
    if (!SideNavClass) {
      console.error("SideNav no está disponible en window.SideNav")
      return
    }
    // El plugin espera un elemento con .sidenav-inner
    const el = this.element.querySelector(".sidenav-inner")
    if (!el) {
      console.warn("No encontré .sidenav-inner dentro de", this.element)
      return
    }

    // Construimos las opciones
    const opts = {
      orientation:        this.orientationValue,
      animate:            this.animateValue,
      accordion:          this.accordionValue,
      closeChildren:      this.closeChildrenValue,
      showDropdownOnHover:this.showDropdownOnHoverValue
    }

    // Creamos la instancia
    this.instance = new SideNavClass(el, opts)
  }
}
