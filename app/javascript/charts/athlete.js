import ApexCharts from 'apexcharts';
import { ruLocale } from 'charts/ru';
import { srLocale } from 'charts/sr';
import { apexThemeOptions, chartAccentColor, chartLayoutPadding } from 'charts/theme';

const translations = {
  ru: {
    recentResults: 'Недавние результаты',
    time: 'время',
  },
  sr: {
    recentResults: 'Nedavni rezultati',
    time: 'vreme',
  },
  en: {
    recentResults: 'Recent results',
    time: 'time',
  },
};

export default class AthleteCharts {
  constructor(rows) {
    this.rows = rows;
    const lang = document.documentElement.lang;
    this.currentLocale = translations[lang] ? lang : 'ru';
    this.t = translations[this.currentLocale];
  }

  render(container) {
    Apex.chart = {
      locales: [ruLocale, srLocale],
      defaultLocale: this.currentLocale,
    };

    const resultsChart = new ApexCharts(container, this.#resultsChartOptions({ max_count: 15 }));
    resultsChart.render();
  }

  #resultsData(max_count) {
    const points = [];
    const labels = [];

    Array.prototype.slice.call(this.rows, 0, max_count).forEach(row => {
      const time_cell = row.querySelector('td.total-time');
      labels.push(time_cell.textContent);
      points.push([
        Number(time_cell.dataset.timestamp),
        Number(time_cell.dataset.sec)
      ]);
    });

    return { points, labels };
  }

  #secondsFormatter(seconds) {
    return `${Math.floor(seconds / 60)}:${('00' + seconds % 60).slice(-2)}`;
  }

  #resultsChartOptions({ max_count = undefined } = {}) {
    const data = this.#resultsData(max_count);
    const { theme, foreColor, axisLabels } = apexThemeOptions();
    const accent = chartAccentColor();
    const layout = chartLayoutPadding();

    return {
      ...layout,
      chart: {
        ...layout.chart,
        id: 'athlete-results-chart',
        height: 320,
        width: '100%',
        type: 'area',
        background: 'transparent',
        foreColor,
        animations: {
          initialAnimation: {
            enabled: false
          }
        },
        zoom: {
          enabled: false
        }
      },
      stroke: {
        curve: 'smooth',
        width: 2,
      },
      fill: {
        type: 'gradient',
        gradient: {
          shadeIntensity: 0.3,
          opacityFrom: 0.42,
          opacityTo: 0.08,
          stops: [0, 90, 100],
        },
      },
      plotOptions: {
        area: {
          fillTo: 'end',
        }
      },
      series: [{
        name: this.t.time,
        data: data.points
      }],
      xaxis: {
        type: 'datetime',
        labels: axisLabels,
      },
      yaxis: {
        reversed: true,
        opposite: true,
        labels: {
          ...axisLabels,
          formatter: this.#secondsFormatter
        }
      },
      tooltip: {
        shared: false,
        followCursor: true,
        y: {
          formatter: this.#secondsFormatter
        }
      },
      theme,
      colors: [accent],
      title: { show: false },
      dataLabels: {
        enabled: true,
        formatter: (_, opt) => data.labels[opt.dataPointIndex]
      }
    };
  }
}
