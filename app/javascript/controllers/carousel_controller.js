import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['image', 'feature'];

  connect() {
    this.currentIndex = 0;
  }

  updateDisplay() {
    this.imageTarget.style.opacity = '0.75';

    setTimeout(() => {
      this.imageTarget.src = `/images/app/mobile_app_${this.currentIndex + 1}.png`;
      this.imageTarget.style.opacity = '1';

      this.featureTargets.forEach((feature, index) => {
        if (index === this.currentIndex) {
          feature.classList.add('feature-active');
        } else {
          feature.classList.remove('feature-active');
        }
      });
    }, 200);
  }

  showSlide(event) {
    const index = parseInt(event.currentTarget.dataset.index);
    if (index === this.currentIndex) return;

    this.currentIndex = index;
    this.updateDisplay();
  }
}
