import { Controller } from '@hotwired/stimulus';

const THEME_KEY = 's95_theme';

export default class extends Controller {
  toggle() {
    const currentTheme = document.documentElement.getAttribute('data-bs-theme') || 'light';
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';
    document.documentElement.setAttribute('data-bs-theme', newTheme);
    localStorage.setItem(THEME_KEY, newTheme);
  }
}
