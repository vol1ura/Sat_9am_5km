import { Controller } from '@hotwired/stimulus';
import {
  CHART_IDS,
  PIE_CHART_IDS,
  athleteResultsChartThemeUpdateOptions,
  barAccentChartThemeUpdateOptions,
  heatmapThemeUpdateOptions,
  volunteeringChartThemeUpdateOptions,
  pieChartThemeUpdateOptions,
  sparklineThemeUpdateOptions,
  themeUpdateOptions,
} from 'charts/theme';

const STORAGE_KEY = 's95_theme';

const SPARKLINE_CHARTS = ['results-count-chart', 'volunteers-count-chart'];

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

      if (SPARKLINE_CHARTS.includes(chartId)) {
        chartOptions = sparklineThemeUpdateOptions();
      } else if (chartId === 'athlete-results-chart') {
        chartOptions = athleteResultsChartThemeUpdateOptions();
      } else if (chartId === 'athlete-positions-chart') {
        chartOptions = barAccentChartThemeUpdateOptions();
      } else if (chartId === 'volunteering-chart') {
        chartOptions = volunteeringChartThemeUpdateOptions();
      } else if (chartId === 'h-index-chart') {
        chartOptions = heatmapThemeUpdateOptions();
      } else if (PIE_CHART_IDS.includes(chartId)) {
        chartOptions = pieChartThemeUpdateOptions();
      }

      ApexCharts.exec(chartId, 'updateOptions', chartOptions, false, true);
    });
  }
}
