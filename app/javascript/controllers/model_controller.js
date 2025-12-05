import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ["modal", "taskName", "timer", "start", "pause", "stop"]
  static values = {
    taskName: String
  }

  /* OUVRIR LA MODAL */
  open(event) {
    event.preventDefault()
    this.taskNameTarget.textContent = this.taskNameValue
    this.modalTarget.classList.remove("hidden")
  }

  /* FERMER LA MODAL */
  close() {
    this.modalTarget.classList.add("hidden")
    this.resetTimer()
  }

  /* Exemple timer (si tu veux conserver ton JS actuel) */
  resetTimer() {
    this.timerTarget.textContent = "25:00"
    this.pauseTarget.style.display = "none"
    this.startTarget.style.display = "inline-block"
  }
}
