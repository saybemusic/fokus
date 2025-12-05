import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { percent: Number }

  connect() {
    const bar = this.element.querySelector(".fokus-progress-bar")
    const container = this.element.querySelector(".fokus-progress-points")

    // Mise à jour largeur
    bar.style.width = `${this.percentValue}%`

      if (this.percentValue >= 100) {
      bar.style.background = "linear-gradient(135deg, #37d27a, #2bb266)";
      pointsContainer.classList.add('hidden'); // ← on cache les points
    } else {
      bar.style.background = "linear-gradient(to right, red 0%, orange 99%)";
      pointsContainer.classList.remove('hidden'); // ← on ré-affiche les points
    }
    // Génération de points
    this.generatePoints(container, Math.floor(20 + this.percentValue * 1.5))
  }

  generatePoints(container, count) {
  container.innerHTML = ""

  // +20% de points
  const totalPoints = Math.floor(count * 1.2)

  for (let i = 0; i < totalPoints; i++) {
    const dot = document.createElement("div")
    dot.classList.add("fokus-point")

    // Position aléatoire de départ
    dot.style.left = Math.random() * 100 + "%"
    dot.style.top = Math.random() * 100 + "%"

    // Durée plus lente de 30%
    const baseDuration = 1 + Math.random() * 1.5   // avant
    const slowerDuration = baseDuration * 1.3       // +30% plus lent
    dot.style.setProperty("--duration", slowerDuration + "s")

    // Déplacements aléatoires larges (+/- 20px)
    dot.style.setProperty("--dx1", (Math.random() * 40 - 20) + "px")
    dot.style.setProperty("--dy1", (Math.random() * 40 - 20) + "px")

    dot.style.setProperty("--dx2", (Math.random() * 40 - 20) + "px")
    dot.style.setProperty("--dy2", (Math.random() * 40 - 20) + "px")

    dot.style.setProperty("--dx3", (Math.random() * 40 - 20) + "px")
    dot.style.setProperty("--dy3", (Math.random() * 40 - 20) + "px")

    dot.style.setProperty("--dx4", (Math.random() * 40 - 20) + "px")
    dot.style.setProperty("--dy4", (Math.random() * 40 - 20) + "px")

    container.appendChild(dot)
  }
}
}
