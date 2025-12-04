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

    const cellSize = 18
    const padding = 4
    const maxColumns = 7

    let column = 0
    let row = 0

    // Couleurs conformes à ta logique
    const colors = {
      0: "#d7d7d7ff", // blanc (futur ou jour actuel sans progression)
      1: "#ff4f4f", // rouge (aucune tâche faite, jour passé)
      2: "#ffa534", // orange (partiellement fait)
      3: "#34c759"  // vert (toutes tâches faites)
    }

    data.forEach(intensity => {
      ctx.fillStyle = colors[intensity] || "#ffffff"

      const x = column * (cellSize + padding)
      const y = row * (cellSize + padding)

      ctx.fillRect(x, y, cellSize, cellSize)

      column++

      if (column >= maxColumns) {
        column = 0
        row++
      }
    })
  }
}
