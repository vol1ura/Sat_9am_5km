import { Controller } from '@hotwired/stimulus'
import ApexCharts from 'apexcharts'
import AthleteCharts from 'charts/athlete'
import { ruLocale } from 'charts/ru'
import { rsLocale } from 'charts/rs'

// Connects to data-controller="athlete"
export default class extends Controller {
  static targets = ['results']

  connect() {
    Apex.chart = {
      locales: [ruLocale, rsLocale],
      defaultLocale: document.documentElement.lang === 'rs' ? 'rs' : 'ru',
    }
    const athleteCharts = new AthleteCharts(document.querySelectorAll('tr.result'))

    if (this.hasResultsTarget) {
      const resultsChart = new ApexCharts(
        this.resultsTarget,
        athleteCharts.resultsChartOptions('Недавние результаты', { max_count: 15 })
      )
      resultsChart.render()
    }
  }

  disconnect() {
    if (this.hasResultsTarget) this.resultsTarget.innerHTML = ''
  }
}
