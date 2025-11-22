import ApexCharts from 'apexcharts';

const translations = {
  ru: {
    participants: 'Участники',
    totalResults: 'Всего участников',
    personalBests: 'Личные рекорды',
    others: 'Остальные',
    newcomers: 'Впервые',
    newcomersS95: 'Впервые на S95',
    volunteers: 'Волонтёры',
    totalVolunteers: 'Всего волонтеров',
    gender: 'Распределение по полу',
    male: 'Мужчины',
    female: 'Женщины',
    unknown: 'Неизвестные',
    noData: 'Пока нет данных за эту неделю',
    people: 'чел.',
  },
  sr: {
    participants: 'Učesnici',
    totalResults: 'Ukupno rezultata',
    personalBests: 'Osobni rekordi',
    others: 'Ostali',
    newcomers: 'Prvi put',
    newcomersS95: 'Prvi put na S95',
    volunteers: 'Vladeoci',
    totalVolunteers: 'Ukupno vladeoci',
    gender: 'Raspored po polu',
    male: 'Muškarci',
    female: 'Žene',
    unknown: 'Nepoznati',
    noData: 'Nema podataka za ovu nedelju',
    people: 'osoba',
  }
};

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
    this.t = translations[document.documentElement.lang === 'sr' ? 'sr' : 'ru'];

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

  #participantsChartOptions() {
    const newcomers = this.firstRuns;
    const personalBestsExcludingNewcomers = Math.max(0, this.personalBests - this.firstRuns);
    const others = Math.max(0, this.totalResults - this.firstRuns - personalBestsExcludingNewcomers);

    const series = [];
    const labels = [];

    if (newcomers) {
      series.push(newcomers);
      labels.push(this.t.newcomersS95);
    }
    if (personalBestsExcludingNewcomers) {
      series.push(personalBestsExcludingNewcomers);
      labels.push(this.t.personalBests);
    }
    if (others) {
      series.push(others);
      labels.push(this.t.others);
    }

    if (series.length === 0) {
      return this.#emptyChartOptions(this.t.participants, this.t.noData);
    } else {
      return this.#basePieChartOptions(`${this.t.totalResults}: ${this.totalResults}`, series, labels);
    }
  }

  #volunteersChartOptions() {
    const newcomerVolunteers = this.firstTimeVolunteers;
    const experiencedVolunteers = Math.max(0, this.totalVolunteers - this.firstTimeVolunteers);

    const series = [];
    const labels = [];

    if (newcomerVolunteers) {
      series.push(newcomerVolunteers);
      labels.push(this.t.newcomers);
    }
    if (experiencedVolunteers) {
      series.push(experiencedVolunteers);
      labels.push(this.t.others);
    }

    if (series.length === 0) {
      return this.#emptyChartOptions(this.t.volunteers, this.t.noData);
    } else {
      return this.#basePieChartOptions(`${this.t.totalVolunteers}: ${this.totalVolunteers}`, series, labels);
    }
  }

  #genderChartOptions() {
    const series = [this.totalMale, this.totalFemale];
    const labels = [this.t.male, this.t.female];
    if (this.totalUnknown) {
      series.push(this.totalUnknown);
      labels.push(this.t.unknown);
    }

    return this.#basePieChartOptions(this.t.gender, series, labels);
  }

  #basePieChartOptions(title, series, labels) {
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
          formatter: val => `${val} ${this.t.people}`
        }
      },
      theme: {
        palette: 'palette2'
      }
    };
  }

  #emptyChartOptions(title, message) {
    const baseOptions = this.#basePieChartOptions(title, [1], [message]);

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
