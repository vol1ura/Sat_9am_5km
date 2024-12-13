import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"
import EventCharts from "charts/event"
import { ruLocale } from "charts/ru"

// Connects to data-controller="event"
export default class extends Controller {
  initialize() {
    Apex.chart = { locales: [ruLocale], defaultLocale: 'ru' };

    const lastActivities = document.querySelectorAll("tbody tr.not-collapse");
    const eventCharts = new EventCharts(lastActivities);
    const resultsCountChart = new ApexCharts(
      document.getElementById("results-count-chart"),
      eventCharts.chartOptions("results-count-chart", "Участники", "results_count")
    );
    resultsCountChart.render();
    const volunteersCountChart = new ApexCharts(
      document.getElementById("volunteers-count-chart"),
      eventCharts.chartOptions("volunteers-count-chart", "Волонтёры", "volunteers_count")
    );
    volunteersCountChart.render();
  }
}
