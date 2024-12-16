import { Controller } from '@hotwired/stimulus'
import ApexCharts from 'apexcharts'
import EventCharts from 'charts/event'
import { ruLocale } from 'charts/ru'

// Connects to data-controller="event"
export default class extends Controller {
  static targets = ['results', 'volunteers']

  connect() {
    Apex.chart = { locales: [ruLocale], defaultLocale: 'ru' }
    const lastActivities = document.querySelectorAll('tbody tr.not-collapse')
    const eventCharts = new EventCharts(lastActivities)

    const resultsCountChart = new ApexCharts(
      this.resultsTarget,
      eventCharts.chartOptions('results-count-chart', 'Участники', 'results_count')
    )
    resultsCountChart.render()
    const volunteersCountChart = new ApexCharts(
      this.volunteersTarget,
      eventCharts.chartOptions('volunteers-count-chart', 'Волонтёры', 'volunteers_count')
    )
    volunteersCountChart.render()
  }

  disconnect() {
    this.resultsTarget.innerHTML=''
    this.volunteersTarget.innerHTML=''
  }
}
