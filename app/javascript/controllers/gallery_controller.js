import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide", "thumb", "counter"]

  connect() {
    this.current = 0
    this._keyHandler = (e) => {
      if (e.key === "ArrowLeft") this.prev()
      if (e.key === "ArrowRight") this.next()
    }
    document.addEventListener("keydown", this._keyHandler)
  }

  disconnect() {
    document.removeEventListener("keydown", this._keyHandler)
  }

  next() { this.show(this.current + 1) }
  prev() { this.show(this.current - 1) }

  goto(e) {
    this.show(parseInt(e.currentTarget.dataset.index))
  }

  show(index) {
    const count = this.slideTargets.length
    this.current = ((index % count) + count) % count

    this.slideTargets.forEach((slide, i) => {
      slide.style.opacity = i === this.current ? "1" : "0"
    })

    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${this.current + 1} / ${count}`
    }

    if (this.hasThumbTarget) {
      this.thumbTargets.forEach((thumb, i) => {
        thumb.classList.toggle("border-[#B8860B]", i === this.current)
        thumb.classList.toggle("border-transparent", i !== this.current)
        thumb.classList.toggle("opacity-70", i !== this.current)
      })
    }
  }
}
