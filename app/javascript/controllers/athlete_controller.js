import { Controller } from '@hotwired/stimulus';
import AthleteCharts from 'charts/athlete';

// Connects to data-controller="athlete"
export default class extends Controller {
  static targets = ['results'];

  connect() {
    if (this.hasResultsTarget) {
      const athleteCharts = new AthleteCharts(document.querySelectorAll('tr.result'));
      athleteCharts.render(this.resultsTarget);
    }
  }

  disconnect() {
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = '';
    }
  }
}
