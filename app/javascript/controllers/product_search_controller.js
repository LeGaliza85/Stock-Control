import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "iaModal", "iaImagePreview", "iaLoading", "iaResults", "iaError", "iaErrorMsg",
    "iaConfianza", "iaConfianzaBar", "iaDescripcion", "iaTipoProducto", 
    "iaCategoriaSugerida", "iaMarcaModelo", "iaEstado", "iaErrores", "iaFileInput",
    "searchModal", "searchForm", "searchOptions", "searchPreview", "searchLoading", "searchResults"
  ]

  static values = {
    analyzeUrl: { type: String, default: "/ia/analyze" },
    newProductoUrl: { type: String, default: "/productos/new" }
  }

  connect() {
    this._csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || ""
  }

  // --- SEARCH IN STOCK (Turbo powered) ---

  openSearchModal(event) {
    event?.preventDefault()
    this._resetSearchModal()
    if (this.hasSearchModalTarget) {
      this.searchModalTarget.classList.replace("hidden", "flex")
      document.body.style.overflow = "hidden"
    }
  }

  closeSearchModal(event) {
    event?.preventDefault()
    if (this.hasSearchModalTarget) {
      this.searchModalTarget.classList.replace("flex", "hidden")
      document.body.style.overflow = ""
    }
  }

  onSearchFileChange(event) {
    const file = event.target.files?.[0]
    if (!file) return

    // Show local preview immediately
    const reader = new FileReader()
    reader.onload = (e) => {
      if (this.hasSearchPreviewTarget) {
        this.searchPreviewTarget.innerHTML = `<img src="${e.target.result}" class="max-h-48 mx-auto rounded-lg object-contain">`
      }
    }
    reader.readAsDataURL(file)

    // UI state
    if (this.hasSearchOptionsTarget) this.searchOptionsTarget.classList.add("hidden")
    if (this.hasSearchLoadingTarget) this.searchLoadingTarget.classList.remove("hidden")
    if (this.hasSearchResultsTarget) this.searchResultsTarget.innerHTML = ""

    // Submit form via Turbo
    if (this.hasSearchFormTarget) {
      this.searchFormTarget.requestSubmit()
    }
  }

  resetSearch(event) {
    event?.preventDefault()
    this._resetSearchModal()
  }

  // --- IA ANALYSIS (JSON powered) ---

  openIaModal(event) {
    event?.preventDefault()
    if (this.hasIaFileInputTarget) this.iaFileInputTarget.click()
  }

  onIaFileChange(event) {
    const file = event.target.files?.[0]
    if (!file) return

    this._resetIaModal()
    if (this.hasIaModalTarget) {
      this.iaModalTarget.classList.replace("hidden", "flex")
      document.body.style.overflow = "hidden"
    }

    const reader = new FileReader()
    reader.onload = (e) => {
      this._currentImageData = e.target.result
      if (this.hasIaImagePreviewTarget) {
        this.iaImagePreviewTarget.innerHTML = `<img src="${this._currentImageData}" class="max-h-48 mx-auto rounded-lg object-contain">`
      }
      this._analyzeImage()
    }
    reader.readAsDataURL(file)
  }

  closeIaModal(event) {
    event?.preventDefault()
    if (this.hasIaModalTarget) {
      this.iaModalTarget.classList.replace("flex", "hidden")
      document.body.style.overflow = ""
    }
  }

  retryIa(event) {
    event?.preventDefault()
    if (this._currentImageData) this._analyzeImage()
  }

  fillForm() {
    if (!this._currentAnalysis) return

    const selectors = {
      'input[name="producto[nombre]"]': this._buildIaName(),
      'textarea[name="producto[descripcion]"]': this._currentAnalysis.descripcion,
      'select[name="producto[estado]"]': this._currentAnalysis.estado
    }

    for (const [selector, value] of Object.entries(selectors)) {
      const el = document.querySelector(selector)
      if (el && value) {
        if (selector.includes("nombre") && el.value !== "") continue
        el.value = value
      }
    }

    // Special handling for category
    if (this._currentAnalysis.categoria_sugerida) {
      const catSelect = document.querySelector('select[name="producto[categoria_id]"]')
      if (catSelect) {
        const option = Array.from(catSelect.options).find(o => 
          o.text.toLowerCase().includes(this._currentAnalysis.categoria_sugerida.toLowerCase())
        )
        if (option) catSelect.selectedIndex = option.index
      }
    }

    this.closeIaModal()
  }

  createProductFromIa() {
    if (!this._currentAnalysis) return

    const params = new URLSearchParams({
      from_ia: "1",
      nombre: this.hasIaMarcaModeloTarget ? this.iaMarcaModeloTarget.value || this.iaTipoProductoTarget.value : "",
      descripcion: this.hasIaDescripcionTarget ? this.iaDescripcionTarget.value : "",
      estado: this.hasIaEstadoTarget ? this.iaEstadoTarget.value : ""
    })

    if (this._currentImageData) {
      if (this._currentImageData.length > 50000) {
        const key = `ia_image_${Date.now()}`
        sessionStorage.setItem(key, this._currentImageData)
        params.set("ia_image_key", key)
      } else {
        params.set("ia_image_data", this._currentImageData)
      }
    }

    window.location.href = `${this.newProductoUrlValue}?${params}`
  }

  // --- Utilities ---

  closeOnBackdrop(e) {
    if (this.hasIaModalTarget && e.target === this.iaModalTarget) this.closeIaModal()
    if (this.hasSearchModalTarget && e.target === this.searchModalTarget) this.closeSearchModal()
  }

  _resetSearchModal() {
    if (this.hasSearchOptionsTarget) this.searchOptionsTarget.classList.remove("hidden")
    if (this.hasSearchLoadingTarget) this.searchLoadingTarget.classList.add("hidden")
    if (this.hasSearchResultsTarget) this.searchResultsTarget.innerHTML = ""
    if (this.hasSearchPreviewTarget) {
      this.searchPreviewTarget.innerHTML = `
        <div class="text-center py-8">
          <svg class="w-12 h-12 mx-auto text-[#E8E0D4] mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
          </svg>
          <p class="text-[#9C8B7A] text-sm">Selecciona una opción arriba</p>
        </div>`
    }
    // Clear inputs
    this.element.querySelectorAll('input[type="file"]').forEach(i => i.value = "")
  }

  _resetIaModal() {
    if (this.hasIaLoadingTarget) this.iaLoadingTarget.classList.add("hidden")
    if (this.hasIaResultsTarget) this.iaResultsTarget.classList.add("hidden")
    if (this.hasIaErrorTarget) this.iaErrorTarget.classList.add("hidden")
  }

  _analyzeImage() {
    if (this.hasIaLoadingTarget) this.iaLoadingTarget.classList.remove("hidden")
    if (this.hasIaResultsTarget) this.iaResultsTarget.classList.add("hidden")
    if (this.hasIaErrorTarget) this.iaErrorTarget.classList.add("hidden")

    const formData = new FormData()
    formData.append("image_data", this._currentImageData)

    fetch(this.analyzeUrlValue, {
      method: "POST",
      headers: { "X-CSRF-Token": this._csrfToken },
      body: formData
    })
      .then(r => r.json())
      .then(data => {
        if (this.hasIaLoadingTarget) this.iaLoadingTarget.classList.add("hidden")
        if (data.error) {
          this._showIaError(data.error, data.necesita_config)
        } else {
          this._showIaResults(data)
        }
      })
      .catch(err => {
        if (this.hasIaLoadingTarget) this.iaLoadingTarget.classList.add("hidden")
        this._showIaError(`Error de conexión: ${err.message}`, false)
      })
  }

  _showIaError(msg, needsConfig) {
    if (this.hasIaErrorTarget) this.iaErrorTarget.classList.remove("hidden")
    if (this.hasIaErrorMsgTarget) {
      this.iaErrorMsgTarget.innerHTML = needsConfig 
        ? `${msg}<br><br><a href="/config_ia" class="text-[#B8860B] hover:underline">Configurar API Key &rarr;</a>`
        : msg
    }
  }

  _showIaResults(data) {
    this._currentAnalysis = data
    if (this.hasIaResultsTarget) this.iaResultsTarget.classList.remove("hidden")

    if (this.hasIaConfianzaTarget) this.iaConfianzaTarget.textContent = `${data.confianza || 0}%`
    if (this.hasIaConfianzaBarTarget) {
      this.iaConfianzaBarTarget.style.width = `${data.confianza || 0}%`
    }

    if (this.hasIaDescripcionTarget) this.iaDescripcionTarget.value = data.descripcion || ""
    if (this.hasIaTipoProductoTarget) this.iaTipoProductoTarget.value = data.tipo_producto || ""
    if (this.hasIaCategoriaSugeridaTarget) this.iaCategoriaSugeridaTarget.value = data.categoria_sugerida || ""
    if (this.hasIaMarcaModeloTarget) this.iaMarcaModeloTarget.value = data.marca_modelo || ""
    
    if (this.hasIaEstadoTarget && data.estado) {
      this.iaEstadoTarget.value = data.estado
    }
  }

  _buildIaName() {
    if (this._currentAnalysis.palabras_clave?.length > 0) {
      return this._currentAnalysis.palabras_clave.slice(0, 4).join(" - ")
    }
    return this._currentAnalysis.tipo_producto || ""
  }
}
