import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  initialize() {
    this.search = this.debounce(this.search.bind(this), 300)
  }

  search() {
    this.element.requestSubmit()
  }

  debounce(fn, delay) {
    let timer
    return (...args) => {
      clearTimeout(timer)
      timer = setTimeout(() => fn(...args), delay)
    }
  }
}
