import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["body"]

  toggle() {
    this.bodyTarget.style.display = this.bodyTarget.style.display === "none" ? "block" : "none"
  }
}
