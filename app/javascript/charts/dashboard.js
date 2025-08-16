import ApexCharts from 'apexcharts'

export default class DashboardCharts {
  constructor(totalResults, personalBests, firstRuns, totalVolunteers, firstTimeVolunteers, totalMale, totalFemale, totalUnknown) {
    this.totalResults = totalResults;
    this.personalBests = personalBests;
    this.firstRuns = firstRuns;
    this.totalVolunteers = totalVolunteers;
    this.firstTimeVolunteers = firstTimeVolunteers;
    this.totalMale = totalMale;
    this.totalFemale = totalFemale;
    this.totalUnknown = totalUnknown;
  }

  initializeCharts(participantsContainer, volunteersContainer, genderContainer) {
    if (participantsContainer) {
      const participantsChart = new ApexCharts(participantsContainer, this.#participantsChartOptions());
      participantsChart.render();
    }

    if (volunteersContainer) {
      const volunteersChart = new ApexCharts(volunteersContainer, this.#volunteersChartOptions());
      volunteersChart.render();
    }

    if (genderContainer) {
      const genderChart = new ApexCharts(genderContainer, this.#genderChartOptions());
      genderChart.render();
    }
  }

  #getBasePieChartOptions(title, series, labels) {
    return {
      chart: {
        height: 200,
        type: 'pie',
      },
      series: series,
      labels: labels,
      title: {
        text: title,
        align: 'center',
        margin: 10,
        offsetY: 10,
        style: {
          fontSize: '1rem',
          fontWeight: 600,
          color: '#333'
        }
      },
      legend: {
        position: 'bottom'
      },
      dataLabels: {
        enabled: true
      },
      tooltip: {
        y: {
          formatter: val => `${val} чел.`
        }
      },
      theme: {
        palette: 'palette2'
      }
    };
  }

  #participantsChartOptions() {
    const newcomers = this.firstRuns;
    const personalBestsExcludingNewcomers = Math.max(0, this.personalBests - this.firstRuns);
    const others = Math.max(0, this.totalResults - this.firstRuns - personalBestsExcludingNewcomers);

    const seriesData = [];
    const labelsData = [];

    if (newcomers > 0) {
      seriesData.push(newcomers);
      labelsData.push('Впервые на S95');
    }
    if (personalBestsExcludingNewcomers > 0) {
      seriesData.push(personalBestsExcludingNewcomers);
      labelsData.push('Личные рекорды');
    }
    if (others > 0) {
      seriesData.push(others);
      labelsData.push('Остальные');
    }

    const series = seriesData;
    const labels = labelsData;

    if (series.length === 0) {
      return this.#getEmptyChartOptions('Участники', 'Пока нет данных за эту неделю');
    }

    return this.#getBasePieChartOptions(`Всего участников: ${this.totalResults}`, series, labels);
  }

  #volunteersChartOptions() {
    const newcomerVolunteers = this.firstTimeVolunteers;
    const experiencedVolunteers = Math.max(0, this.totalVolunteers - this.firstTimeVolunteers);

    const seriesData = [];
    const labelsData = [];

    if (newcomerVolunteers > 0) {
      seriesData.push(newcomerVolunteers);
      labelsData.push('Впервые');
    }
    if (experiencedVolunteers > 0) {
      seriesData.push(experiencedVolunteers);
      labelsData.push('Остальные');
    }

    const series = seriesData;
    const labels = labelsData;

    if (series.length === 0) {
      return this.#getEmptyChartOptions('Волонтёры', 'Пока нет данных за эту неделю');
    }

    return this.#getBasePieChartOptions(`Всего волонтеров: ${this.totalVolunteers}`, series, labels);
  }

  #genderChartOptions() {
    const series = [this.totalMale, this.totalFemale, this.totalUnknown];
    const labels = ['Мужчины', 'Женщины', 'Неизвестные'];

    return this.#getBasePieChartOptions('Распределение по полу', series, labels);
  }

  #getEmptyChartOptions(title, message) {
    const baseOptions = this.#getBasePieChartOptions(title, [1], [message]);

    return {
      ...baseOptions,
      legend: {
        show: false
      },
      dataLabels: {
        enabled: false
      },
      plotOptions: {
        pie: {
          donut: {
            size: '70%',
            labels: {
              show: true,
              total: {
                show: true,
                label: '',
                formatter: () => message
              }
            }
          }
        }
      }
    };
  }
}
