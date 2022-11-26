import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"

// Connects to data-controller="athlete"
export default class extends Controller {
  connect() {
    let events = {}
    document.querySelectorAll(".event-name").forEach(cell => {
      events[cell.textContent] = 1 + (events[cell.textContent] || 0)
    })

    const eventsCountChart = new ApexCharts(
      document.querySelector("#chart-events-count"),
      {
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
        }
      }
    )
    eventsCountChart.render()
  }
}
