import ApexCharts from 'apexcharts';
import { ruLocale } from 'charts/ru';
import { srLocale } from 'charts/sr';
import { apexThemeOptions, chartSparklineColors, chartTitleOptions } from 'charts/theme';

const translations = {
  ru: {
    participants: 'Участники',
    volunteers: 'Волонтёры',
    count: 'Количество',
  },
  sr: {
    participants: 'Učesnici',
    volunteers: 'Vlontori',
    count: 'Broj',
  },
  en: {
    participants: 'Participants',
    volunteers: 'Volunteers',
    count: 'Count',
  },
};

export default class EventCharts {
  constructor(rows) {
    this.rows = rows;
    this.eventsData = {};
    const lang = document.documentElement.lang;
    this.currentLocale = translations[lang] ? lang : 'ru';
    this.t = translations[this.currentLocale];

    Apex.chart = { locales: [ruLocale, srLocale], defaultLocale: this.currentLocale };
  }

  initializeCharts(resultsTarget, volunteersTarget) {
    if (resultsTarget) {
      const chart = new ApexCharts(resultsTarget, this.#chartOptions('results-count-chart', this.t.participants, 'results_count', 0));
      chart.render();
    }

    if (volunteersTarget) {
      const chart = new ApexCharts(volunteersTarget, this.#chartOptions('volunteers-count-chart', this.t.volunteers, 'volunteers_count', 1));
      chart.render();
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

  #chartOptions(chartId, title, valueClass, sparklineIndex) {
    const { theme, foreColor, titleStyle } = apexThemeOptions();
    const sparklineColor = chartSparklineColors()[sparklineIndex] ?? chartSparklineColors()[0];

    return {
      chart: {
        id: chartId,
        group: 'sparklines',
        type: 'area',
        height: 200,
        background: 'transparent',
        foreColor,
        sparkline: {
          enabled: true
        },
      },
      stroke: {
        curve: 'straight',
        width: 2,
      },
      fill: {
        opacity: 0.45,
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
      colors: [sparklineColor],
      theme,
      title: chartTitleOptions(title, { offsetX: 30, style: { fontSize: '16px', color: titleStyle.color } }),
    };
  }
}
