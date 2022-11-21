import { Controller } from "@hotwired/stimulus"
import ApexCharts from 'apexcharts'
import ActivityCharts from "../charts/activity"

// Connects to data-controller="protocol"
export default class extends Controller {
  static targets = ["absolute", "male", "female"]

  initialize() {
    this.maleTarget.innerHTML = this.absoluteTarget.innerHTML
    this.filterTableByMale(this.maleTarget, 'true')
    this.femaleTarget.innerHTML = this.absoluteTarget.innerHTML
    this.filterTableByMale(this.femaleTarget, 'false')
    const activityCharts = new ActivityCharts(this.absoluteTarget.querySelectorAll('tbody tr'))
    const genderChart = new ApexCharts(document.querySelector("#chart-gender"), activityCharts.genderDonutOptions)
    genderChart.render()
    const clubsChart = new ApexCharts(document.querySelector("#chart-clubs"), activityCharts.clubsBarOptions)
    clubsChart.render()
  }

  filterTableByMale(table, is_male) {
    let new_position = 0
    table.querySelectorAll('tbody tr').forEach(row => {
      if (row.dataset.male !== is_male) {
        row.parentNode.removeChild(row)
      } else {
        row.querySelector('.position').innerText = ++new_position
      }
    })
  }
}
