import { Controller } from "@hotwired/stimulus"

// data-controller="reload"
// data-reload-interval-value="2000"
export default class extends Controller {
  static values = {
    interval: { type: Number, default: 2000 }
  }

  connect() {
    this.timer = setInterval(() => {
      window.location.reload()
    }, this.intervalValue)
  }

  disconnect() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  }
}
