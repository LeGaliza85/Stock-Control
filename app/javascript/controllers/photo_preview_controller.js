import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preview"]

  preview(event) {
    const container = this.previewTarget
    container.innerHTML = ""

    const files = event.target.files
    if (!files.length) return

    Array.from(files).forEach((file) => {
      if (!file.type.startsWith("image/")) return

      const reader = new FileReader()
      reader.onload = (e) => {
        const img = document.createElement("img")
        img.src = e.target.result
        img.className = "w-20 h-20 object-cover rounded-md"
        container.appendChild(img)
      }
      reader.readAsDataURL(file)
    })
  }
}
