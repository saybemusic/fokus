// app/javascript/controllers/slidebutton_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slider", "handle", "text"]

  connect() {
    this.isDragging = false
    this.startX = 0
    this.updateMeasurements()
    window.addEventListener("resize", this.updateMeasurements)
  }

  disconnect() {
    window.removeEventListener("resize", this.updateMeasurements)
  }

  updateMeasurements = () => {
    this.sliderRect = this.sliderTarget.getBoundingClientRect()
    this.maxTravel = this.sliderRect.width - this.handleTarget.offsetWidth - 8
  }

  startDrag(event) {
    const clientX = this._clientX(event)
    if (clientX == null) return

    this.isDragging = true
    this.startX = clientX - this.handleTarget.offsetLeft
    this.element.classList.add("is-dragging")

    window.addEventListener("mousemove", this.moveDrag)
    window.addEventListener("mouseup", this.endDrag)
    window.addEventListener("touchmove", this.moveDrag, { passive: true })
    window.addEventListener("touchend", this.endDrag)
  }

  moveDrag = (event) => {
    if (!this.isDragging) return
    const clientX = this._clientX(event)
    if (clientX == null) return

    const pos = clientX - this.startX
    const clamped = Math.min(Math.max(4, pos), this.maxTravel)
    this.handleTarget.style.left = `${clamped}px`

    const progress = clamped / this.maxTravel
    this.textTarget.style.opacity = 1 - progress
  }

  endDrag = () => {
    if (!this.isDragging) return

    this.isDragging = false
    this.element.classList.remove("is-dragging")

    window.removeEventListener("mousemove", this.moveDrag)
    window.removeEventListener("mouseup", this.endDrag)
    window.removeEventListener("touchmove", this.moveDrag)
    window.removeEventListener("touchend", this.endDrag)

    const finalLeft = parseFloat(this.handleTarget.style.left || "4")
    if (finalLeft >= this.maxTravel * 0.9) {
      this.element.classList.add("fokus-slider-done")
      this.textTarget.textContent = "Chargement..."
      window.location.href = "/objectives/new" // ou <%= objectives_path %> dans un pack ERB
    } else {
      this.handleTarget.style.left = "4px"
      this.textTarget.style.opacity = 1
    }
  }

  _clientX(event) {
    if (event.touches && event.touches[0]) {
      return event.touches[0].clientX
    }
    if (event.changedTouches && event.changedTouches[0]) {
      return event.changedTouches[0].clientX
    }
    return event.clientX
  }
}
