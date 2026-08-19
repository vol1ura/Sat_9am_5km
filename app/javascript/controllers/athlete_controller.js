import { Controller } from '@hotwired/stimulus';
import AthleteCharts from 'charts/athlete';

// Connects to data-controller="athlete"
export default class extends Controller {
  static targets = ['results'];

  connect() {
    if (!this.hasResultsTarget) return;

    const rows = document.querySelectorAll('#panel-results tr.result');
    if (rows.length === 0) return;

    this.chart = new AthleteCharts(rows);
    this.chart.render(this.resultsTarget);
  }

  disconnect() {
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = '';
    }
  }
}
