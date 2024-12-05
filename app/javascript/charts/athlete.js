export default class AthleteCharts {
  constructor(rows) {
    this.rows = rows;
  }

  get #eventsData() {
    const events = {};
    this.rows.forEach(row => {
      const event = row.querySelector("td.event-name").textContent;
      events[event] = 1 + (events[event] || 0);
    });
    return events;
  }

  get #eventsResultsData() {
    const data = {};
    this.rows.forEach(row => {
      const event = row.querySelector("td.event-name").textContent;
      const total_time = Number(row.querySelector("td.total-time").dataset.min);
      data[event] = data[event] ? [...data[event], total_time] : [total_time];
    });

    const asc = arr => arr.sort((a, b) => a - b);
    const quantile = (arr, q) => {
      const sorted = asc(arr);
      const pos = (sorted.length - 1) * q;
      const base = Math.floor(pos);
      const rest = pos - base;
      if (sorted[base + 1] !== undefined) {
        return sorted[base] + rest * (sorted[base + 1] - sorted[base]);
      } else {
        return sorted[base];
      }
    };

    Object.keys(data).forEach(event => {
      const results = data[event];
      data[event] = [
        Math.min(...results),
        quantile(results, 0.25),
        quantile(results, 0.50),
        quantile(results, 0.75),
        Math.max(...results)
      ];
    });
    return data;
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

  eventsChartOptions(title) {
    const events = this.#eventsData;
    return {
      series: [{
        name: 'забегов',
        data: Object.values(events)
      }],
      chart: {
        type: 'bar',
        height: 300
      },
      title: {
        text: title,
        align: 'center'
      },
      plotOptions: {
        bar: {
          columnWidth: '45%',
          distributed: true,
        }
      },
      dataLabels: {
        enabled: true,
        offsetY: 10,
        style: {
          colors: ['#333']
        }
      },
      legend: {
        show: false
      },
      xaxis: {
        categories: Object.keys(events),
        labels: {
          hideOverlappingLabels: false,
          rotateAlways: true
        }

      },
      yaxis: {
        tickAmount: 1
      },
      theme: {
        palette: 'palette2'
      }
    };
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

  eventsWhiskersOptions(title) {
    const data = this.#eventsResultsData;
    return {
      series: [
        {
          type: 'boxPlot',
          data: Object.keys(data).map(event => {
            return {
              x: event,
              y: data[event]
            };
          })
        }
      ],
      chart: {
        type: 'boxPlot',
        height: 300,
        toolbar: {
          show: true,
          tools: {
            download: true,
            selection: false,
            zoom: false,
            zoomin: false,
            zoomout: false,
            pan: false,
            reset: false
          }
        }
      },
      title: {
        text: title,
        align: 'center'
      },
      xaxis: {
        labels: {
          hideOverlappingLabels: false,
          rotateAlways: true
        }
      },
      yaxis: {
        title: {
          text: 'Время'
        },
        labels: {
          formatter: this.#secondsFormatter
        }
      },
      tooltip: {
        enabled: false
      },
      plotOptions: {
        boxPlot: {
          colors: {
            upper: '#5C4742',
            lower: '#A5978B'
          }
        }
      }
    }
  }
}
