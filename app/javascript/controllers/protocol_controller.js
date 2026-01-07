import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['absolute', 'male', 'female'];

  initialize() {
    this.maleTarget.innerHTML = this.absoluteTarget.innerHTML;
    this.#filterTable(this.maleTarget, 'male');
    this.femaleTarget.innerHTML = this.absoluteTarget.innerHTML;
    this.#filterTable(this.femaleTarget, 'female');
  }

  #filterTable(table, gender) {
    let new_position = 0;
    table.querySelectorAll('tbody tr').forEach(row => {
      if (row.dataset.gender !== gender) {
        row.parentNode.removeChild(row);
      } else {
        row.querySelector('.position').innerText = ++new_position;
      }
    });
  }
}
