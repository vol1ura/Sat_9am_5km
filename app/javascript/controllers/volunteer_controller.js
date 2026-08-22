import { Controller } from '@hotwired/stimulus';
import ApexCharts from 'apexcharts';
import { ruLocale } from 'charts/ru';
import { srLocale } from 'charts/sr';
import { apexThemeOptions, chartHeatmapScale, chartLayoutPadding, chartTitleOptions } from 'charts/theme';

const translations = {
  ru: {
    recentVolunteering: 'Недавние волонтёрства',
  },
  sr: {
    recentVolunteering: 'Nedavno volontiranje',
  },
  en: {
    recentVolunteering: 'Recent volunteering',
  },
};

// Connects to data-controller="volunteer"
export default class extends Controller {
  static targets = ['data', 'chart', 'hdata', 'hchart'];

  connect() {
    if (this.hasChartTarget && this.dataTargets.length > 0) {
      this.#renderVolunteeringChart();
    }
    if (this.hasHchartTarget && this.hdataTargets.length > 0) {
      this.#renderHIndexChart();
    }
  }

  disconnect() {
    if (this.hasChartTarget) {
      if (this.volunteeringChart) {
        this.volunteeringChart.destroy();
      }
      this.chartTarget.innerHTML = '';
    }
    if (this.hasHchartTarget) {
      if (this.hIndexChart) {
        this.hIndexChart.destroy();
      }
      this.hchartTarget.innerHTML = '';
    }
  }

  #renderVolunteeringChart() {
    try {
      const currentLocale = document.documentElement.lang === 'sr' ? srLocale : ruLocale;
      this.volunteeringChart = new ApexCharts(
        this.chartTarget,
        this.#chartOptions(translations[currentLocale.name].recentVolunteering, currentLocale.options.shortMonths)
      );
      this.volunteeringChart.render();
    } catch (error) {
      console.error('Error creating volunteering chart:', error);
    }
  }

  #renderHIndexChart() {
    try {
      const target = Number(this.hchartTarget.dataset.hIndexTarget);
      const title = this.hchartTarget.dataset.hIndexTitle;
      const tooltipLabel = this.hchartTarget.dataset.hIndexTooltip;
      this.hIndexChart = new ApexCharts(
        this.hchartTarget,
        this.#heatmapOptions(title, tooltipLabel, target)
      );
      this.hIndexChart.render();
    } catch (error) {
      console.error('Error creating h-index chart:', error);
    }
  }

  #chartOptions(title, months) {
    const currentMonthIndex = new Date().getMonth(); // 0-11
    const categories = [];

    for (let i = 5; i >= 0; i--) {
      const monthIndex = (currentMonthIndex - i + 12) % 12;
      categories.push(months[monthIndex]);
    }

    const series = [];
    const rows = this.dataTargets;
    rows.forEach(row => {
      const role = row.querySelector('th').textContent;

      const data = [];
      row.querySelectorAll('td').forEach(td => data.push(td.textContent.trim()));

      series.push({
        name: role,
        data: data
      });
    });

    const { theme, colors, foreColor, legend, axisLabels } = apexThemeOptions();
    const layout = chartLayoutPadding();

    return {
      ...layout,
      series,
      chart: {
        ...layout.chart,
        id: 'volunteering-chart',
        type: 'bar',
        height: 380,
        stacked: true,
        background: 'transparent',
        foreColor,
        toolbar: {
          show: false
        },
        zoom: {
          enabled: false
        }
      },
      title: chartTitleOptions(title, { floating: false }),
      dataLabels: {
        enabled: false
      },
      responsive: [{
        breakpoint: 720,
        options: {
          legend: {
            position: 'bottom',
            offsetX: -20,
            offsetY: 0
          }
        }
      }],
      plotOptions: {
        bar: {
          horizontal: false,
          borderRadius: 10,
          borderRadiusApplication: 'end', // 'around', 'end'
          borderRadiusWhenStacked: 'last', // 'all', 'last'
        },
      },
      xaxis: { categories, labels: axisLabels },
      yaxis: {
        forceNiceScale: true,
        labels: axisLabels,
      },
      legend: {
        position: 'right',
        offsetY: 40,
        ...legend,
      },
      colors,
      theme,
      fill: {
        opacity: 0.72
      }
    };
  }

  #heatmapOptions(title, tooltipLabel, target) {
    const { theme, foreColor } = apexThemeOptions();
    const layout = chartLayoutPadding();
    const categories = Array.from({ length: target }, (_, idx) => (idx + 1).toString());
    const series = this.hdataTargets.map((row, rowIdx) => {
      const role = row.querySelector('th').textContent.trim();
      const count = Number(row.dataset.count);
      const deficit = Number(row.dataset.deficit);
      const data = categories.map((x, colIdx) => {
        let y;
        if (colIdx >= count) {
          y = 0; // empty
        } else if (colIdx < target - 1 && rowIdx < target - 1) {
          y = 3; // inside h×h zone
        } else if (deficit === 0) {
          y = 2; // outside h×h zone, role has no deficit
        } else {
          y = 1; // role has deficit
        }

        return { x, y };
      });

      return {
        name: role,
        data,
        meta: { count, deficit }
      };
    });

    return {
      ...layout,
      series,
      chart: {
        ...layout.chart,
        id: 'h-index-chart',
        type: 'heatmap',
        height: 380,
        background: 'transparent',
        foreColor,
        toolbar: {
          show: false
        }
      },
      title: chartTitleOptions(title),
      dataLabels: {
        enabled: false
      },
      legend: {
        show: false
      },
      plotOptions: {
        heatmap: {
          shadeIntensity: 0,
          colorScale: {
            ranges: chartHeatmapScale(),
          }
        }
      },
      xaxis: {
        categories,
        tooltip: {
          enabled: false
        }
      },
      yaxis: {
        opposite: true,
      },
      tooltip: {
        custom: ({ seriesIndex, w }) => {
          const seriesData = w.config.series[seriesIndex];
          const count = seriesData.meta.count;
          const deficit = seriesData.meta.deficit;
          const role = seriesData.name;
          return `
            <div class="p-2">
              <div>${role}</div>
              <div>${count}/${target}</div>
              <div>${tooltipLabel}: ${deficit}</div>
            </div>
          `;
        }
      },
      theme,
      fill: {
        opacity: 0.72
      }
    };
  }
}
