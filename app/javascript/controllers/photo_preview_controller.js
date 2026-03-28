import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["preview", "counter"];

  connect() {
    console.log("photo-preview controller connected");
    this.selectedFiles = [];
    this._setupExistingFotos();
  }

  openCamera(event) {
    event.preventDefault();
    console.log('openCamera called');
    
    // Create a fresh input element each time
    const container = document.getElementById('cameraInputContainer');
    if (!container) {
      console.error('Camera input container not found');
      return;
    }
    
    // Remove old input and create new one
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
    
    // Trigger click on the new input
    newInput.click();
    console.log('Camera input clicked');
  }

  _setupExistingFotos() {
    const checkboxes = this.element.querySelectorAll(".foto-checkbox");
    checkboxes.forEach((checkbox) => {
      checkbox.addEventListener("change", (e) => this._toggleExistingFoto(e));
    });
  }

  _toggleExistingFoto(event) {
    const checkbox = event.target;
    const wrapper = checkbox.closest(".foto-item");
    const preview = wrapper.querySelector(".foto-preview");

    if (checkbox.checked) {
      preview.classList.add("border-[#A63D2F]", "opacity-50");
      preview.classList.remove("border-[#E8E0D4]");
    } else {
      preview.classList.remove("border-[#A63D2F]", "opacity-50");
      preview.classList.add("border-[#E8E0D4]");
    }
  }

  preview(event) {
    const container = this.previewTarget;
    const input = event.target;
    const files = input.files;
    const inputId = input.id;
    console.log('Files selected:', files.length, 'Input ID:', inputId);
    if (!files.length) return;

    // First add new files to selectedFiles
    Array.from(files).forEach((file) => {
      if (!file.type.startsWith("image/")) return;
      this.selectedFiles.push(file);
      console.log('Added file:', file.name);

      const reader = new FileReader();
      reader.onload = (e) => {
        console.log('FileReader loaded for:', file.name);
        const wrapper = document.createElement("div");
        wrapper.className = "relative group mb-2";

        const img = document.createElement("img");
        img.src = e.target.result;
        img.className = "w-20 h-20 object-cover rounded-lg border-2 border-[#B8860B]";
        img.alt = file.name;

        const removeBtn = document.createElement("button");
        removeBtn.type = "button";
        removeBtn.innerHTML = "&times;";
        removeBtn.className = "absolute -top-2 -right-2 w-6 h-6 rounded-full bg-[#A63D2F] text-white text-lg flex items-center justify-center cursor-pointer";
        removeBtn.title = "Eliminar foto";
        removeBtn.onclick = (e) => {
          e.preventDefault();
          if (confirm('¿Estás seguro de que quieres eliminar esta foto?')) {
            wrapper.remove();
            const idx = this.selectedFiles.indexOf(file);
            if (idx > -1) this.selectedFiles.splice(idx, 1);
            this._updateFileInputFromSelected(inputId);
            this._updateCounter();
          }
        };

        wrapper.appendChild(img);
        wrapper.appendChild(removeBtn);
        container.appendChild(wrapper);
        console.log('Thumbnail added for:', file.name);
      };
      reader.onerror = (e) => {
        console.error('FileReader error:', e);
      };
      reader.readAsDataURL(file);
    });

    // Update the input with ALL accumulated files
    this._updateFileInputFromSelected(inputId);
    this._updateCounter();
    
    // Reset input value to allow re-selecting camera
    input.value = '';
    console.log('Input value reset, total files:', this.selectedFiles.length);
  }

  _updateFileInputFromFiles(files, inputId = null) {
    const dt = new DataTransfer();
    Array.from(files).forEach((f) => dt.items.add(f));
    this._replaceInputFiles(dt.files, inputId);
  }

  _updateFileInputFromSelected(inputId = 'cameraInput') {
    const dt = new DataTransfer();
    this.selectedFiles.forEach((f) => dt.items.add(f));
    // Use the specified input or cameraInput by default
    this._replaceInputFiles(dt.files, inputId);
  }

  _replaceInputFiles(files, targetInputId = null) {
    console.log('Replacing input files:', files.length, 'target:', targetInputId);
    
    // Only update one specific input, not all inputs
    const input = targetInputId 
      ? document.getElementById(targetInputId)
      : this.element.querySelector("input[name='producto[fotos][]']");
    
    if (!input) {
      console.error('Input not found');
      return;
    }

    const newInput = document.createElement('input');
    newInput.type = 'file';
    newInput.name = input.name;
    newInput.id = input.id;
    newInput.accept = input.accept;
    newInput.multiple = input.multiple;
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
      this.counterTarget.textContent =
        this.selectedFiles.length + " foto(s) seleccionada(s)";
      this.counterTarget.classList.toggle(
        "hidden",
        this.selectedFiles.length === 0,
      );
    }
  }
}
