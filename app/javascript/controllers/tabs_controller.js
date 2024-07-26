import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  change() {
    console.log("Tab changed!")
  }
}
