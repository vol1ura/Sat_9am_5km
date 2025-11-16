import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['content', 'tab'];
  static values = {
    page: { type: Number, default: 1 },
    loading: { type: Boolean, default: false },
    hasMore: { type: Boolean, default: true },
    url: String,
    params: String
  };

  connect() {
    this.setupInfiniteScroll();
    this.loadPage();
  }

  setupInfiniteScroll() {
    if (this.observer) {
      this.observer.disconnect();
    }

    const options = {
      root: null,
      rootMargin: '50px',
      threshold: 0.1
    };

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !this.loadingValue && this.hasMoreValue) {
          this.loadMore();
        }
      });
    }, options);

    const spinner = this.contentTarget.querySelector('.loading-indicator');
    if (spinner) {
      this.observer.observe(spinner);
    }
  }

  async switchTab(event) {
    this.tabTargets.forEach(tab => tab.classList.remove('active'));
    event.currentTarget.classList.add('active');

    this.pageValue = 1;
    this.loadingValue = false;
    this.hasMoreValue = true;

    await this.loadPage();
  }

  setGender(event) {
    const gender = event.currentTarget.dataset.gender;
    const genderInput = document.getElementById('gender-input');
    const resetLink = document.getElementById('results-reset');
    genderInput.value = gender;

    const url = new URL(resetLink.href, window.location.origin);
    url.searchParams.set('gender', gender);
    resetLink.href = url.pathname + url.search;
  }

  async loadPage() {
    if (!this.hasMoreValue) return;

    this.loadingValue = true;

    const tabData = this.tabTargets.find(tab => tab.classList.contains('active')).dataset;
    const query_arr = this.paramsValue.split(',').map(param => `${param}=${tabData[param]}`);

    const urlParams = new URLSearchParams(window.location.search);
    const tabParamNames = this.paramsValue.split(',');
    urlParams.forEach((value, key) => {
      if (!tabParamNames.includes(key) && key !== 'page') {
        query_arr.push(`${encodeURIComponent(key)}=${encodeURIComponent(value)}`);
      }
    });

    const url = `${this.urlValue}?page=${this.pageValue}&${query_arr.join('&')}`;

    try {
      const response = await fetch(url);
      const html = await response.text();
      const target = this.contentTarget;

      const tempDiv = document.createElement('tbody');
      tempDiv.innerHTML = html;

      const currentLoadingIndicator = target.querySelector('.loading-indicator');
      currentLoadingIndicator?.remove();

      if (this.pageValue === 1) {
        target.innerHTML = '';
      }

      const dataRows = Array.from(tempDiv.children).filter(row => !row.classList?.contains('loading-indicator'));

      if (dataRows.length > 0) {
        dataRows.forEach(row => target.appendChild(row));
        this.hasMoreValue = true;
      } else {
        this.hasMoreValue = false;
      }

      if (this.hasMoreValue && currentLoadingIndicator) {
        target.appendChild(currentLoadingIndicator);
      }

      setTimeout(() => this.setupInfiniteScroll(), 100);
    } catch (error) {
      console.error('Error loading data:', error);
      this.hasMoreValue = false;
    } finally {
      this.loadingValue = false;
    }
  }

  async loadMore() {
    if (this.loadingValue || !this.hasMoreValue) { return; }

    this.pageValue++;
    await this.loadPage();
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect();
    }
  }
}
