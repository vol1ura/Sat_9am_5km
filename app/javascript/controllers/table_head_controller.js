import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="table-head"
export default class extends Controller {
  toggleSort(e) {
    const tumblers = e.target.closest('tr').querySelectorAll('i.bi')
    Array.prototype.slice.call(tumblers).forEach(cell => {
      cell.classList.remove('bi-caret-up')
      cell.classList.remove('bi-caret-down')
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
          this.currentColumn(e.target.closest('td')),
          sort_direction
        )
        return
      }
      cell.classList.remove('bi-caret-down-fill')
      cell.classList.remove('bi-caret-up-fill')
      cell.classList.add('bi-caret-up')
    })
  }

  sortTable(table, column_idx, sort_direction) {
    const result = Array.prototype.slice.call(table.querySelectorAll('tbody>tr')).sort((a, b) => {
      const val1 = parseInt(a.querySelector(`td:nth-child(${column_idx + 1})`).innerHTML)
      const val2 = parseInt(b.querySelector(`td:nth-child(${column_idx + 1})`).innerHTML)
      return sort_direction == 'desc' ? val1 > val2 : val1 < val2
    })
    const table_body = table.querySelector('tbody')
    table_body.innerHTML = ''
    result.forEach(row => table_body.appendChild(row))
  }

  currentColumn(cell) {
    const columns = Array.prototype.slice.call(cell.closest('tr').cells)
    return columns.indexOf(cell)
  }
}
