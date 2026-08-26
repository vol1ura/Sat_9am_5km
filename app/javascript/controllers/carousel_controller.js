import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['image', 'feature', 'slide', 'indicator'];

  connect() {
    this.currentIndex = 0;
    if (this.hasSlideTarget) {
      this.updateSlides();
    }
  }

  showSlide(event) {
    const index = parseInt(event.currentTarget.dataset.index, 10);
    if (Number.isNaN(index)) return;
    if (index === this.currentIndex && this.hasFeatureTarget) return;

    this.currentIndex = index;

    if (this.hasSlideTarget) {
      this.updateSlides();
    } else {
      this.updateDisplay();
    }
  }

  prev() {
    if (!this.hasSlideTarget) return;

    this.currentIndex = (this.currentIndex - 1 + this.slideTargets.length) % this.slideTargets.length;
    this.updateSlides();
  }

  next() {
    if (!this.hasSlideTarget) return;

    this.currentIndex = (this.currentIndex + 1) % this.slideTargets.length;
    this.updateSlides();
  }

  updateSlides() {
    this.slideTargets.forEach((slide, index) => {
      slide.classList.toggle('hidden', index !== this.currentIndex);
    });

    if (this.hasIndicatorTarget) {
      this.indicatorTargets.forEach((indicator, index) => {
        indicator.classList.toggle('bg-accent', index === this.currentIndex);
        indicator.classList.toggle('bg-line', index !== this.currentIndex);
        indicator.setAttribute('aria-current', index === this.currentIndex ? 'true' : 'false');
      });
    }
  }

  updateDisplay() {
    this.imageTarget.style.opacity = '0.75';

    setTimeout(() => {
      this.imageTarget.src = `/images/app/mobile_app_${this.currentIndex + 1}.png`;
      this.imageTarget.style.opacity = '1';

      this.featureTargets.forEach((feature, index) => {
        feature.classList.toggle('feature-active', index === this.currentIndex);
      });
    }, 200);
  }
}
