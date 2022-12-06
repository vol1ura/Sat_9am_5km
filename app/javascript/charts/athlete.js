export default class AthleteCharts {
  constructor(rows) {
    this.rows = rows
  }

  get #eventsData() {
    const events = {}
    this.rows.forEach(row => {
      const event = row.querySelector(".event-name").textContent
      events[event] = 1 + (events[event] || 0)
    })
    return events
  }

  get #eventsResultsData() {
    const data = {}
    this.rows.forEach(row => {
      const event = row.querySelector(".event-name").textContent
      const timestamp = Number(row.querySelector(".total-time").getAttribute("min"))
      data[event] = data[event] ? [...data[event], timestamp] : [timestamp]
    })

    const asc = arr => arr.sort((a, b) => a - b)
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
    }

    Object.keys(data).forEach(event => {
      const results = data[event]
      data[event] = [
        Math.min(...results),
        quantile(results, .25),
        quantile(results, .50),
        quantile(results, .75),
        Math.max(...results)
      ]
    })
    return data
  }

  get #resultsData() {
    const points = []
    const labels = []
    this.rows.forEach(row => {
      const time_cell = row.querySelector(".total-time")
      labels.push(time_cell.textContent)
      points.push([
        Number(row.querySelector(".event-date").getAttribute("timestamp")),
        Number(time_cell.getAttribute("min"))
      ])
    })
    return { points, labels }
  }

  get eventsChartOptions() {
    const events = this.#eventsData
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
        text: 'Количество забегов',
        align: 'center'
      },
      plotOptions: {
        bar: {
          columnWidth: '45%',
          distributed: true,
        }
      },
      dataLabels: {
        enabled: false
      },
      legend: {
        show: false
      },
      xaxis: {
        categories: Object.keys(events)
      },
      yaxis: {
        tickAmount: 1
      },
      theme: {
        palette: 'palette2'
      }
    }
  }

  get resultsChartOptions() {
    const data = this.#resultsData
    return {
      chart: {
        height: 300,
        width: "100%",
        type: "area",
        animations: {
          initialAnimation: {
            enabled: false
          }
        }
      },
      fill: {
        type: 'gradient'
      },
      series: [{
        name: "время",
        data: data.points
      }],
      xaxis: {
        type: 'datetime'
      },
      yaxis: {
        labels: {
          formatter: val => (val / 60).toFixed(0)
        }
      },
      tooltip: {
        shared: false,
        y: {
          formatter: val => `${(val / 60).toFixed(0)}:${val % 60}`
        }
      },
      theme: {
        palette: 'palette2'
      },
      title: {
        text: 'Динамика результатов',
        align: 'center',
        style: {
          fontSize: '14px'
        }
      },
      dataLabels: {
        enabled: true,
        formatter: (_, opt) => data.labels[opt.dataPointIndex]
      }
    }
  }

  get eventsWhiskersOptions() {
    const data = this.#eventsResultsData
    return {
      series: [
        {
          type: 'boxPlot',
          data: Object.keys(data).map(event => {
            return {
              x: event,
              y: data[event]
            }
          })
        }
      ],
      chart: {
        type: 'boxPlot',
        height: 300
      },
      title: {
        text: 'Статистика',
        align: 'center'
      },
      yaxis: {
        title: {
          text: 'Время (минуты)'
        },
        labels: {
          formatter: val => (val / 60).toFixed(0)
        }
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
