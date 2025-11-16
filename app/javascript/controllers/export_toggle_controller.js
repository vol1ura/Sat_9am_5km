import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['submit', 'options']

  connect() {

    this.toggleSubmitEnabled()
  }

  change(_event) {
    this.toggleSubmitEnabled()
  }

  toggleSubmitEnabled() {
    const checked = this.element.querySelector('input[name="model"]:checked')
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = !checked
    }
  }
}
