import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = [ "drawer", "overlay" ]
  connect() {
    this.drawerTarget.classList.add("open")
    this.overlayTarget.classList.add("open")
    document.body.style.overflow = "hidden"
  }
  disconnect() {
    this.drawerTarget.classList.remove("open")
    this.overlayTarget.classList.remove("open")
    document.body.style.overflow = ""
  }
  toggle() {
    this.drawerTarget.classList.toggle("open")
    this.overlayTarget.classList.toggle("open")
    document.body.style.overflow = this.drawerTarget.classList.contains("open") ? "hidden" : ""
  }
}
