import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  open() {
    this.sidebarTarget.classList.add("open")
    this.overlayTarget.classList.add("visible")
  }

  close() {
    this.sidebarTarget.classList.remove("open")
    this.overlayTarget.classList.remove("visible")
  }
}
