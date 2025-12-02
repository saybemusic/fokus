import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "content", "navbar", "toggleIcon", "overlay"]

  toggle() {
    // Ouvre / ferme la sidebar
    this.sidebarTarget.classList.toggle("open")

    // Décale le contenu
    this.contentTarget.classList.toggle("shifted")

    // Décale la navbar
    this.navbarTarget.classList.toggle("shifted")

    // Active / désactive l’overlay
    this.overlayTarget.classList.toggle("visible")

    // Met à jour l’icône du bouton
    this.updateIcon()
  }

  updateIcon() {
    const hamburger = this.toggleIconTarget.querySelector(".icon-hamburger")
    const arrow = this.toggleIconTarget.querySelector(".icon-arrow")

    // Selon si la sidebar est ouverte ou non
    const isOpen = this.sidebarTarget.classList.contains("open")

    if (isOpen) {
      hamburger.classList.add("hidden")
      arrow.classList.remove("hidden")
    } else {
      hamburger.classList.remove("hidden")
      arrow.classList.add("hidden")
    }
  }
}
