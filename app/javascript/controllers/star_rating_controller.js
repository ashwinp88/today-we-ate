import { Controller } from "@hotwired/stimulus"

// Handles interactive star-based ratings with half-star increments.
export default class extends Controller {
  static targets = ["input", "slider", "fill", "display"]
  static values = {
    min: { type: Number, default: 0.5 },
    max: { type: Number, default: 5 },
    step: { type: Number, default: 0.5 }
  }

  connect() {
    const startingValue = parseFloat(this.inputTarget.value) || this.minValue
    this.setRating(startingValue)
  }

  select(event) {
    this.updateFromEvent(event)
  }

  keydown(event) {
    const current = parseFloat(this.inputTarget.value) || this.minValue
    let delta = 0

    if (["ArrowRight", "ArrowUp"].includes(event.key)) {
      delta = this.stepValue
    } else if (["ArrowLeft", "ArrowDown"].includes(event.key)) {
      delta = -this.stepValue
    }

    if (delta !== 0) {
      event.preventDefault()
      this.setRating(current + delta)
    }
  }

  updateFromEvent(event) {
    const rect = this.sliderTarget.getBoundingClientRect()
    const point = Math.min(Math.max(event.clientX - rect.left, 0), rect.width)
    const percent = rect.width === 0 ? 0 : point / rect.width
    const rawValue = this.minValue + percent * (this.maxValue - this.minValue)
    this.setRating(rawValue)
  }

  setRating(value) {
    const rounded = this.roundToStep(value)
    const safeValue = Math.min(this.maxValue, Math.max(this.minValue, rounded))
    this.inputTarget.value = safeValue

    this.fillTargets.forEach((fill, index) => {
      const proportion = this.starFillAmount(safeValue, index)
      fill.style.width = `${proportion * 100}%`
    })
    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = `${safeValue.toFixed(1)} / ${this.maxValue}`
    }

    this.sliderTarget.setAttribute("aria-valuenow", safeValue.toString())
  }

  roundToStep(value) {
    const stepCount = Math.round((value - this.minValue) / this.stepValue)
    return this.minValue + stepCount * this.stepValue
  }

  starFillAmount(value, index) {
    return Math.min(Math.max(value - index, 0), 1)
  }
}
