import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["video", "canvas", "modal", "fileInput", "preview"]

  open() {
    this.photos = this.photos || []
    this.modalTarget.classList.remove("hidden")

    navigator.mediaDevices
      .getUserMedia({ video: { facingMode: "environment", width: { ideal: 1280 }, height: { ideal: 960 } } })
      .then((stream) => {
        this.stream = stream
        this.videoTarget.srcObject = stream
        this.videoTarget.play()
      })
      .catch(() => {
        this.close()
        this.fileInputTarget.click()
      })
  }

  capture() {
    const video = this.videoTarget
    const canvas = this.canvasTarget
    canvas.width = video.videoWidth
    canvas.height = video.videoHeight
    canvas.getContext("2d").drawImage(video, 0, 0)

    canvas.toBlob((blob) => {
      const file = new File([blob], `foto_${Date.now()}.jpg`, { type: "image/jpeg" })
      this.photos.push(file)
      this._updateFileInput()
      this._addThumbnail(blob)
    }, "image/jpeg", 0.85)
  }

  close() {
    if (this.stream) {
      this.stream.getTracks().forEach((t) => t.stop())
      this.stream = null
    }
    this.modalTarget.classList.add("hidden")
  }

  _updateFileInput() {
    const dt = new DataTransfer()
    this.photos.forEach((f) => dt.items.add(f))
    this.fileInputTarget.files = dt.files
    this.fileInputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  _addThumbnail(blob) {
    const img = document.createElement("img")
    img.src = URL.createObjectURL(blob)
    img.className = "w-16 h-16 object-cover rounded-lg border-2 border-[#B8860B]"
    this.previewTarget.appendChild(img)
  }
}
