import { Controller } from '@hotwired/stimulus';
import { renderPieChart } from 'charts/pie';

// Connects to data-controller="pie-chart"
export default class extends Controller {
  static values = {
    series: Array,
    labels: Array,
    chartId: String,
    unit: String,
    totalLabel: String,
    error: String,
    title: String,
    height: { type: Number, default: 240 },
    showCountInLegend: Boolean,
  };

  connect() {
    if (!this.seriesValue.length) return;

    try {
      this.chart = renderPieChart(this.element, {
        series: this.seriesValue,
        labels: this.labelsValue,
        chartId: this.chartIdValue,
        unit: this.unitValue,
        totalLabel: this.totalLabelValue,
        height: this.heightValue,
        title: this.titleValue || undefined,
        showCountInLegend: this.showCountInLegendValue,
      });
    } catch (error) {
      console.error('Error rendering pie chart:', error);
      this.#showError();
    }
  }

  disconnect() {
    this.chart?.destroy();
    this.chart = null;
  }

  #showError() {
    this.element.innerHTML = `
      <p class="rounded-md border border-warning/30 bg-warning-subtle px-3 py-2 text-sm text-warning-fg" role="alert">
        <i class="fa fa-exclamation-triangle"></i>
        ${this.errorValue}
      </p>
    `;
  }
}
