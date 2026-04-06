import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "spinner"]

  show() {
    // If it's a submit button inside a form, check validity first
    const form = this.element.closest('form')
    if (form && !form.checkValidity()) return

    if (this.hasContentTarget) {
      this.contentTarget.classList.add("invisible")
    }
    
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.remove("hidden")
    }
    
    // Fallback if no targets are defined: replace HTML but keep width
    if (!this.hasContentTarget && !this.hasSpinnerTarget) {
      if (!this.element.dataset.originalHtml) {
        this.element.dataset.originalHtml = this.element.innerHTML
        
        // Preserve width so button doesn't shrink
        const width = this.element.offsetWidth
        if (width > 0) this.element.style.width = width + "px"
        
        this.element.innerHTML = `<svg class="animate-spin h-5 w-5 mx-auto text-current" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>`
        
        // Disable button to prevent double clicks
        this.element.disabled = true
      }
    }
  }

  hide() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.remove("invisible")
    }
    
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.add("hidden")
    }
    
    if (this.element.dataset.originalHtml) {
      this.element.innerHTML = this.element.dataset.originalHtml
      delete this.element.dataset.originalHtml
      this.element.style.width = ""
      this.element.disabled = false
    }
  }
}
