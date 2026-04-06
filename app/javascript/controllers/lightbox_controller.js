import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image"]

  open(e) {
    const trigger = e.currentTarget
    this.imageTarget.src = trigger.dataset.zoomUrl || trigger.src
    this.element.classList.remove("hidden")
    this.element.classList.add("flex")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.element.classList.add("hidden")
    this.element.classList.remove("flex")
    document.body.style.overflow = ""
  }

  closeOnBackdrop(e) {
    if (e.target === this.element) this.close()
  }

  connect() {
    this._escHandler = (e) => { if (e.key === "Escape") this.close() }
    document.addEventListener("keydown", this._escHandler)
  }

  disconnect() {
    document.removeEventListener("keydown", this._escHandler)
  }
}
