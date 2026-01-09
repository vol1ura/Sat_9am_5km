import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  toggleSort(event) {
    const th = event.currentTarget.closest('th');
    const table = this.element.closest('table');
    const currentIcon = th.querySelector('.sort-arrow > i');
    const wasAsc = currentIcon.classList.contains('fa-caret-down');

    this.element.querySelectorAll('.sort-arrow > i').forEach(i => {
      i.classList.remove('fa-caret-up', 'fa-caret-down');
    });

    currentIcon.classList.add(wasAsc ? 'fa-caret-up' : 'fa-caret-down');
    const sort_direction = wasAsc ? 'desc' : 'asc';

    this.sortTable(table, this.currentColumnIndex(th), sort_direction);
  }

  sortTable(table, column_idx, sort_direction) {
    const result = Array.prototype.slice.call(table.querySelectorAll('tbody>tr')).sort((a, b) => {
      const el1 = a.querySelector(`td:nth-child(${column_idx + 1})`);
      const el2 = b.querySelector(`td:nth-child(${column_idx + 1})`);
      let val1 = el1.getAttribute('sort_by') || el1.innerHTML;
      let val2 = el2.getAttribute('sort_by') || el2.innerHTML;
      if (isNaN(val1) || isNaN(val2)) {
        return (sort_direction === 'desc' ? -1 : 1) * val1.localeCompare(val2);
      }
      val1 = parseInt(val1);
      val2 = parseInt(val2);
      return sort_direction === 'desc' ? val2 - val1 : val1 - val2;
    });

    const tableBody = table.querySelector('tbody');
    tableBody.innerHTML = '';
    result.forEach(row => tableBody.appendChild(row));
  }

  currentColumnIndex(cell) {
    const columns = Array.prototype.slice.call(this.element.cells);
    return columns.indexOf(cell);
  }
}
