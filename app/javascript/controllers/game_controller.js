import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Quand le controller se charge → on écoute tout le document
    document.addEventListener("click", this.closeOnClickOutside)
  }

  disconnect() {
    // On nettoie l'event listener quand le controller disparaît
    document.removeEventListener("click", this.closeOnClickOutside)
  }

  toggle(event) {
    event.stopPropagation() // important pour ne pas fermer instantanément
    this.element.classList.toggle("is-active")
  }

  // Fonction fléchée pour conserver "this"
  closeOnClickOutside = (event) => {
    // Si on clique en dehors de .game → fermer
    if (!this.element.contains(event.target)) {
      this.element.classList.remove("is-active")
    }
  }
}
