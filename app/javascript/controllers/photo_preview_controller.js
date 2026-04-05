import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "frame", "image", "clear"]

  async preview(event) {
    const file = event.target.files?.[0]
    if (!file) {
      this.clear()
      return
    }

    const processedFile = await this.cropToFourByThree(file)
    if (!processedFile) {
      this.clear()
      return
    }

    const transfer = new DataTransfer()
    transfer.items.add(processedFile)
    this.inputTarget.files = transfer.files

    if (this.previewUrl) URL.revokeObjectURL(this.previewUrl)
    this.previewUrl = URL.createObjectURL(processedFile)
    this.imageTarget.src = this.previewUrl
    this.frameTarget.classList.remove("hidden")
    if (this.hasClearTarget) this.clearTarget.classList.remove("hidden")
  }

  clear() {
    this.inputTarget.value = null
    if (this.previewUrl) {
      URL.revokeObjectURL(this.previewUrl)
      this.previewUrl = null
    }
    this.imageTarget.removeAttribute("src")
    this.frameTarget.classList.add("hidden")
    if (this.hasClearTarget) this.clearTarget.classList.add("hidden")
  }

  async cropToFourByThree(file) {
    const image = await this.loadImage(file)
    const sourceWidth = image.naturalWidth || image.width
    const sourceHeight = image.naturalHeight || image.height
    const sourceRatio = sourceWidth / sourceHeight
    const targetRatio = 4 / 3

    let sx = 0
    let sy = 0
    let sw = sourceWidth
    let sh = sourceHeight

    if (sourceRatio > targetRatio) {
      sw = sourceHeight * targetRatio
      sx = (sourceWidth - sw) / 2
    } else {
      sh = sourceWidth / targetRatio
      sy = (sourceHeight - sh) / 2
    }

    const canvas = document.createElement("canvas")
    canvas.width = 1600
    canvas.height = 1200

    const context = canvas.getContext("2d")
    context.drawImage(image, sx, sy, sw, sh, 0, 0, canvas.width, canvas.height)

    const blob = await new Promise((resolve) => canvas.toBlob(resolve, "image/jpeg", 0.88))
    if (!blob) return null

    const filenameBase = (file.name || "meal-photo").replace(/\.[^.]+$/, "")
    return new File([blob], `${filenameBase}.jpg`, { type: "image/jpeg" })
  }

  loadImage(file) {
    return new Promise((resolve, reject) => {
      const image = new Image()
      const url = URL.createObjectURL(file)
      image.onload = () => {
        URL.revokeObjectURL(url)
        resolve(image)
      }
      image.onerror = () => {
        URL.revokeObjectURL(url)
        reject(new Error("Failed to load image"))
      }
      image.src = url
    })
  }
}
