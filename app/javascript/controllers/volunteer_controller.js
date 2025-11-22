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
  }
};

// Connects to data-controller="volunteer"
export default class extends Controller {
  static targets = ['data', 'chart'];

  connect() {
    if (this.hasChartTarget && this.dataTargets.length > 0) {
      this.#renderVolunteeringChart();
    }
  }

  disconnect() {
    if (this.hasChartTarget) {
      this.chartTarget.innerHTML = '';
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

    return {
      series,
      chart: {
        type: 'bar',
        height: 350,
        stacked: true,
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
        palette: 'palette2'
      },
      fill: {
        opacity: 0.85
      }
    };
  }
}
