import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "timerDisplay", "taskName", "startButton", "pauseButton", "stopButton" ]

  static values = {
    initialTime: { type: Number, default: 15 * 60 }
  }

  connect() {
    this.element.addEventListener('show.bs.modal', this.openModal.bind(this))
    this.timeLeft = this.initialTimeValue
    this.isRunning = false
    this.timerId = null
    this.updateDisplay()
  }

  openModal(event) {
    const triggerButton = event.relatedTarget

    if (triggerButton) {
      const name = triggerButton.dataset.taskName
      const duration = triggerButton.dataset.taskDuration

      if (name) {
        this.taskNameTarget.textContent = name
      }

      if (duration) {
        this.initialTimeValue = parseInt(duration, 10) || this.initialTimeValue
      }
    }

    this.resetTimer()
    this.updateButtons()
  }

  start() {
    if (this.isRunning) return
    this.isRunning = true
    this.updateButtons()
    this.timerId = setInterval(() => {
      this.timeLeft--
      this.updateDisplay()
      if (this.timeLeft <= 0) {
        this.stop()
        this.timerDisplayTarget.classList.add("text-danger")
      }
    }, 1000)
  }

  pause() {
    if (!this.isRunning) return
    this.isRunning = false
    clearInterval(this.timerId)
    this.updateButtons()
  }

  stop() {
    this.isRunning = false
    clearInterval(this.timerId)
    this.resetTimer()
    this.updateButtons()
    this.timerDisplayTarget.classList.remove("text-danger")
  }

  resetTimer() {
    this.timeLeft = this.initialTimeValue
    this.updateDisplay()
  }

  updateDisplay() {
    const minutes = Math.floor(this.timeLeft / 60)
    const seconds = this.timeLeft % 60
    this.timerDisplayTarget.textContent =
      `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
  }

  updateButtons() {
    if (this.isRunning) {
      this.startButtonTarget.style.display = "none"
      this.pauseButtonTarget.style.display = "inline-block"
    } else {
      this.startButtonTarget.style.display = "inline-block"
      this.pauseButtonTarget.style.display = "none"
    }
    this.stopButtonTarget.style.display = "inline-block"
  }

  disconnect() {
    if (this.timerId) {
      clearInterval(this.timerId)
    }
  }

  // horloge
  static targets = [ "timerDisplay", "taskName", "startButton", "pauseButton", "stopButton", "progressRing", "timerContainer" ]

  updateDisplay() {
    const minutes = Math.floor(this.timeLeft / 60)
    const seconds = this.timeLeft % 60
    this.timerDisplayTarget.textContent =
      `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`

    // Animation anneau analogique (0% = 534, 100% = 0)
    const circumference = 534 // 2 * π * 85
    const offset = (this.timeLeft / this.initialTimeValue) * circumference
    this.progressRingTarget.style.strokeDashoffset = offset
  }

  stop() {
    this.isRunning = false
    clearInterval(this.timerId)
    this.resetTimer()
    this.updateButtons()
    this.timerContainerTarget.classList.remove("text-danger")
  }

  resetTimer() {
    this.timeLeft = this.initialTimeValue
    this.progressRingTarget.style.strokeDashoffset = "534" // Reset anneau
    this.updateDisplay()
  }

}
