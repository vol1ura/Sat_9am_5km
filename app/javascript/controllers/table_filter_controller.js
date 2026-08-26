import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="table-filter"
export default class extends Controller {
  static targets = ['row', 'event', 'role'];

  filter() {
    const eventId = this.hasEventTarget ? this.eventTarget.value : '';
    const role = this.hasRoleTarget ? this.roleTarget.value : '';

    this.rowTargets.forEach((row) => {
      const matchEvent = !eventId || row.dataset.eventId === eventId;
      const matchRole = !role || row.dataset.role === role;
      row.hidden = !(matchEvent && matchRole);
    });
  }
}
