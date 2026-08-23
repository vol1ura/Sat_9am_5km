import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['checkbox', 'submit'];

  connect() {
    this.element.addEventListener('hidden.bs.modal', () => this.reset());
  }

  toggleSubmit() {
    this.submitTarget.disabled = !this.checkboxTarget.checked;
  }

  reset() {
    this.checkboxTarget.checked = false;
    this.submitTarget.disabled = true;
  }
}
