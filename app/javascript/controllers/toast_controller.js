import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast"
export default class extends Controller {
  connect() {
    // Auto-dismiss after 4 seconds
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 4000)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    this.element.style.transition = "opacity 0.3s ease-out, transform 0.3s ease-out"
    this.element.style.opacity = "0"
    this.element.style.transform = "translateY(-10px)"
    
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
