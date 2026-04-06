import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "drawer", "overlay" ]

  connect() {
    // Ensuring the drawer starts closed on connect
    this.drawerTarget.classList.remove("open")
    this.overlayTarget.classList.remove("open")
    document.body.style.overflow = ""
  }

  disconnect() {
    this.drawerTarget.classList.remove("open")
    this.overlayTarget.classList.remove("open")
    document.body.style.overflow = ""
  }

  toggle() {
    const isOpen = this.drawerTarget.classList.contains("open")
    
    this.drawerTarget.classList.toggle("open")
    this.overlayTarget.classList.toggle("open")
    
    // Toggle overflow based on the new state
    document.body.style.overflow = !isOpen ? "hidden" : ""
  }
}
