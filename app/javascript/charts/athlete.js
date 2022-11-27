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
        data: Object.values(events)
      }],
      chart: {
        type: 'bar',
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
        name: "время, мин.",
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
}
