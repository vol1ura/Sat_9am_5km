import ApexCharts from 'apexcharts';
import { ruLocale } from 'charts/ru';
import { srLocale } from 'charts/sr';
import { AREA_ACCENT_FILL, apexThemeOptions, barChartOptions, chartAccentColor, chartLayoutPadding, formatCount, formatMmSs } from 'charts/theme';

const translations = {
  ru: {
    time: 'время',
    results: 'результаты',
    place: 'Место',
  },
  sr: {
    time: 'vreme',
    results: 'rezultati',
    place: 'Pozicija',
  },
  en: {
    time: 'time',
    results: 'results',
    place: 'Position',
  },
};

export default class AthleteCharts {
  constructor(rows = []) {
    this.rows = rows;
    const lang = document.documentElement.lang;
    this.currentLocale = translations[lang] ? lang : 'ru';
    this.t = translations[this.currentLocale];
  }

  #applyLocale() {
    Apex.chart = {
      locales: [ruLocale, srLocale],
      defaultLocale: this.currentLocale,
    };
  }

  render(container) {
    this.#applyLocale();
    const resultsChart = new ApexCharts(container, this.#resultsChartOptions({ max_count: 15 }));
    resultsChart.render();
    return resultsChart;
  }

  renderPositions(container, { categories, counts }) {
    this.#applyLocale();
    const chart = new ApexCharts(container, this.#positionsChartOptions(categories, counts));
    chart.render();
    return chart;
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
      fill: AREA_ACCENT_FILL,
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
          formatter: formatMmSs,
        }
      },
      tooltip: {
        shared: false,
        followCursor: true,
        y: {
          formatter: formatMmSs,
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

  #positionsChartOptions(categories, counts) {
    const { foreColor } = apexThemeOptions();

    return barChartOptions({
      id: 'athlete-positions-chart',
      height: 320,
      series: [{
        name: this.t.results,
        data: counts,
      }],
      grid: {
        padding: { top: 24 },
      },
      plotBar: {
        dataLabels: { position: 'top' },
      },
      title: { show: false },
      dataLabels: {
        enabled: true,
        offsetY: -20,
        formatter: formatCount,
        style: {
          fontSize: '12px',
          colors: [foreColor],
        },
      },
      xaxis: {
        type: 'category',
        categories: categories.map(String),
        title: { text: this.t.place },
      },
      yaxis: {
        min: 0,
        labels: {
          formatter: formatCount,
        },
      },
      legend: { show: false },
      colors: [chartAccentColor()],
      tooltip: {
        x: {
          formatter: (val) => `${this.t.place}: ${val}`,
        },
        y: {
          formatter: formatCount,
        },
      },
    });
  }
}
