export default class EventCharts {
  constructor(rows) {
    this._rows = rows;
    this._eventsData = {};
  }

  get #eventsData() {
    if (Object.keys(this._eventsData).length === 0) {
      this._rows.forEach(row => {
        this._eventsData[row.querySelector('td.date').dataset.date] = {
          results_count: Number(row.querySelector('td.results_count').textContent),
          volunteers_count: Number(row.querySelector('td.volunteers_count').textContent),
        };
      });
    }
    return this._eventsData;
  }

  chartOptions(chartId, title, valueClass) {
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
        name: 'Количество',
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
