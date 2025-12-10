import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Auto-hide after 5 seconds
    setTimeout(() => this.close(), 5000)
  }

  close() {
    this.element.classList.add("opacity-0", "transition", "duration-300")
    setTimeout(() => this.element.remove(), 300)
  }
}
