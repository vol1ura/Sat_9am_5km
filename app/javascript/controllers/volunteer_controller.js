import { Controller } from '@hotwired/stimulus';
import ApexCharts from 'apexcharts';
import { ruLocale } from 'charts/ru';
import { srLocale } from 'charts/sr';

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

    const isDark = document.documentElement.getAttribute('data-bs-theme') === 'dark';

    return {
      series,
      chart: {
        type: 'bar',
        height: 350,
        stacked: true,
        background: 'transparent',
        toolbar: {
          show: false
        },
        zoom: {
          enabled: false
        }
      },
      title: {
        text: title,
        floating: true,
        align: 'center',
      },
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
      xaxis: { categories },
      yaxis: {
        forceNiceScale: true,
      },
      legend: {
        position: 'right',
        offsetY: 40
      },
      theme: {
        mode: isDark ? 'dark' : 'light',
        palette: isDark ? 'palette5' : 'palette2'
      },
      fill: {
        opacity: 0.85
      }
    };
  }

  #heatmapOptions(title, tooltipLabel, target) {
    const isDark = document.documentElement.getAttribute('data-bs-theme') === 'dark';
    const categories = Array.from({ length: target }, (_, idx) => (idx + 1).toString());
    const series = this.hdataTargets.map(row => {
      const role = row.querySelector('th').textContent.trim();
      const count = Number(row.dataset.count);
      const deficit = Number(row.dataset.deficit);
      const data = categories.map((x, idx) => ({
        x,
        y: idx + 1 <= count ? 1 : 0
      }));

      return {
        name: role,
        data,
        meta: { count, deficit }
      };
    });

    const filledColor = isDark ? '#2b908f' : '#3f51b5';
    const emptyColor = isDark ? '#2d3748' : '#edf2f7';

    return {
      series,
      chart: {
        type: 'heatmap',
        height: 360,
        background: 'transparent',
        toolbar: {
          show: false
        }
      },
      title: {
        text: title,
        align: 'center'
      },
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
            ranges: [
              {
                from: 0,
                to: 0,
                color: emptyColor
              },
              {
                from: 1,
                to: 1,
                color: filledColor
              }
            ]
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
      theme: {
        mode: isDark ? 'dark' : 'light'
      },
      fill: {
        opacity: 0.85
      }
    };
  }
}
