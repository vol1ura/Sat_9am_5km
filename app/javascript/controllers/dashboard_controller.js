import { Controller } from '@hotwired/stimulus';
import DashboardCharts from 'charts/dashboard';

// Connects to data-controller="dashboard"
export default class extends Controller {
  static targets = ['container', 'participants', 'volunteers', 'gender'];
  static values = {
    totalResults: Number,
    personalBests: Number,
    firstRuns: Number,
    totalVolunteers: Number,
    firstTimeVolunteers: Number,
    totalMale: Number,
    totalFemale: Number,
    totalUnknown: Number,
    error: String,
  };

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
      );

      dashboardCharts.initializeCharts(this.participantsTarget, this.volunteersTarget, this.genderTarget);
    } catch (error) {
      console.error('Error showing dashboard data:', error);
      this.#showError();
    }
  }

  disconnect() {
    if (this.hasParticipantsTarget) {
      this.participantsTarget.innerHTML = '';
    }
    if (this.hasVolunteersTarget) {
      this.volunteersTarget.innerHTML = '';
    }
    if (this.hasGenderTarget) {
      this.genderTarget.innerHTML = '';
    }
  }

  #showError() {
    if (this.hasContainerTarget) {
      this.containerTarget.innerHTML = `
        <div class="alert alert-warning" role="alert">
          <i class="fa fa-exclamation-triangle"></i>
          ${this.errorValue}
        </div>
      `;
    }
  }
}
