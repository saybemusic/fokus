import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "content", "navbar", "toggleIcon", "overlay"]

  toggle() {
    this.sidebarTarget.classList.toggle("open")
    this.contentTarget.classList.toggle("shifted")
    this.navbarTarget.classList.toggle("shifted")
    this.overlayTarget.classList.toggle("visible")
    this.updateIcon()
  }

  updateIcon() {
    const hamburger = this.toggleIconTarget.querySelector(".icon-hamburger")
    const arrow = this.toggleIconTarget.querySelector(".icon-arrow")

    hamburger.classList.toggle("hidden")
    arrow.classList.toggle("hidden")
  }
}
