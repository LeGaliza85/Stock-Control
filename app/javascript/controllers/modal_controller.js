import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  open(e) {
    if (e) e.preventDefault()
    this.element.classList.remove("hidden")
    this.element.classList.add("flex")
    document.body.style.overflow = "hidden"
  }

  close(e) {
    if (e) e.preventDefault()
    this.element.classList.add("hidden")
    this.element.classList.remove("flex")
    document.body.style.overflow = ""
  }

  closeOnBackdrop(e) {
    if (e.target === this.element) this.close(e)
  }

  connect() {
    this._escHandler = (e) => { if (e.key === "Escape") this.close(e) }
    document.addEventListener("keydown", this._escHandler)
  }

  disconnect() {
    document.removeEventListener("keydown", this._escHandler)
  }
}
