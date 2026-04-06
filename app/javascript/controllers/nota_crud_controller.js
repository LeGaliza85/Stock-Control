import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "editForm", "deleteModal", "deletePreview", "confirmDeleteBtn"]

  toggleEdit(e) {
    const id = e.currentTarget.dataset.id
    const content = this.contentTargets.find(el => el.dataset.id === id)
    const form = this.editFormTargets.find(el => el.dataset.id === id)
    
    if (content && form) {
      content.classList.toggle("hidden")
      form.classList.toggle("hidden")
    }
  }

  confirmDelete(e) {
    const id = e.currentTarget.dataset.id
    const preview = e.currentTarget.dataset.preview
    const url = e.currentTarget.dataset.url

    this.deletePreviewTarget.textContent = preview + (preview.length >= 50 ? "..." : "")
    this._deleteUrl = url

    this.deleteModalTarget.classList.remove("hidden")
    this.deleteModalTarget.classList.add("flex")
    document.body.style.overflow = "hidden"
  }

  closeDeleteModal() {
    this.deleteModalTarget.classList.add("hidden")
    this.deleteModalTarget.classList.remove("flex")
    document.body.style.overflow = ""
  }

  executeDelete() {
    if (!this._deleteUrl) return

    const form = document.createElement("form")
    form.method = "POST"
    form.action = this._deleteUrl

    const methodInput = document.createElement("input")
    methodInput.type = "hidden"
    methodInput.name = "_method"
    methodInput.value = "delete"
    form.appendChild(methodInput)

    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    const csrfInput = document.createElement("input")
    csrfInput.type = "hidden"
    csrfInput.name = "authenticity_token"
    csrfInput.value = csrfToken
    form.appendChild(csrfInput)

    document.body.appendChild(form)
    form.submit()
  }
}
