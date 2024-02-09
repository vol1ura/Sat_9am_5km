import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleSort(e) {
    e.target.closest('tr').querySelectorAll('i.bi').forEach(cell => {
      cell.classList.remove('bi-caret-up', 'bi-caret-down')
      if (cell == e.target) {
        let sort_direction = 'asc'
        if (cell.classList.contains('bi-caret-up-fill')) {
          cell.classList.remove('bi-caret-up-fill')
          cell.classList.add('bi-caret-down-fill')
          sort_direction = 'desc'
        } else {
          cell.classList.remove('bi-caret-down-fill')
          cell.classList.add('bi-caret-up-fill')
        }
        this.sortTable(
          e.target.closest('table'),
          this.currentColumnIndex(e.target.closest('th')),
          sort_direction
        )
        return
      }
      cell.classList.remove('bi-caret-down-fill', 'bi-caret-up-fill')
      cell.classList.add('bi-caret-up')
    })
  }

  sortTable(table, column_idx, sort_direction) {
    const result = Array.prototype.slice.call(table.querySelectorAll('tbody>tr')).sort((a, b) => {
      let val1 = a.querySelector(`td:nth-child(${column_idx + 1})`).innerHTML
      let val2 = b.querySelector(`td:nth-child(${column_idx + 1})`).innerHTML
      if (isNaN(val1) || isNaN(val2)) {
        return (sort_direction == 'desc' ? 1 : -1) * val1.localeCompare(val2)
      }
      val1 = parseInt(val1)
      val2 = parseInt(val2)
      return sort_direction == 'desc' ? val1 - val2 : val2 - val1
    })
    const table_body = table.querySelector('tbody')
    table_body.innerHTML = ''
    result.forEach(row => table_body.appendChild(row))
  }

  currentColumnIndex(cell) {
    const columns = Array.prototype.slice.call(cell.closest('tr').cells)
    return columns.indexOf(cell)
  }
}
