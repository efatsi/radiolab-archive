import { Controller } from "@hotwired/stimulus"

// Live-filters table rows by matching the query against each row's text
// (title, date, tease). Rows are looked up on each filter so rows replaced
// by turbo streams are still picked up.
export default class extends Controller {
  static targets = ["input", "empty"]

  filter() {
    const terms = this.inputTarget.value.toLowerCase().trim().split(/\s+/).filter(Boolean)
    let visible = 0

    this.rows.forEach(row => {
      const text = row.textContent.toLowerCase()
      const match = terms.every(term => text.includes(term))
      row.classList.toggle("hidden", !match)
      if (match) visible++
    })

    if (this.hasEmptyTarget) this.emptyTarget.classList.toggle("hidden", visible > 0)
  }

  clear(event) {
    if (event.key !== "Escape") return
    this.inputTarget.value = ""
    this.filter()
  }

  get rows() {
    return this.element.querySelectorAll("tbody tr")
  }
}
