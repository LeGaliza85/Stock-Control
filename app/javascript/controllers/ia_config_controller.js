import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["option", "geminiSelect"]

  change(e) {
    const serviceId = e.currentTarget.value
    
    this.optionTargets.forEach(opt => {
      if (opt.dataset.service === serviceId) {
        opt.classList.add("border-[#B8860B]", "bg-[#F5ECD7]/30")
        opt.classList.remove("border-[#E8E0D4]")
      } else {
        opt.classList.remove("border-[#B8860B]", "bg-[#F5ECD7]/30")
        opt.classList.add("border-[#E8E0D4]")
      }
    })

    if (this.hasGeminiSelectTarget) {
      this.geminiSelectTarget.classList.toggle("hidden", serviceId !== "gemini")
    }
  }
}
