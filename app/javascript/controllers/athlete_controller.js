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

    const eventsCountChart = new ApexCharts(
      this.eventsCountTarget,
      athleteCharts.eventsChartOptions('Количество забегов')
    )
    eventsCountChart.render()

    const eventsWhiskersChart = new ApexCharts(
      this.eventsWhiskersTarget,
      athleteCharts.eventsWhiskersOptions('Статистика')
    )
    eventsWhiskersChart.render()

    const resultsChart = new ApexCharts(
      this.resultsTarget,
      athleteCharts.resultsChartOptions('Недавние результаты', { max_count: 15 })
    )
    resultsChart.render()
  }

  disconnect() {
    this.resultsTarget.innerHTML = ''
    this.eventsCountTarget.innerHTML = ''
    this.eventsWhiskersTarget.innerHTML = ''
  }
}
