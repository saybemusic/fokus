import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { data: Array }

  connect() {
    this.draw()
  }

  draw() {
    const canvas = this.element
    const ctx = canvas.getContext("2d")

    const data = this.dataValue || []

    const cellSize = 15
    const padding = 3
    const columns = 15

    const colors = {
      0: "#d3d3d3", // gris futur
      1: "#ff4f4f", // rouge
      2: "#ff9f1c", // orange
      3: "#34c759"  // vert
    }

    let col = 0
    let row = 0

    data.forEach(intensity => {
      ctx.fillStyle = colors[intensity] || "#ffffff"

      const x = col * (cellSize + padding)
      const y = row * (cellSize + padding)

      ctx.fillRect(x, y, cellSize, cellSize)

      col++

      if (col >= columns) {
        col = 0
        row++
      }
    })
  }
}
