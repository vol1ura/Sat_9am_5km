import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    target: { type: String, default: '.multi-collapse' },
    show: String,
    hide: String
  };

  initialize() {
    this.#setName();
  }

  toggle() {
    const expanded = this.element.getAttribute('aria-expanded') === 'true';
    const nextExpanded = !expanded;

    document.querySelectorAll(this.targetValue).forEach((element) => {
      element.classList.toggle('hidden', !nextExpanded);
    });

    this.element.setAttribute('aria-expanded', nextExpanded);
    this.#setName();
  }

  #setName() {
    if (this.element.getAttribute('aria-expanded') === 'true') {
      this.element.innerHTML = this.hideValue;
    } else {
      this.element.innerHTML = this.showValue;
    }
  }
}
