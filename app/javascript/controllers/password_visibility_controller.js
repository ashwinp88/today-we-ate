import { Controller } from "@hotwired/stimulus"

// Toggles password fields between masked and plain text for better usability on auth forms.
export default class extends Controller {
  static targets = ["input", "toggle"]
  static values = {
    showLabel: { type: String, default: "Show" },
    hideLabel: { type: String, default: "Hide" }
  }

  toggle(event) {
    event.preventDefault()

    const currentType = this.inputTarget.type
    const isShowing = currentType === "text"
    this.inputTarget.type = isShowing ? "password" : "text"

    const nextLabel = isShowing ? this.showLabelValue : this.hideLabelValue
    this.toggleTarget.textContent = nextLabel
    this.toggleTarget.setAttribute("aria-pressed", (!isShowing).toString())
  }
}
