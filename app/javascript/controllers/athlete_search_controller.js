import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['input'];

  search() {
    const query = this.inputTarget.value.toLowerCase().trim();
    const tables = this.element.parentElement.querySelectorAll('.tab-content table');

    tables.forEach(table => this.#filterTable(table, query));

    if (query) {
      tables.forEach(table => table.classList.remove('table-striped'));
    } else {
      tables.forEach(table => table.classList.add('table-striped'));
    }
  }

  clear() {
    this.inputTarget.value = '';
    this.search();
  }

  #filterTable(table, query) {
    Array.from(table.querySelectorAll('tbody tr')).forEach(row => {
      const athleteLink = row.querySelector('.athlete-link');

      if (!athleteLink) {
        row.style.display = query ? 'none' : '';
        return;
      }

      const athleteName = athleteLink.textContent.toLowerCase();

      if (query === '' || athleteName.includes(query)) {
        row.style.display = '';
      } else {
        row.style.display = 'none';
      }
    });
  }
}
