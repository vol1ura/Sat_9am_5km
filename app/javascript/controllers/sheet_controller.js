import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['panel', 'backdrop'];

  open() {
    this.panelTarget.classList.remove('hidden');
    this.backdropTarget.classList.remove('hidden');
    document.body.style.overflow = 'hidden';
  }

  close() {
    this.panelTarget.classList.add('hidden');
    this.backdropTarget.classList.add('hidden');
    document.body.style.overflow = '';
  }

  toggle() {
    if (this.panelTarget.classList.contains('hidden')) {
      this.open();
    } else {
      this.close();
    }
  }
}
