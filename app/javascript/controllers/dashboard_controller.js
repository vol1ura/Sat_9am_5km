import { Controller } from '@hotwired/stimulus'
import DashboardCharts from 'charts/dashboard'

// Connects to data-controller="dashboard"
export default class extends Controller {
  static targets = ['container', 'participantsContainer', 'volunteersContainer', 'genderContainer']
  static values = {
    totalResults: Number,
    personalBests: Number,
    firstRuns: Number,
    totalVolunteers: Number,
    firstTimeVolunteers: Number,
    totalMale: Number,
    totalFemale: Number,
    totalUnknown: Number,
  }

  connect() {
    try {
      const dashboardCharts = new DashboardCharts(
        this.totalResultsValue,
        this.personalBestsValue,
        this.firstRunsValue,
        this.totalVolunteersValue,
        this.firstTimeVolunteersValue,
        this.totalMaleValue,
        this.totalFemaleValue,
        this.totalUnknownValue,
      )
      dashboardCharts.initializeCharts(
        this.participantsContainerTarget,
        this.volunteersContainerTarget,
        this.genderContainerTarget
      )
    } catch (error) {
      console.error('Error showing dashboard data:', error)
      this.#showError()
    }
  }

  disconnect() {
    if (this.hasParticipantsContainerTarget) {
      this.participantsContainerTarget.innerHTML = ''
    }
    if (this.hasVolunteersContainerTarget) {
      this.volunteersContainerTarget.innerHTML = ''
    }
    if (this.hasGenderContainerTarget) {
      this.genderContainerTarget.innerHTML = ''
    }
  }

  #showError() {
    if (this.hasContainerTarget) {
      this.containerTarget.innerHTML = `
        <div class="alert alert-warning" role="alert">
          <i class="fa fa-exclamation-triangle"></i>
          Не удалось загрузить данные дашборда. Попробуйте обновить страницу.
        </div>
      `
    }
  }
}
