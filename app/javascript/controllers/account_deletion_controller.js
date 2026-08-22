import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['checkbox', 'submit'];

  connect() {
    this.dialog = this.element.closest('dialog');
    this._boundReset = () => this.reset();
    this.dialog?.addEventListener('close', this._boundReset);
    this.toggleSubmit();
  }

  disconnect() {
    this.dialog?.removeEventListener('close', this._boundReset);
  }

  toggleSubmit() {
    this.submitTarget.disabled = !this.checkboxTarget.checked;
  }

  reset() {
    this.checkboxTarget.checked = false;
    this.toggleSubmit();
  }
}
