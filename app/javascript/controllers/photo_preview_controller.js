import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preview", "counter"]

  connect() {
    this.selectedFiles = []
  }

  preview(event) {
    const container = this.previewTarget
    const files = event.target.files
    if (!files.length) return

    Array.from(files).forEach((file) => {
      if (!file.type.startsWith("image/")) return
      this.selectedFiles.push(file)

      const reader = new FileReader()
      reader.onload = (e) => {
        const wrapper = document.createElement("div")
        wrapper.className = "relative group"

        const img = document.createElement("img")
        img.src = e.target.result
        img.className = "w-20 h-20 object-cover rounded-lg border-2 border-[#B8860B]"

        const removeBtn = document.createElement("button")
        removeBtn.type = "button"
        removeBtn.innerHTML = "&times;"
        removeBtn.className = "absolute -top-2 -right-2 w-5 h-5 rounded-full bg-[#A63D2F] text-white text-xs flex items-center justify-center cursor-pointer opacity-0 group-hover:opacity-100 transition-opacity"
        removeBtn.onclick = () => {
          wrapper.remove()
          const idx = this.selectedFiles.indexOf(file)
          if (idx > -1) this.selectedFiles.splice(idx, 1)
          this._updateFileInput()
          this._updateCounter()
        }

        wrapper.appendChild(img)
        wrapper.appendChild(removeBtn)
        container.appendChild(wrapper)
      }
      reader.readAsDataURL(file)
    })

    this._updateCounter()
  }

  _updateFileInput() {
    const dt = new DataTransfer()
    this.selectedFiles.forEach(f => dt.items.add(f))
    const input = this.element.querySelector("input[type=file]")
    if (input) input.files = dt.files
  }

  _updateCounter() {
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = this.selectedFiles.length + " foto(s) seleccionada(s)"
      this.counterTarget.classList.toggle("hidden", this.selectedFiles.length === 0)
    }
  }
}
