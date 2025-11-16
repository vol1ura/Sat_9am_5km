import { Controller } from '@hotwired/stimulus';
import EventCharts from 'charts/event';

// Connects to data-controller="event"
export default class extends Controller {
  static targets = ['results', 'volunteers'];

  connect() {
    const eventCharts = new EventCharts(document.querySelectorAll('tbody tr.not-collapse'));

    eventCharts.initializeCharts(this.resultsTarget, this.volunteersTarget);
  }

  disconnect() {
    this.resultsTarget.innerHTML = '';
    this.volunteersTarget.innerHTML = '';
  }
}
