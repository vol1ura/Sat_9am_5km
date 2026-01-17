import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  async toggle() {
    const currentTheme = document.documentElement.getAttribute('data-bs-theme') || 'light';
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';
    document.documentElement.setAttribute('data-bs-theme', newTheme);
    localStorage.setItem('s95_theme', newTheme);

    const event_charts = document.querySelector('div[data-controller="event"]');
    if (!event_charts) return;

    const { default: ApexCharts } = await import('apexcharts');
    ['results-count-chart', 'volunteers-count-chart'].forEach(chartId => {
      ApexCharts.exec(chartId, 'updateOptions', {
        theme: {
          mode: newTheme,
        },
        colors: [newTheme === 'dark' ? '#4a5568' : '#dce6ec'],
      }, false, true);
    });
  }
}
