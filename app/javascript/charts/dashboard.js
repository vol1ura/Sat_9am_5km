import ApexCharts from 'apexcharts';
import { apexThemeOptions, chartLayoutPadding, chartTitleOptions } from 'charts/theme';

const translations = {
  ru: {
    participants: 'Участники',
    totalResults: 'Всего участников',
    personalBests: 'Личные рекорды',
    others: 'Остальные',
    newcomers: 'Впервые',
    newcomersS95: 'Впервые на С95',
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
  },
  en: {
    participants: 'Participants',
    totalResults: 'Total results',
    personalBests: 'Personal bests',
    others: 'Others',
    newcomers: 'Newcomers',
    newcomersS95: 'Newcomers on S95',
    volunteers: 'Volunteers',
    totalVolunteers: 'Total volunteers',
    gender: 'Gender distribution',
    male: 'Men',
    female: 'Women',
    unknown: 'Unknown',
    noData: 'No data for this week',
    people: 'people',
  },
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
    this.t = translations[document.documentElement.lang] ?? translations.ru;

    if (participantsContainer) {
      const participantsChart = new ApexCharts(participantsContainer, this.#participantsChartOptions('participants-chart'));
      participantsChart.render();
    }

    if (volunteersContainer) {
      const volunteersChart = new ApexCharts(volunteersContainer, this.#volunteersChartOptions('volunteers-chart'));
      volunteersChart.render();
    }

    if (genderContainer) {
      const genderChart = new ApexCharts(genderContainer, this.#genderChartOptions('gender-chart'));
      genderChart.render();
    }
  }

  #participantsChartOptions(chartId) {
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
      return this.#basePieChartOptions(`${this.t.totalResults}: ${this.totalResults}`, series, labels, chartId);
    }
  }

  #volunteersChartOptions(chartId) {
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
      return this.#basePieChartOptions(`${this.t.totalVolunteers}: ${this.totalVolunteers}`, series, labels, chartId);
    }
  }

  #genderChartOptions(chartId) {
    const series = [this.totalMale, this.totalFemale];
    const labels = [this.t.male, this.t.female];
    if (this.totalUnknown) {
      series.push(this.totalUnknown);
      labels.push(this.t.unknown);
    }

    return this.#basePieChartOptions(this.t.gender, series, labels, chartId);
  }

  #basePieChartOptions(title, series, labels, chartId) {
    const { theme, colors, foreColor, legend } = apexThemeOptions();
    const layout = chartLayoutPadding();

    return {
      ...layout,
      chart: {
        ...layout.chart,
        ...(chartId ? { id: chartId } : {}),
        height: 220,
        type: 'pie',
        background: 'transparent',
        foreColor,
      },
      series: series,
      labels: labels,
      title: chartTitleOptions(title),
      legend: {
        position: 'bottom',
        ...legend,
      },
      dataLabels: {
        enabled: true
      },
      tooltip: {
        y: {
          formatter: val => `${val} ${this.t.people}`
        }
      },
      colors,
      theme,
      fill: {
        opacity: 0.92,
      },
    };
  }

  #emptyChartOptions(title, message) {
    const baseOptions = this.#basePieChartOptions(title, [1], [message], null);

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
