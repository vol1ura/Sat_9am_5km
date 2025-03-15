import { Controller } from '@hotwired/stimulus'
import ApexCharts from 'apexcharts'
import AthleteCharts from 'charts/athlete'
import { ruLocale } from 'charts/ru'

// Connects to data-controller="athlete"
export default class extends Controller {
  static targets = ['results', 'eventsCount', 'eventsWhiskers']

  connect() {
    Apex.chart = { locales: [ruLocale], defaultLocale: 'ru' }
    const athleteCharts = new AthleteCharts(document.querySelectorAll('tr.result'))

    if (this.hasResultsTarget) {
      const resultsChart = new ApexCharts(
        this.resultsTarget,
        athleteCharts.resultsChartOptions('Недавние результаты', { max_count: 15 })
      )
      resultsChart.render()
    }

    if (this.hasEventsCountTarget) {
      const eventsCountChart = new ApexCharts(
        this.eventsCountTarget,
        athleteCharts.eventsChartOptions('Количество забегов')
      )
      eventsCountChart.render()
    }

    if (this.hasEventsWhiskersTarget) {
      const eventsWhiskersChart = new ApexCharts(
        this.eventsWhiskersTarget,
        athleteCharts.eventsWhiskersOptions('Статистика')
      )
      eventsWhiskersChart.render()
    }
  }

  disconnect() {
    if (this.hasResultsTarget) this.resultsTarget.innerHTML = ''
    if (this.hasEventsCountTarget) this.eventsCountTarget.innerHTML = ''
    if (this.hasEventsWhiskersTarget) this.eventsWhiskersTarget.innerHTML = ''
  }
}
