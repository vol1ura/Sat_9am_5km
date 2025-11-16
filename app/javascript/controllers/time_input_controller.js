import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
    this.element.addEventListener('input', this.formatInput.bind(this));
    this.element.addEventListener('keydown', this.handleKeydown.bind(this));
  }

  formatInput(event) {
    let value = event.target.value.replace(/\D/g, '');

    if (value.length === 1 && value !== '0') {
      value = '0' + value;
    }
    if (value.length > 2) {
      value = value.substring(0, 2) + ':' + value.substring(2);
    }
    if (value.length > 5) {
      value = value.substring(0, 5) + ':' + value.substring(5, 7);
    }

    event.target.value = value;
  }

  handleKeydown(event) {
    const allowedKeys = ['Backspace', 'Delete', 'Tab', 'ArrowLeft', 'ArrowRight', 'Home', 'End'];
    if (allowedKeys.includes(event.key)) return;
    if (!/^\d$/.test(event.key) || event.target.value.length >= 8) event.preventDefault();
  }
}
