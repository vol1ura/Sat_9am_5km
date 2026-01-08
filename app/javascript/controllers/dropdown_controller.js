import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['toggle', 'menu'];

  connect() {
    this._boundShow = this.show.bind(this);
    this._boundHide = this.hide.bind(this);

    this.element.addEventListener('mouseenter', this._boundShow);
    this.element.addEventListener('mouseleave', this._boundHide);
  }

  disconnect() {
    this.element.removeEventListener('mouseenter', this._boundShow);
    this.element.removeEventListener('mouseleave', this._boundHide);
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
