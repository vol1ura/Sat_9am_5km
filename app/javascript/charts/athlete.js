export default class AthleteCharts {
  constructor(rows) {
    this.rows = rows;
  }

  #resultsData(max_count) {
    const points = [];
    const labels = [];

    Array.prototype.slice.call(this.rows, 0, max_count).forEach(row => {
      const time_cell = row.querySelector("td.total-time");
      labels.push(time_cell.textContent);
      points.push([
        Number(time_cell.dataset.timestamp),
        Number(time_cell.dataset.min)
      ]);
    });

    return { points, labels };
  }

  #secondsFormatter(seconds) {
    return `${Math.floor(seconds / 60)}:${('00' + seconds % 60).slice(-2)}`;
  }

  resultsChartOptions(title, { max_count = undefined } = {}) {
    const data = this.#resultsData(max_count);
    return {
      chart: {
        height: 300,
        width: '100%',
        type: 'area',
        animations: {
          initialAnimation: {
            enabled: false
          }
        },
        zoom: {
          enabled: false
        }
      },
      fill: {
        type: 'gradient'
      },
      plotOptions: {
        area: {
          fillTo: 'end',
        }
      },
      series: [{
        name: 'время',
        data: data.points
      }],
      xaxis: {
        type: 'datetime'
      },
      yaxis: {
        reversed: true,
        opposite: true,
        labels: {
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
      theme: {
        palette: 'palette2'
      },
      title: {
        text: title,
        align: 'center',
      },
      dataLabels: {
        enabled: true,
        formatter: (_, opt) => data.labels[opt.dataPointIndex]
      }
    }
  }
}
