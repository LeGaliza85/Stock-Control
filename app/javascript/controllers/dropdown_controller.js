import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle(e) {
    e.preventDefault()
    e.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  connect() {
    this._clickOutside = (e) => {
      if (!this.element.contains(e.target)) {
        this.menuTarget.classList.add("hidden")
      }
    }
    document.addEventListener("click", this._clickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this._clickOutside)
  }
}
