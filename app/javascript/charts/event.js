import ApexCharts from 'apexcharts'
import { ruLocale } from 'charts/ru'
import { rsLocale } from 'charts/rs'

const translations = {
  ru: {
    participants: 'Участники',
    volunteers: 'Волонтёры',
    count: 'Количество',
  },
  rs: {
    participants: 'Učesnici',
    volunteers: 'Vlontori',
    count: 'Broj',
  },
}

export default class EventCharts {
  constructor(rows) {
    this.rows = rows;
    this.eventsData = {};
    this.currentLocale = document.documentElement.lang === 'rs' ? 'rs' : 'ru'
    this.t = translations[this.currentLocale]

    Apex.chart = { locales: [ruLocale, rsLocale], defaultLocale: this.currentLocale }
  }

  initializeCharts(resultsTarget, volunteersTarget) {
    if (resultsTarget) {
      const chart = new ApexCharts(resultsTarget, this.#chartOptions('results-count-chart', this.t.participants, 'results_count'))
      chart.render()
    }

    if (volunteersTarget) {
      const chart = new ApexCharts(volunteersTarget, this.#chartOptions('volunteers-count-chart', this.t.volunteers, 'volunteers_count'))
      chart.render()
    }
  }

  get #eventsData() {
    if (Object.keys(this.eventsData).length === 0) {
      this.rows.forEach(row => {
        this.eventsData[row.querySelector('td.date').dataset.date] = {
          results_count: Number(row.querySelector('td.results_count').textContent),
          volunteers_count: Number(row.querySelector('td.volunteers_count').textContent),
        };
      });
    }
    return this.eventsData;
  }

  #chartOptions(chartId, title, valueClass) {
    return {
      chart: {
        id: chartId,
        group: 'sparklines',
        type: 'area',
        height: 200,
        sparkline: {
          enabled: true
        },
      },
      stroke: {
        curve: 'straight'
      },
      fill: {
        opacity: 1,
      },
      series: [{
        name: this.t.count,
        data: Object.values(this.#eventsData).map(data => data[valueClass])
      }],
      labels: Object.keys(this.#eventsData),
      yaxis: {
        min: 0
      },
      xaxis: {
        type: 'datetime',
      },
      colors: ['#DCE6EC'],
      title: {
        text: title,
        offsetX: 30,
        style: {
          fontSize: '16px',
        }
      }
    };
  }
}
