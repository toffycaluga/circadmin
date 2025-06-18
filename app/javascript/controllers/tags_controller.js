// app/javascript/controllers/tags_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "container", "hidden"]

  connect() {
    this.syncTagsFromHidden()
  }

  addTag(event) {
    if (event.key === "Enter" || event.key === ",") {
      event.preventDefault()
      const tag = this.inputTarget.value.trim()
      if (tag === "") return
      this.appendTag(tag)
      this.inputTarget.value = ""
    }
  }

  appendTag(tag) {
    // evitar duplicados
    const tags = this.tags
    if (tags.includes(tag)) return

    const span = document.createElement("span")
    span.className = "badge bg-primary-subtle text-primary border border-primary rounded-pill px-2 py-1 d-flex align-items-center shadow-sm"
    span.innerHTML = `
      <span class="me-1">${tag}</span>
      <button type="button" class="btn-close btn-sm ms-1" aria-label="Eliminar" data-action="click->tags#removeTag" data-tag="${tag}"></button>
    `
    this.containerTarget.appendChild(span)

    this.tags = [...tags, tag]
  }

  removeTag(event) {
    const tag = event.currentTarget.dataset.tag
    this.tags = this.tags.filter(t => t !== tag)
    event.currentTarget.closest("span").remove()
  }

  syncTagsFromHidden() {
    const tags = this.hiddenTarget.value.split(",").map(t => t.trim()).filter(Boolean)
    tags.forEach(tag => this.appendTag(tag))
  }

  get tags() {
    return this.hiddenTarget.value.split(",").map(t => t.trim()).filter(Boolean)
  }

  set tags(value) {
    this.hiddenTarget.value = value.join(",")
  }
}
