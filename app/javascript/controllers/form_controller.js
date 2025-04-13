import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input']

  connect() {
    this.modal = new bootstrap.Modal(document.getElementById('promotionModal'))
    this.currentPromotionKey = null
  }

  submit(event) {
    event.preventDefault()
    this.element.requestSubmit()
  }

  toggleBlock(event) {
    const input = this.inputTarget.getElementsByTagName('input')[0]
    if (event.target.checked) {
      this.inputTarget.classList.add('d-none')
      input.disabled = true
    } else {
      this.inputTarget.classList.remove('d-none')
      input.disabled = false
    }
  }

  showPromotionModal(event) {
    if (event.target.checked) {
      this.currentPromotionKey = event.target.dataset.promotionKey
      const terms = this.getPromotionTerms(this.currentPromotionKey)
      document.getElementById('promotionTerms').innerHTML = terms
      this.modal.show()
      event.target.checked = false
    }
  }

  agreeToPromotion() {
    if (this.currentPromotionKey) {
      const checkbox = document.querySelector(`[data-promotion-key="${this.currentPromotionKey}"]`)
      checkbox.checked = true
      this.modal.hide()
    }
  }

  getPromotionTerms(promotionKey) {
    const terms = {
      spartacus: `
        <p>
          Принимая участие в
          <a href="https://fanat1k.ru/news-380970-vse-na-spartakovskuyu-probezhku-19-aprelya.php" target="_blank">акции фан-клуба ФАНАТИК СКВАД</a>,
          вы соглашаетесь
          с условиями обработки персональных данных и их предоставления
          в рамках партнёрской
          <a href="https://spartak.com/business/loyalty" target="_blank">программы лояльности</a>
          ФК "СПАРТАК-МОСКВА" (необходима также регистрация на сайте партнёра).
        </p>
        <p>
          Мы гарантируем конфиденциальность ваших данных и
          обязуемся использовать их только в рамках акции.
        </p>
      `
    }
    return terms[promotionKey] || ''
  }
}
