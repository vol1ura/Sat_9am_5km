import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = [
    'code', 'name', 'home', 'runs', 'vols',
    'previewCode', 'previewName', 'previewHome', 'previewRuns', 'previewVols', 'previewCard',
    'qrPlaceholder', 'qrContent'
  ];

  updatePreview() {
    const code = this.codeTarget.value.trim();
    const name = this.nameTarget.value.trim();
    const home = this.homeTarget.value.trim();
    const runs = this.runsTarget.value.trim();
    const vols = this.volsTarget.value.trim();

    this.previewCodeTarget.textContent = code || '—';
    this.previewNameTarget.textContent = name || (document.documentElement.lang === 'ru' ? 'Участник С95' : 'S95 Athlete');
    this.previewHomeTarget.textContent = home || '—';
    this.previewRunsTarget.textContent = runs || '0';
    this.previewVolsTarget.textContent = vols || '0';

    this.previewCardTarget.classList.toggle('opacity-50', !code);

    if (this.hasQrPlaceholderTarget && this.hasQrContentTarget) {
      if (code) {
        this.qrPlaceholderTarget.classList.add('d-none');
        this.qrContentTarget.classList.remove('d-none');
        this.qrContentTarget.style.opacity = '0.3'; // Visual hint that it's a preview
      } else {
        this.qrPlaceholderTarget.classList.remove('d-none');
        this.qrContentTarget.classList.add('d-none');
      }
    }
  }
}
