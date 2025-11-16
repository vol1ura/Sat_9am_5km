import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    initialId: String,
    initialName: String
  };

  connect() {
    if (this.initialIdValue && this.initialNameValue) {
      setTimeout(() => {
        const input = this.element.querySelector('input[type="text"]');
        const hiddenField = this.element.querySelector('input[type="hidden"]');

        if (input && hiddenField && !input.value) {
          input.value = this.initialNameValue;
          hiddenField.value = this.initialIdValue;
        }
      }, 100);
    }
  }
}
