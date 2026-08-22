import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = { id: String };

  open(event) {
    event?.preventDefault();
    event?.stopPropagation();

    const dialogId = event?.params?.dialogId || this.idValue;
    const element = dialogId ? document.getElementById(dialogId) : this.element;

    if (element && typeof element.showModal === 'function') {
      // Defer opening so the same click does not hit the dialog backdrop.
      requestAnimationFrame(() => element.showModal());
    }
  }

  close(event) {
    const dialogId = event?.params?.dialogId || this.idValue;
    const element = dialogId ? document.getElementById(dialogId) : this.element;

    if (element && typeof element.close === 'function') {
      element.close();
    }
  }

  connect() {
    if (this.element.tagName === 'DIALOG') {
      this.element.addEventListener('click', (event) => {
        if (event.target === this.element) this.close();
      });
    }
  }
}
