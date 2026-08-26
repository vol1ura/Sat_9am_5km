import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['panel', 'input', 'toggle'];

  connect() {
    this.closeOnEscape = this.#closeOnEscape.bind(this);
    document.addEventListener('keydown', this.closeOnEscape);
  }

  disconnect() {
    document.removeEventListener('keydown', this.closeOnEscape);
  }

  open(event) {
    event?.preventDefault();
    this.panelTarget.classList.remove('hidden');
    this.#setExpanded(true);

    if (this.hasInputTarget) {
      requestAnimationFrame(() => this.inputTarget.focus());
    }
  }

  close(event) {
    event?.preventDefault();
    this.panelTarget.classList.add('hidden');
    this.#setExpanded(false);
  }

  #closeOnEscape(event) {
    if (event.key === 'Escape' && !this.panelTarget.classList.contains('hidden')) {
      this.close(event);
    }
  }

  #setExpanded(expanded) {
    if (!this.hasToggleTarget) return;

    this.toggleTarget.setAttribute('aria-expanded', expanded ? 'true' : 'false');
  }
}
