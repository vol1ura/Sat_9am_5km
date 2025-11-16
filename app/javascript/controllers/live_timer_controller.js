import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['time'];
  static values = { startTime: Number };

  connect() {
    this.updateTime();
    this.timer = setInterval(() => {
      this.updateTime();
    }, 1000);
  }

  disconnect() {
    if (this.timer) {
      clearInterval(this.timer);
    }
  }

  startTimeValueChanged() {
    this.updateTime();
  }

  updateTime() {
    const startTime = Number(this.startTimeValue);

    if (startTime > 0) {
      const now = Date.now();
      const elapsed = now - startTime;
      const seconds = Math.floor(elapsed / 1000);
      const minutes = Math.floor(seconds / 60);
      const hours = Math.floor(minutes / 60);

      const formattedTime = `${hours.toString().padStart(2, '0')}:${(minutes % 60).toString().padStart(2, '0')}:${(seconds % 60).toString().padStart(2, '0')}`;

      if (this.hasTimeTarget) {
        this.timeTarget.textContent = formattedTime;
      }
    } else {
      if (this.hasTimeTarget) {
        this.timeTarget.textContent = '--:--:--';
      }
    }
  }
}
