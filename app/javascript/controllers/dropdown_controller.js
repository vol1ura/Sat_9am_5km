import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['toggle', 'menu'];

  connect() {
    this._boundShow = this.show.bind(this);
    this._boundHide = this.hide.bind(this);
    this._boundToggle = this.toggle.bind(this);

    this.element.addEventListener('mouseenter', this._boundShow);
    this.element.addEventListener('mouseleave', this._boundHide);
    this.toggleTarget.addEventListener('click', this._boundToggle);
  }

  disconnect() {
    this.element.removeEventListener('mouseenter', this._boundShow);
    this.element.removeEventListener('mouseleave', this._boundHide);
    this.toggleTarget.removeEventListener('click', this._boundToggle);
  }

  toggle(event) {
    event.preventDefault();
    if (this.menuTarget.classList.contains('hidden')) {
      this.show();
    } else {
      this.hide();
    }
  }

  show() {
    this.toggleTarget.setAttribute('aria-expanded', 'true');
    this.menuTarget.classList.remove('hidden');
    this.menuTarget.classList.add('block');
  }

  hide() {
    this.toggleTarget.setAttribute('aria-expanded', 'false');
    this.menuTarget.classList.add('hidden');
    this.menuTarget.classList.remove('block');
  }
}
