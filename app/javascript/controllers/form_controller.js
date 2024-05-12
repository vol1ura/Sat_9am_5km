import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['input']

  submit(event) {
    event.preventDefault()
    this.element.requestSubmit()
  }

  toggleBlock(event) {
    const input = this.inputTarget.getElementsByTagName('input')[0]
    if (event.target.checked) {
      this.inputTarget.classList.add('d-none')
      input.disabled = true
    } else {
      this.inputTarget.classList.remove('d-none')
      input.disabled = false
    }
  }
}
