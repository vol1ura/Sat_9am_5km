import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "tab"]
  static values = {
    page: { type: Number, default: 1 },
    loading: { type: Boolean, default: false },
    hasMore: { type: Boolean, default: true },
    currentTab: String,
    order: String,
    ratingType: String
  }

  connect() {
    if (!this.hasOrderValue) {
      const activeTab = this.element.querySelector('.nav-link.active')
      if (activeTab) {
        this.currentTabValue = activeTab.getAttribute('aria-controls')
      }
    }
    this.setupInfiniteScroll()
    this.loadPage()
  }

  setupInfiniteScroll() {
    if (this.observer) {
      this.observer.disconnect()
    }

    const options = {
      root: null,
      rootMargin: "50px",
      threshold: 0.1
    }

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !this.loadingValue && this.hasMoreValue) {
          this.loadMore()
        }
      })
    }, options)

    const target = this.getContentTarget()
    const spinner = target.querySelector('.loading-indicator')
    if (spinner) {
      this.observer.observe(spinner)
    }
  }

  async switchTab(event) {
    const tab = event.currentTarget

    if (this.hasOrderValue) {
      this.orderValue = tab.dataset.order
      const url = new URL(window.location)
      url.searchParams.set('order', this.orderValue)
      history.pushState({}, '', url)
    } else {
      this.currentTabValue = tab.getAttribute('aria-controls')
    }

    this.pageValue = 1
    this.loadingValue = false
    this.hasMoreValue = true

    await this.loadPage()
  }

  async loadPage() {
    if (!this.hasMoreValue) return

    this.loadingValue = true
    let url = ''

    if (this.hasOrderValue) {
      url = `/ratings/table?page=${this.pageValue}&rating_type=${this.ratingTypeValue}&order=${this.orderValue}`
    } else {
      url = `/ratings/results_table?page=${this.pageValue}&male=${this.currentTabValue === 'male'}`
    }

    try {
      const response = await fetch(url)
      const html = await response.text()
      const target = this.getContentTarget()

      const tempDiv = document.createElement('tbody')
      tempDiv.innerHTML = html

      const currentLoadingIndicator = target.querySelector('.loading-indicator')
      currentLoadingIndicator?.remove()

      if (this.pageValue === 1) {
        target.innerHTML = ''
      }

      const rows = Array.from(tempDiv.children)
      const newLoadingIndicator = rows.find(row => row.classList?.contains('loading-indicator'))

      const dataRows = rows.filter(row => !row.classList?.contains('loading-indicator'))

      if (dataRows.length > 0) {
        dataRows.forEach(row => target.appendChild(row))
        this.hasMoreValue = true
      } else {
        this.hasMoreValue = false
      }

      if (this.hasMoreValue && currentLoadingIndicator) {
        target.appendChild(currentLoadingIndicator)
      }

      setTimeout(() => this.setupInfiniteScroll(), 100)
    } catch (error) {
      console.error('Error loading data:', error)
      this.hasMoreValue = false
    } finally {
      this.loadingValue = false
    }
  }

  getContentTarget() {
    if (this.hasOrderValue) {
      return this.contentTarget
    }
    const activePane = this.element.querySelector('.tab-pane.show.active')
    const content = activePane?.querySelector('[data-table-target="content"]')
    return content || this.contentTargets[0]
  }

  async loadMore() {
    if (this.loadingValue || !this.hasMoreValue) { return }

    this.pageValue++
    await this.loadPage()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }
}
