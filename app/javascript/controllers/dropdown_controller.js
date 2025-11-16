import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['toggle', 'menu'];

  connect() {
    this.element.addEventListener('mouseenter', this.show.bind(this));
    this.element.addEventListener('mouseleave', this.hide.bind(this));
  }

  disconnect() {
    this.element.removeEventListener('mouseenter', this.show.bind(this));
    this.element.removeEventListener('mouseleave', this.hide.bind(this));
  }

  show() {
    this.toggleTarget.setAttribute('aria-expanded', 'true');
    this.menuTarget.classList.add('show');
  }

  hide() {
    this.toggleTarget.setAttribute('aria-expanded', 'false');
    this.menuTarget.classList.remove('show');
  }
}
