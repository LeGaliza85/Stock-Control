import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "input", "error", "select"]

  open() {
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")
    this.inputTarget.focus()
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.modalTarget.classList.remove("flex")
    this.errorTarget.classList.add("hidden")
    this.inputTarget.value = ""
  }

  submit(e) {
    e.preventDefault()
    const nombre = this.inputTarget.value.trim()
    if (!nombre) return

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    fetch('/categorias/quick_create', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': csrfToken
      },
      body: 'categoria[nombre]=' + encodeURIComponent(nombre)
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        const option = document.createElement('option')
        option.value = data.categoria.id
        option.text = data.categoria.nombre
        option.selected = true
        this.selectTarget.appendChild(option)
        this.close()
      } else {
        this.errorTarget.textContent = data.errors ? data.errors.join(', ') : 'Error al crear la categoría'
        this.errorTarget.classList.remove('hidden')
      }
    })
    .catch(err => {
      this.errorTarget.textContent = 'Error de red: ' + err.message
      this.errorTarget.classList.remove('hidden')
    })
  }
}
