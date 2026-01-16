import { Controller } from "@hotwired/stimulus"

// Replaces default browser confirms with an on-brand glass modal.
export default class extends Controller {
  static targets = ["dialog", "form"]

  open(event) {
    event.preventDefault()
    this.dialogTarget.classList.remove("hidden")
    this.dialogTarget.classList.add("flex")
    document.body.classList.add("overflow-hidden")
  }

  cancel(event) {
    if (event) event.preventDefault()
    this.closeDialog()
  }

  confirm(event) {
    event.preventDefault()
    this.closeDialog()
    this.formTarget.requestSubmit()
  }

  closeDialog() {
    this.dialogTarget.classList.add("hidden")
    this.dialogTarget.classList.remove("flex")
    document.body.classList.remove("overflow-hidden")
  }
}
