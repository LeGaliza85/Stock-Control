import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["preview", "counter", "fotosAEliminar"];

  connect() {
    this.selectedFiles = [];
  }

  openCamera(event) {
    event.preventDefault();
    const container = document.getElementById('cameraInputContainer');
    if (!container) return;
    
    container.innerHTML = '';
    const newInput = document.createElement('input');
    newInput.type = 'file';
    newInput.name = 'producto[fotos][]';
    newInput.id = 'cameraInput';
    newInput.accept = 'image/*';
    newInput.setAttribute('capture', 'environment');
    newInput.multiple = true;
    newInput.className = 'hidden';
    newInput.dataset.action = 'change->photo-preview#preview';
    
    container.appendChild(newInput);
    newInput.click();
  }

  openGallery(event) {
    event.preventDefault();
    document.getElementById('fotosInput').click();
  }

  preview(event) {
    const container = this.previewTarget;
    const input = event.target;
    const files = input.files;
    const inputId = input.id;
    if (!files.length) return;

    Array.from(files).forEach((file) => {
      if (!file.type.startsWith("image/")) return;
      this.selectedFiles.push(file);

      const reader = new FileReader();
      reader.onload = (e) => {
        const wrapper = document.createElement("div");
        wrapper.className = "relative group mb-2";

        const img = document.createElement("img");
        img.src = e.target.result;
        img.className = "w-20 h-20 object-cover rounded-lg border-2 border-[#B8860B]";
        img.alt = file.name;

        const removeBtn = document.createElement("button");
        removeBtn.type = "button";
        removeBtn.innerHTML = "&times;";
        removeBtn.className = "absolute -top-2 -right-2 w-6 h-6 rounded-full bg-[#A63D2F] text-white text-lg flex items-center justify-center cursor-pointer shadow-md hover:bg-red-600";
        removeBtn.title = "Eliminar foto";
        removeBtn.onclick = (e) => {
          e.preventDefault();
          wrapper.remove();
          const idx = this.selectedFiles.indexOf(file);
          if (idx > -1) this.selectedFiles.splice(idx, 1);
          this._updateFileInputFromSelected(inputId);
          this._updateCounter();
        };

        wrapper.appendChild(img);
        wrapper.appendChild(removeBtn);
        container.appendChild(wrapper);
      };
      reader.readAsDataURL(file);
    });

    this._updateFileInputFromSelected(inputId);
    this._updateCounter();
    input.value = '';
  }

  eliminarFotoExistente(e) {
    const fotoId = e.currentTarget.dataset.fotoId;
    const container = e.currentTarget.closest('.foto-item');
    const btnEliminar = container.querySelector('.btn-eliminar');
    const btnCancelar = container.querySelector('.btn-cancelar');
    const marca = container.querySelector('.foto-marcada');

    let ids = this.fotosAEliminarTarget.value ? this.fotosAEliminarTarget.value.split(',') : [];
    if (!ids.includes(fotoId)) {
      ids.push(fotoId);
    }
    this.fotosAEliminarTarget.value = ids.join(',');

    container.classList.add('border-red-500', 'border-2');
    btnEliminar.classList.add('hidden');
    btnCancelar.classList.remove('hidden');
    marca.classList.remove('hidden');
  }

  cancelarEliminarFotoExistente(e) {
    const fotoId = e.currentTarget.dataset.fotoId;
    const container = e.currentTarget.closest('.foto-item');
    const btnEliminar = container.querySelector('.btn-eliminar');
    const btnCancelar = container.querySelector('.btn-cancelar');
    const marca = container.querySelector('.foto-marcada');

    let ids = this.fotosAEliminarTarget.value ? this.fotosAEliminarTarget.value.split(',') : [];
    ids = ids.filter(id => id !== fotoId);
    this.fotosAEliminarTarget.value = ids.join(',');

    container.classList.remove('border-red-500', 'border-2');
    btnEliminar.classList.remove('hidden');
    btnCancelar.classList.add('hidden');
    marca.classList.add('hidden');
  }

  _updateFileInputFromSelected(inputId) {
    const dt = new DataTransfer();
    this.selectedFiles.forEach((f) => dt.items.add(f));
    this._replaceInputFiles(dt.files, inputId);
  }

  _replaceInputFiles(files, targetInputId) {
    const input = document.getElementById(targetInputId) || this.element.querySelector("input[name='producto[fotos][]']");
    if (!input) return;

    const newInput = document.createElement('input');
    newInput.type = 'file';
    newInput.name = input.name;
    newInput.id = input.id;
    newInput.accept = input.accept;
    newInput.multiple = input.multiple;
    if (input.hasAttribute('capture')) newInput.setAttribute('capture', input.getAttribute('capture'));
    newInput.className = input.className;
    newInput.files = files;
    
    for (const attr of input.attributes) {
      if (attr.name.startsWith('data-')) {
        newInput.setAttribute(attr.name, attr.value);
      }
    }
    
    input.parentNode.replaceChild(newInput, input);
  }

  _updateCounter() {
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = this.selectedFiles.length + " foto(s) seleccionada(s)";
      this.counterTarget.classList.toggle("hidden", this.selectedFiles.length === 0);
    }
  }
}
