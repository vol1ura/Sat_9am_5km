import { Controller } from '@hotwired/stimulus';
import AthleteCharts from 'charts/athlete';

// Connects to data-controller="athlete"
export default class extends Controller {
  static targets = ['results', 'positions'];
  static values = {
    categories: Array,
    counts: Array,
  };

  connect() {
    const rows = this.hasResultsTarget ? document.querySelectorAll('#panel-results tr.result') : [];
    const charts = new AthleteCharts(rows);

    if (this.hasResultsTarget && rows.length > 0) {
      this.resultsChart = charts.render(this.resultsTarget);
    }

    if (this.hasPositionsTarget && this.countsValue.length > 0) {
      this.positionsChart = charts.renderPositions(this.positionsTarget, {
        categories: this.categoriesValue,
        counts: this.countsValue,
      });
    }
  }

  disconnect() {
    this.resultsChart?.destroy();
    this.positionsChart?.destroy();
    this.resultsChart = null;
    this.positionsChart = null;

    if (this.hasResultsTarget) this.resultsTarget.innerHTML = '';
    if (this.hasPositionsTarget) this.positionsTarget.innerHTML = '';
  }
}
