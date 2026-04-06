import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "imageContainer"]

  open(e) {
    const trigger = e.currentTarget
    this.imageTarget.src = trigger.dataset.zoomUrl || trigger.src
    this.imageContainerTarget.classList.remove("hidden")
    this.imageContainerTarget.classList.add("flex")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.imageContainerTarget.classList.add("hidden")
    this.imageContainerTarget.classList.remove("flex")
    document.body.style.overflow = ""
  }

  closeOnBackdrop(e) {
    if (e.target === this.imageContainerTarget) this.close()
  }

  connect() {
    this._escHandler = (e) => { if (e.key === "Escape") this.close() }
    document.addEventListener("keydown", this._escHandler)
  }

  disconnect() {
    document.removeEventListener("keydown", this._escHandler)
  }
}
