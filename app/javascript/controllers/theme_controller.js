import { Controller } from '@hotwired/stimulus';
import {
  CHART_IDS,
  accentChartThemeUpdateOptions,
  heatmapThemeUpdateOptions,
  sparklineThemeUpdateOptions,
  themeUpdateOptions,
} from 'charts/theme';

const STORAGE_KEY = 's95_theme';

const SPARKLINE_CHARTS = {
  'results-count-chart': 0,
  'volunteers-count-chart': 1,
};

export default class extends Controller {
  toggle() {
    const next = document.documentElement.classList.contains('dark') ? 'light' : 'dark';
    localStorage.setItem(STORAGE_KEY, next);
    this.applyTheme(next);
    this.updateCharts();
  }

  applyTheme(mode) {
    document.documentElement.classList.toggle('dark', mode === 'dark');
  }

  async updateCharts() {
    const { default: ApexCharts } = await import('apexcharts');
    const baseOptions = themeUpdateOptions();

    CHART_IDS.forEach((chartId) => {
      let chartOptions = baseOptions;

      if (chartId in SPARKLINE_CHARTS) {
        chartOptions = sparklineThemeUpdateOptions(SPARKLINE_CHARTS[chartId]);
      } else if (chartId === 'athlete-results-chart') {
        chartOptions = accentChartThemeUpdateOptions();
      } else if (chartId === 'h-index-chart') {
        chartOptions = heatmapThemeUpdateOptions();
      }

      ApexCharts.exec(chartId, 'updateOptions', chartOptions, false, true);
    });
  }
}
