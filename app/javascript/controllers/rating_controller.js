import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  select(event) {
    event.preventDefault()
    this.element.requestSubmit()
  }
}
