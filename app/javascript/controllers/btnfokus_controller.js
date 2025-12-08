// app/javascript/controllers/fokus_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "taskName",
    "timerDisplay",
    "startButton",
    "pauseButton",
    "stopButton"
  ]

  static values = {
    duration: { type: Number, default: 15 * 60 } // en secondes
  }

  connect() {
    this.isRunning = false
    this.timeLeft = this.durationValue
    this.timerInterval = null

    this.updateTaskName()
    this.updateDisplay()
  }

  // --- Actions Stimulus (data-action) ---

  start(event) {
    if (event) event.preventDefault()
    if (this.isRunning) return

    this.isRunning = true
    this.toggleButtons(true)

    this.timerInterval = setInterval(() => {
      this.timeLeft--
      this.updateDisplay()

      if (this.timeLeft <= 0) {
        clearInterval(this.timerInterval)
        this.isRunning = false
        this.toggleButtons(false)
        alert("Session FOKUS terminée ! 🎉")
        this.reset()
      }
    }, 1000)
  }

  pause(event) {
    if (event) event.preventDefault()
    if (!this.isRunning) return

    this.isRunning = false
    clearInterval(this.timerInterval)
    this.toggleButtons(false)
  }

  stop(event) {
    if (event) event.preventDefault()
    this.reset()
    const modal = bootstrap.Modal.getInstance(this.element)
    if (modal) modal.hide()
  }

  // --- Méthodes internes ---

  reset() {
    if (this.timerInterval) clearInterval(this.timerInterval)
    this.isRunning = false
    this.timeLeft = this.durationValue
    this.updateDisplay()
    this.toggleButtons(false)
  }

  updateDisplay() {
    const minutes = Math.floor(this.timeLeft / 60)
    const seconds = this.timeLeft % 60
    this.timerDisplayTarget.textContent =
      `${minutes.toString().padStart(2, "0")}:${seconds.toString().padStart(2, "0")}`
  }

  updateTaskName() {
    const taskName = this.element.dataset.taskName || "Tâche"
    this.taskNameTarget.textContent = taskName
  }

  toggleButtons(running) {
    if (running) {
      this.startButtonTarget.style.display = "inline-block"
      this.pauseButtonTarget.style.display = "inline-block"
    } else {
      this.startButtonTarget.style.display = "inline-block"
      this.pauseButtonTarget.style.display = "none"
    }
  }
}
