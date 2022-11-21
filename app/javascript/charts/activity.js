export default class ActivityCharts {
  constructor(rows) {
    this.rows = rows
  }

  genderData() {
    const data = [0, 0, 0]
    this.rows.forEach(row => {
      if (row.dataset.male === 'true') {
        data[0] += 1
      } else if (row.dataset.male === 'false') {
        data[1] += 1
      } else {
        data[2] += 1
      }
    })
    return data
  }

  get genderDonutOptions() {
    return {
      chart: { type: 'donut' },
      series: this.genderData(),
      labels: ['мужчины', 'женщины', 'неизвестные'],
      plotOptions: {
        pie: {
          donut: {
            labels: {
              show: true,
              total: {
                show: true,
                label: 'Всего'
              }
            }
          }
        }
      }
    }
  }

  clubData() {
    const data = {}
    this.rows.forEach(row => {
      const club_name = row.querySelector('.club-name').innerText.trim()
      if (!club_name) return
      data[club_name] = !data[club_name] ? 1 : data[club_name] + 1
    })
    return Object.keys(data).sort((a, b) => data[b] - data[a]).reduce((result, key) => {
      result[key] = data[key];
      return result;
    }, {})
  }

  get clubsBarOptions() {
    const clubs = this.clubData()
    return {
      series: [{
        data: Object.values(clubs)
      }],
      chart: {
        type: 'bar',
      },
      title: {
        text: 'Клубы',
        align: 'center'
      },
      plotOptions: {
        bar: {
          columnWidth: '45%',
          distributed: true,
        }
      },
      dataLabels: {
        enabled: false
      },
      legend: {
        show: false
      },
      xaxis: {
        categories: Object.keys(clubs)
      },
      yaxis: {
        tickAmount: 1
      }
    }
  }
}
