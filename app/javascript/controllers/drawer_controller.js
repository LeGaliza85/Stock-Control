import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drawer", "overlay"]

  open(e) {
    if (e) e.preventDefault()
    this.drawerTarget.classList.add("open")
    this.overlayTarget.classList.add("open")
    document.body.style.overflow = "hidden"
  }

  close(e) {
    if (e) e.preventDefault()
    this.drawerTarget.classList.remove("open")
    this.overlayTarget.classList.remove("open")
    document.body.style.overflow = ""
  }
}
