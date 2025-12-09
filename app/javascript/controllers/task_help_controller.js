import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["body"]

  connect() {
    this.bodyTarget.classList.remove("open")
  }

  toggle() {
    this.bodyTarget.classList.toggle("open")
  }
}
