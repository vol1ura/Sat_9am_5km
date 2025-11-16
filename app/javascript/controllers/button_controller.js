import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    show: String,
    hide: String
  };

  initialize() {
    this.setName();
  }

  setName() {
    if (this.element.getAttribute('aria-expanded') === 'true') {
      this.element.innerHTML = this.hideValue;
    } else {
      this.element.innerHTML = this.showValue;
    }
  }
}
