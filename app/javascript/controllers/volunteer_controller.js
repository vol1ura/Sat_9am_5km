import { Controller } from '@hotwired/stimulus'
import ApexCharts from 'apexcharts'
import { ruLocale } from 'charts/ru'
import { rsLocale } from 'charts/rs'

// Connects to data-controller="volunteer"
export default class extends Controller {
  static targets = ['data', 'chart']

  connect() {
    this.volunteeringChartRendered = false

    if (this.hasChartTarget) {
      this.#initializeVolunteeringChart()
    }
  }

  disconnect() {
    if (this.hasChartTarget) {
      this.chartTarget.innerHTML = ''
    }
  }

  #initializeVolunteeringChart() {
    const isVisible = this.chartTarget.offsetParent !== null;

    if (isVisible && !this.volunteeringChartRendered) {
      this.#renderVolunteeringChart()
    } else if (!isVisible) {
      const accordionCollapse = document.querySelector('#flush-collapseTotalVolunteering')
      accordionCollapse?.addEventListener('shown.bs.collapse', this.#renderVolunteeringChart.bind(this))
      }
  }

  #renderVolunteeringChart() {
    if (this.volunteeringChartRendered || !this.hasChartTarget || this.dataTargets.length === 0) {
      return
    }

    try {
      const currentLocale = document.documentElement.lang === 'rs' ? rsLocale : ruLocale
      this.volunteeringChart = new ApexCharts(
        this.chartTarget,
        this.#chartOptions('Недавние волонтёрства', currentLocale.options.shortMonths)
      )
      this.volunteeringChart.render()
      this.volunteeringChartRendered = true
    } catch (error) {
      console.error('Ошибка создания диаграммы волонтёрств:', error)
    }
  }

  #chartOptions(title, months) {
    const currentMonthIndex = new Date().getMonth(); // 0-11
    const categories = []

    for (let i = 5; i >= 0; i--) {
      const monthIndex = (currentMonthIndex - i + 12) % 12
      categories.push(months[monthIndex])
    }

    const series = []
    const rows = this.dataTargets
    rows.forEach(row => {
      const role = row.querySelector('th').textContent
      const data = []
      row.querySelectorAll('td').forEach(td => {
        data.push(td.textContent.trim())
      })
      series.push({
        name: role,
        data: data
      })
    })

    return {
      series,
      chart: {
      type: 'bar',
      height: 350,
      stacked: true,
      toolbar: {
        show: false
      },
      zoom: {
        enabled: false
      }
    },
    title: {
      text: title,
      floating: true,
      align: 'center',
    },
    dataLabels: {
      enabled: false
    },
    responsive: [{
      breakpoint: 720,
      options: {
        legend: {
          position: 'bottom',
          offsetX: -20,
          offsetY: 0
        }
      }
    }],
    plotOptions: {
      bar: {
        horizontal: false,
        borderRadius: 10,
        borderRadiusApplication: 'end', // 'around', 'end'
        borderRadiusWhenStacked: 'last', // 'all', 'last'
      },
    },
    xaxis: { categories },
    legend: {
      position: 'right',
      offsetY: 40
    },
    theme: {
      palette: 'palette2'
    },
    fill: {
      opacity: 0.85
    }
    }
  }
}
