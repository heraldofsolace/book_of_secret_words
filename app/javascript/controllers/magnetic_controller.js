// app/javascript/controllers/magnetic_controller.js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="magnetic"
export default class extends Controller {
  static targets = ["inner"]

  connect() {
    this.strength = 22        // how far it can move (px)
    this.ease = 0.18          // how "laggy" / smooth the inertia feels

    this.currentX = 0
    this.currentY = 0
    this.targetX = 0
    this.targetY = 0
    this.rafId = null
  }

  disconnect() {
    if (this.rafId) cancelAnimationFrame(this.rafId)
  }

  mousemove(event) {
    const rect = this.element.getBoundingClientRect()
    const x = event.clientX - (rect.left + rect.width / 2)
    const y = event.clientY - (rect.top + rect.height / 2)

    this.targetX = (x / rect.width) * this.strength
    this.targetY = (y / rect.height) * this.strength

    this.startAnimation()
  }

  mouseleave() {
    this.targetX = 0
    this.targetY = 0
    this.startAnimation()
  }

  startAnimation() {
    if (this.rafId) return
    const animate = () => {
      // linear interpolation towards target
      this.currentX += (this.targetX - this.currentX) * this.ease
      this.currentY += (this.targetY - this.currentY) * this.ease

      this.innerTarget.style.transform = `translate(${this.currentX}px, ${this.currentY}px)`

      const stillMoving =
        Math.abs(this.targetX - this.currentX) > 0.1 ||
        Math.abs(this.targetY - this.currentY) > 0.1

      if (stillMoving) {
        this.rafId = requestAnimationFrame(animate)
      } else {
        // snap to final position & stop the loop
        this.currentX = this.targetX
        this.currentY = this.targetY
        this.innerTarget.style.transform = `translate(${this.currentX}px, ${this.currentY}px)`
        this.rafId = null
      }
    }

    this.rafId = requestAnimationFrame(animate)
  }
}
