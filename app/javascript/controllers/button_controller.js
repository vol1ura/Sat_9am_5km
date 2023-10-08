import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleName(e) {
    if(e.target.getAttribute('aria-expanded') === 'true') {
      e.target.innerHTML = 'Свернуть'
    } else {
      e.target.innerHTML = 'Показать все'
    }
  }
}
