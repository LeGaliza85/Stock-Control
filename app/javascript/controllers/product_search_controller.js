import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "iaModal",
    "iaImagePreview",
    "iaLoading",
    "iaResults",
    "iaError",
    "iaErrorMsg",
    "iaConfianza",
    "iaConfianzaBar",
    "iaDescripcion",
    "iaTipoProducto",
    "iaCategoriaSugerida",
    "iaMarcaModelo",
    "iaEstado",
    "iaErrores",
    "searchModal",
    "searchPreview",
    "searchLoading",
    "searchResults",
    "searchResultsList",
    "searchNoResults",
    "searchError",
    "searchErrorMsg",
    "searchOptions",
    "searchGaleria",
    "searchCamara",
    "searchFileInput"
  ]

  static values = {
    searchUrl: { type: String, default: "/productos/buscar_por_imagen" },
    analyzeUrl: { type: String, default: "/ia/analyze" },
    newProductoUrl: { type: String, default: "/productos/new" }
  }

  connect() {
    this._currentImageData = null
    this._currentAnalysis = null
    this._currentSearchImage = null
    this._csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || ""

    this._bindIaButtons()
    this._bindSearchButtons()
    this._bindFloatingButtons()
    this._bindKeyboard()
  }

  disconnect() {
    this._unbindAll()
  }

  openIaModal(event) {
    if (event) event.preventDefault()
    const fileInput = document.getElementById("iaCameraInputIndex")
    if (fileInput) fileInput.click()
  }

  openSearchModal(event) {
    if (event) event.preventDefault()
    this._resetSearchModal()
    this.searchModalTarget.classList.remove("hidden")
    this.searchModalTarget.classList.add("flex")
  }

  closeSearchModal() {
    this.searchModalTarget.classList.add("hidden")
    this.searchModalTarget.classList.remove("flex")
    if (this.hasSearchFileInputTarget) this.searchFileInputTarget.value = ""
    this._currentSearchImage = null
  }

  closeIaModal() {
    this.iaModalTarget.classList.add("hidden")
    this.iaModalTarget.classList.remove("flex")
    const fileInput = document.getElementById("iaCameraInputIndex")
    if (fileInput) fileInput.value = ""
  }

  onSearchGaleriaChange(event) {
    if (event.target.files && event.target.files[0]) {
      this.searchOptionsTarget.classList.add("hidden")
      this._handleSearchFile(event.target.files[0])
    }
  }

  onSearchCamaraChange(event) {
    if (event.target.files && event.target.files[0]) {
      this.searchOptionsTarget.classList.add("hidden")
      this._handleSearchFile(event.target.files[0])
    }
  }

  retrySearch(event) {
    if (event) event.preventDefault()
    if (this._currentSearchImage) this._buscarEnStock(this._currentSearchImage)
  }

  retryIa(event) {
    if (event) event.preventDefault()
    this._analyzeImage()
  }

  resetSearch(event) {
    if (event) event.preventDefault()
    this._resetSearchModal()
    this._showSearchPlaceholder()
    this._currentSearchImage = null
  }

  createProductFromIa(event) {
    if (!this._currentAnalysis) return

    const descripcion = this.iaDescripcionTarget.value
    const nombre = this.iaMarcaModeloTarget.value || this.iaTipoProductoTarget.value
    const estado = this.iaEstadoTarget.value

    const params = new URLSearchParams()
    if (nombre) params.set("nombre", nombre)
    if (descripcion) params.set("descripcion", descripcion)
    if (estado) params.set("estado", estado)
    params.set("from_ia", "1")

    if (this._currentImageData) {
      if (this._currentImageData.length > 50000) {
        const imageKey = "ia_image_" + Date.now()
        sessionStorage.setItem(imageKey, this._currentImageData)
        params.set("ia_image_key", imageKey)
      } else {
        params.set("ia_image_data", this._currentImageData)
      }
    }

    window.location.href = this.newProductoUrlValue + "?" + params.toString()
  }

  _resetSearchModal() {
    this.searchPreviewTarget.classList.remove("hidden")
    this.searchLoadingTarget.classList.add("hidden")
    this.searchResultsTarget.classList.add("hidden")
    this.searchNoResultsTarget.classList.add("hidden")
    this.searchErrorTarget.classList.add("hidden")
    this.searchOptionsTarget.classList.remove("hidden")
    if (this.hasSearchGaleriaTarget) this.searchGaleriaTarget.value = ""
    if (this.hasSearchCamaraTarget) this.searchCamaraTarget.value = ""
  }

  _resetIaModal() {
    this.iaLoadingTarget.classList.add("hidden")
    this.iaResultsTarget.classList.add("hidden")
    this.iaErrorTarget.classList.add("hidden")
    this.iaErrorMsgTarget.textContent = "Error al analizar la imagen"
  }

  _showSearchPlaceholder() {
    this.searchPreviewTarget.innerHTML = `
      <div class="text-center py-8">
        <svg class="w-12 h-12 mx-auto text-[#E8E0D4] mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
        </svg>
        <p class="text-[#9C8B7A] text-sm">Selecciona una opción arriba</p>
      </div>`
  }

  _fileToBase64(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.onload = () => resolve(reader.result)
      reader.onerror = reject
      reader.readAsDataURL(file)
    })
  }

  _handleSearchFile(file) {
    if (!file) return
    this._currentSearchImage = file
    this._fileToBase64(file).then((base64) => {
      this._currentSearchImage = base64
      this.searchPreviewTarget.innerHTML =
        '<img src="' + base64 + '" class="max-h-48 mx-auto rounded-lg object-contain">'
      this._buscarEnStock(base64)
    })
  }

  _buscarEnStock(imageData) {
    this.searchPreviewTarget.classList.add("hidden")
    this.searchLoadingTarget.classList.remove("hidden")
    this.searchResultsTarget.classList.add("hidden")
    this.searchNoResultsTarget.classList.add("hidden")
    this.searchErrorTarget.classList.add("hidden")

    const formData = new FormData()
    formData.append("imagen", imageData)

    fetch(this.searchUrlValue, {
      method: "POST",
      headers: { "X-CSRF-Token": this._csrfToken },
      body: formData
    })
      .then((response) => response.json())
      .then((data) => {
        this.searchLoadingTarget.classList.add("hidden")

        if (data.error) {
          this.searchErrorTarget.classList.remove("hidden")
          this.searchErrorMsgTarget.textContent = data.error
        } else if (data.productos && data.productos.length > 0) {
          this._mostrarResultados(data.productos)
        } else {
          this.searchNoResultsTarget.classList.remove("hidden")
        }
      })
      .catch((error) => {
        this.searchLoadingTarget.classList.add("hidden")
        this.searchErrorTarget.classList.remove("hidden")
        this.searchErrorMsgTarget.textContent = "Error de conexión: " + error.message
      })
  }

  _mostrarResultados(productos) {
    this.searchResultsTarget.classList.remove("hidden")
    this.searchResultsListTarget.innerHTML = ""

    productos.forEach((p) => {
      const fotoHtml = p.fotos
        ? '<img src="' + p.fotos + '" class="w-16 h-16 object-cover rounded-lg">'
        : '<div class="w-16 h-16 bg-[#FAF7F2] rounded-lg flex items-center justify-center"><svg class="w-6 h-6 text-[#E8E0D4]" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg></div>'

      const etiquetaColors = {
        en_venta: "bg-green-500",
        reservado: "bg-amber-500",
        vendido: "bg-red-500",
        en_restauracion: "bg-purple-500"
      }
      const etiquetaLabels = {
        en_venta: "EN VENTA",
        reservado: "RESERVADO",
        vendido: "VENDIDO",
        en_restauracion: "EN RESTAURACIÓN"
      }
      const color = etiquetaColors[p.etiqueta] || "bg-gray-500"
      const label = etiquetaLabels[p.etiqueta] || p.etiqueta
      const similitudHtml = p.similitud
        ? '<span class="text-xs font-bold text-white px-2 py-0.5 rounded bg-blue-600">' + p.similitud + "%</span>"
        : ""

      const item = document.createElement("a")
      item.href = "/productos/" + p.id
      item.className = "flex items-center gap-3 p-3 rounded-lg border border-[#E8E0D4] hover:bg-[#FAF7F2] transition-colors"
      item.innerHTML =
        fotoHtml +
        '<div class="flex-1 min-w-0">' +
          '<div class="flex items-center gap-2">' +
            '<span class="text-xs font-bold text-white px-1.5 py-0.5 rounded ' + color + '">' + label + "</span>" +
            similitudHtml +
          "</div>" +
          '<p class="font-medium text-[#2C1810] truncate">' + (p.nombre || "Sin nombre") + "</p>" +
          '<p class="text-sm text-[#B8860B] font-semibold">' + this._formatoPrecio(p.precio_venta) + "</p>" +
        "</div>"
      this.searchResultsListTarget.appendChild(item)
    })
  }

  _formatoPrecio(valor) {
    if (!valor) return "0,00 \u20AC"
    return parseFloat(valor).toFixed(2).replace(".", ",") + " \u20AC"
  }

  _openIaModalWithImage(imageSrc) {
    this._currentImageData = imageSrc
    this._resetIaModal()
    this.iaModalTarget.classList.remove("hidden")
    this.iaModalTarget.classList.add("flex")

    if (typeof imageSrc === "object" && imageSrc.type) {
      this._fileToBase64(imageSrc).then((base64) => {
        this._currentImageData = base64
        this.iaImagePreviewTarget.innerHTML =
          '<img src="' + base64 + '" class="max-h-48 mx-auto rounded-lg">'
        this._analyzeImage()
      })
    } else {
      this.iaImagePreviewTarget.innerHTML =
        '<img src="' + imageSrc + '" class="max-h-48 mx-auto rounded-lg">'
      this._analyzeImage()
    }
  }

  _analyzeImage() {
    this.iaLoadingTarget.classList.remove("hidden")
    this.iaResultsTarget.classList.add("hidden")
    this.iaErrorTarget.classList.add("hidden")

    const formData = new FormData()
    formData.append("image_data", this._currentImageData)

    fetch(this.analyzeUrlValue, {
      method: "POST",
      headers: { "X-CSRF-Token": this._csrfToken },
      body: formData
    })
      .then((response) => response.json())
      .then((data) => {
        this.iaLoadingTarget.classList.add("hidden")
        if (data.error) {
          this._showIaError(data.error, data.necesita_config === true)
        } else {
          this._showIaResults(data)
        }
      })
      .catch((error) => {
        this.iaLoadingTarget.classList.add("hidden")
        this._showIaError("Error de conexión: " + error.message, false)
      })
  }

  _showIaError(message, necesitaConfig) {
    this.iaErrorTarget.classList.remove("hidden")
    if (necesitaConfig) {
      this.iaErrorMsgTarget.innerHTML =
        message +
        '<br><br><a href="/config_ia" class="inline-block mt-2 text-[#B8860B] hover:underline font-medium">Ir a configurar API Key \u2192</a>'
    } else {
      this.iaErrorMsgTarget.textContent = message
    }
  }

  _showIaResults(data) {
    this.iaResultsTarget.classList.remove("hidden")
    this._currentAnalysis = data

    const confianza = data.confianza || 0
    this.iaConfianzaTarget.textContent = confianza + "%"
    this.iaConfianzaBarTarget.style.width = confianza + "%"

    if (confianza >= 80) {
      this.iaConfianzaBarTarget.className = "bg-[#3D5E3D] h-2 rounded-full transition-all duration-500"
    } else if (confianza >= 50) {
      this.iaConfianzaBarTarget.className = "bg-[#B8860B] h-2 rounded-full transition-all duration-500"
    } else {
      this.iaConfianzaBarTarget.className = "bg-[#A63D2F] h-2 rounded-full transition-all duration-500"
    }

    this.iaDescripcionTarget.value = data.descripcion || ""
    this.iaTipoProductoTarget.value = data.tipo_producto || ""
    this.iaCategoriaSugeridaTarget.value = data.categoria_sugerida || ""
    this.iaMarcaModeloTarget.value = data.marca_modelo || ""

    if (data.estado) {
      for (let i = 0; i < this.iaEstadoTarget.options.length; i++) {
        if (this.iaEstadoTarget.options[i].value === data.estado) {
          this.iaEstadoTarget.selectedIndex = i
          break
        }
      }
    }

    if (data.errores && data.errores.length > 0) {
      this.iaErroresTarget.classList.remove("hidden")
      this.iaErroresTarget.innerHTML = "<strong>Notas:</strong> " + data.errores.join(", ")
    } else {
      this.iaErroresTarget.classList.add("hidden")
    }
  }

  _bindIaButtons() {
    const btnAnalizar = document.getElementById("btnAnalizarIAIndex")
    const iaCameraInput = document.getElementById("iaCameraInputIndex")
    const btnCloseIa = document.getElementById("closeIaModalIndex")
    const btnCancelIa = document.getElementById("btnCancelarIAIndex")
    const btnCrearProducto = document.getElementById("btnCrearProductoIAIndex")
    const btnRetryIa = document.getElementById("btnRetryIAIndex")

    this._iaHandlers = []

    if (btnAnalizar && iaCameraInput) {
      const handler = (e) => {
        e.preventDefault()
        e.stopPropagation()
        iaCameraInput.click()
      }
      btnAnalizar.addEventListener("click", handler)
      this._iaHandlers.push({ el: btnAnalizar, type: "click", handler })
    }

    if (iaCameraInput) {
      const handler = (e) => {
        if (e.target.files && e.target.files[0]) {
          this._openIaModalWithImage(e.target.files[0])
        }
      }
      iaCameraInput.addEventListener("change", handler)
      this._iaHandlers.push({ el: iaCameraInput, type: "change", handler })
    }

    if (btnCloseIa) {
      const handler = () => this.closeIaModal()
      btnCloseIa.addEventListener("click", handler)
      this._iaHandlers.push({ el: btnCloseIa, type: "click", handler })
    }

    if (btnCancelIa) {
      const handler = () => this.closeIaModal()
      btnCancelIa.addEventListener("click", handler)
      this._iaHandlers.push({ el: btnCancelIa, type: "click", handler })
    }

    if (btnCrearProducto) {
      const handler = () => this.createProductFromIa()
      btnCrearProducto.addEventListener("click", handler)
      this._iaHandlers.push({ el: btnCrearProducto, type: "click", handler })
    }

    if (btnRetryIa) {
      const handler = (e) => this.retryIa(e)
      btnRetryIa.addEventListener("click", handler)
      this._iaHandlers.push({ el: btnRetryIa, type: "click", handler })
    }
  }

  _bindSearchButtons() {
    const btnBuscar = document.getElementById("btnBuscarEnStock")
    const btnClose = document.getElementById("closeBuscarStockModal")
    const btnNueva = document.getElementById("btnNuevaBuscarStock")
    const btnRetry = document.getElementById("btnRetryBuscarStock")

    this._searchHandlers = []

    if (btnBuscar) {
      const handler = (e) => {
        e.preventDefault()
        this.openSearchModal()
      }
      btnBuscar.addEventListener("click", handler)
      this._searchHandlers.push({ el: btnBuscar, type: "click", handler })
    }

    if (btnClose) {
      const handler = () => this.closeSearchModal()
      btnClose.addEventListener("click", handler)
      this._searchHandlers.push({ el: btnClose, type: "click", handler })
    }

    if (btnNueva) {
      const handler = (e) => this.resetSearch(e)
      btnNueva.addEventListener("click", handler)
      this._searchHandlers.push({ el: btnNueva, type: "click", handler })
    }

    if (btnRetry) {
      const handler = (e) => this.retrySearch(e)
      btnRetry.addEventListener("click", handler)
      this._searchHandlers.push({ el: btnRetry, type: "click", handler })
    }

    if (this.hasSearchGaleriaTarget) {
      const handler = (e) => this.onSearchGaleriaChange(e)
      this.searchGaleriaTarget.addEventListener("change", handler)
      this._searchHandlers.push({ el: this.searchGaleriaTarget, type: "change", handler })
    }

    if (this.hasSearchCamaraTarget) {
      const handler = (e) => this.onSearchCamaraChange(e)
      this.searchCamaraTarget.addEventListener("change", handler)
      this._searchHandlers.push({ el: this.searchCamaraTarget, type: "change", handler })
    }
  }

  _bindFloatingButtons() {
    const btnBuscarFloating = document.getElementById("btnBuscarEnStockFloating")
    const btnAnalizarFloating = document.getElementById("btnAnalizarIAFloating")

    this._floatingHandlers = []

    if (btnBuscarFloating) {
      const handler = (e) => {
        e.preventDefault()
        this.openSearchModal()
        const galeria = this.hasSearchCamaraTarget ? this.searchCamaraTarget : null
        const camara = galeria || (this.hasSearchGaleriaTarget ? this.searchGaleriaTarget : null)
        if (camara) {
          setTimeout(() => camara.click(), 300)
        }
      }
      btnBuscarFloating.addEventListener("click", handler)
      this._floatingHandlers.push({ el: btnBuscarFloating, type: "click", handler })
    }

    if (btnAnalizarFloating) {
      const handler = (e) => {
        e.preventDefault()
        this.openIaModal(e)
      }
      btnAnalizarFloating.addEventListener("click", handler)
      this._floatingHandlers.push({ el: btnAnalizarFloating, type: "click", handler })
    }
  }

  _bindKeyboard() {
    this._escHandler = (e) => {
      if (e.key !== "Escape") return

      if (!this.iaModalTarget.classList.contains("hidden")) {
        this.closeIaModal()
      } else if (!this.searchModalTarget.classList.contains("hidden")) {
        this.closeSearchModal()
      }
    }
    document.addEventListener("keydown", this._escHandler)

    this._iaBackdropHandler = (e) => {
      if (e.target === this.iaModalTarget) this.closeIaModal()
    }
    this.iaModalTarget.addEventListener("click", this._iaBackdropHandler)

    this._searchBackdropHandler = (e) => {
      if (e.target === this.searchModalTarget) this.closeSearchModal()
    }
    this.searchModalTarget.addEventListener("click", this._searchBackdropHandler)
  }

  _unbindAll() {
    const allHandlers = [
      ...(this._iaHandlers || []),
      ...(this._searchHandlers || []),
      ...(this._floatingHandlers || [])
    ]
    allHandlers.forEach(({ el, type, handler }) => {
      el.removeEventListener(type, handler)
    })

    if (this._escHandler) document.removeEventListener("keydown", this._escHandler)
    if (this._iaBackdropHandler) this.iaModalTarget.removeEventListener("click", this._iaBackdropHandler)
    if (this._searchBackdropHandler) this.searchModalTarget.removeEventListener("click", this._searchBackdropHandler)
  }
}
