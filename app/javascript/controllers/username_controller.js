import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="username"
export default class extends Controller {
  static targets = ["input", "status"]

  connect() {
    this.timeout = null
  }

  check() {
    clearTimeout(this.timeout)

    const username = this.inputTarget.value.trim()

    // Clear status if empty
    if (username === "") {
      this.statusTarget.innerHTML = ""
      return
    }

    // Debounce request (350ms)
    this.timeout = setTimeout(() => {
      this.fetchAvailability(username)
    }, 350)
  }

  fetchAvailability(username) {
    fetch(`/check_username?username=${encodeURIComponent(username)}`)
      .then(response => response.json())
      .then(data => {
        if (data.available) {
          this.statusTarget.innerHTML =
            `<span class="text-emerald-400 text-xs">✓ Username is available</span>`
        } else {
          this.statusTarget.innerHTML =
            `<span class="text-red-400 text-xs">✕ Username is taken</span>`
        }
      })
  }
}
