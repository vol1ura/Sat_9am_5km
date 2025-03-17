import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["maleContent", "femaleContent", "loadingSpinner"]

  connect() {
    this.page = 1
    this.currentTab = 'male'
    this.loading = false
    this.hasMore = true
    this.loadPage()
  }

  switchTab(event) {
    this.currentTab = event.target.getAttribute('aria-controls')
    this.page = 1
    this.loading = false
    this.hasMore = true
    this.loadPage().then(() => {
      this.setupInfiniteScroll()
    })
  }

  setupInfiniteScroll() {
    const options = {
      root: null,
      rootMargin: '20px',
      threshold: 0.1
    }

    if (this.observer) {
      this.observer.disconnect()
    }

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !this.loading && this.hasMore) {
          this.loadMore()
        }
      })
    }, options)

    const spinner = this.element.querySelector(`#${this.currentTab} [data-results-table-target="loadingSpinner"]`)
    if (spinner) {
      this.observer.observe(spinner)
    }
  }

  async loadPage() {
    if (!this.hasMore) return

    this.loading = true
    const isMaleTab = this.currentTab === 'male'

    try {
      const response = await fetch(`/ratings/results_table?page=${this.page}&male=${isMaleTab}`)
      const html = await response.text()
      const target = isMaleTab ? this.maleContentTarget : this.femaleContentTarget

      if (this.page === 1) {
        target.innerHTML = html
        setTimeout(() => this.setupInfiniteScroll(), 0)
      } else {
        const tempDiv = document.createElement('div')
        tempDiv.innerHTML = html
        const newRows = tempDiv.querySelector('tbody')?.children

        if (newRows?.length > 0) {
          const tbody = target.querySelector('tbody')
          if (tbody) {
            tbody.append(...newRows)
          }
        }

        const spinner = tempDiv.querySelector('[data-results-table-target="loadingSpinner"]')
        const currentSpinner = target.querySelector('[data-results-table-target="loadingSpinner"]')

        if (spinner) {
          if (currentSpinner) {
            currentSpinner.replaceWith(spinner)
          } else {
            target.appendChild(spinner)
          }
          this.observer.observe(spinner)
        } else {
          if (currentSpinner) {
            currentSpinner.remove()
          }
          this.hasMore = false
        }
      }
    } catch (error) {
      console.error("Error loading results:", error)
      this.hasMore = false
    } finally {
      this.loading = false
    }
  }

  async loadMore() {
    if (this.loading || !this.hasMore || this.page >= 20) return

    this.page++
    await this.loadPage()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }
}
