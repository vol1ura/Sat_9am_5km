import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleSort(e) {
    e.target.closest('tr').querySelectorAll('i.fa').forEach(cell => {
      cell.classList.remove('fa-angle-up', 'fa-angle-down')
      if (cell == e.target) {
        let sort_direction = 'asc'
        if (cell.classList.contains('fa-caret-up')) {
          cell.classList.remove('fa-caret-up')
          cell.classList.add('fa-caret-down')
          sort_direction = 'desc'
        } else {
          cell.classList.remove('fa-caret-down')
          cell.classList.add('fa-caret-up')
        }
        this.sortTable(
          e.target.closest('table'),
          this.currentColumnIndex(e.target.closest('th')),
          sort_direction
        )
        return
      }
      cell.classList.remove('fa-caret-down', 'fa-caret-up')
      cell.classList.add('fa-angle-up')
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
