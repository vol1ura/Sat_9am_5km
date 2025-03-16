import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tbody", "tab"]
  static values = {
    page: { type: Number, default: 1 },
    ratingType: String,
    order: String,
    loading: { type: Boolean, default: false }
  }

  connect() {
    this.loadPage()
    this.setupInfiniteScroll()
  }

  setupInfiniteScroll() {
    const options = {
      root: null,
      rootMargin: "0px",
      threshold: 0.1
    }

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !this.loadingValue) {
          this.loadNextPage()
        }
      })
    }, options)

    this.tbodyTarget.lastElementChild && observer.observe(this.tbodyTarget.lastElementChild)
  }

  async switchTab(event) {
    event.preventDefault()
    const tab = event.currentTarget

    if (tab.classList.contains('active')) return

    this.tabTargets.forEach(t => t.classList.remove('active'))
    tab.classList.add('active')

    this.orderValue = tab.dataset.order
    this.pageValue = 1

    const url = new URL(window.location)
    url.searchParams.set('order', this.orderValue)
    history.pushState({}, '', url)

    await this.loadPage()
  }

  async loadPage() {
    this.loadingValue = true
    try {
      const response = await fetch(`/ratings/table?page=${this.pageValue}&rating_type=${this.ratingTypeValue}&order=${this.orderValue}`)
      const html = await response.text()

      if (this.pageValue === 1) {
        this.tbodyTarget.innerHTML = html
      } else {
        const loadingIndicator = this.tbodyTarget.querySelector('.loading-indicator')
        loadingIndicator?.remove()
        this.tbodyTarget.insertAdjacentHTML('beforeend', html)
      }

      this.setupInfiniteScroll()
    } catch (error) {
      console.error('Error loading ratings:', error)
    } finally {
      this.loadingValue = false
    }
  }

  async loadNextPage() {
    if (this.pageValue >= 20) {
      this.tbodyTarget.lastElementChild.remove()
      return
    }
    this.pageValue++
    await this.loadPage()
  }
}
