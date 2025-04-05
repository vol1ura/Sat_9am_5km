import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["days", "hours", "minutes", "seconds"]

  connect() {
    this.updateTimer()
    setInterval(() => this.updateTimer(), 1000)
  }

  updateTimer() {
    const now = new Date()
    const nextSaturday = this.getNextSaturday()
    const timeLeft = nextSaturday - now

    if (timeLeft <= 0) {
      // Если уже суббота 9:00, показываем 0
      this.daysTarget.textContent = "00"
      this.hoursTarget.textContent = "00"
      this.minutesTarget.textContent = "00"
      this.secondsTarget.textContent = "00"
      return
    }

    const days = Math.floor(timeLeft / (1000 * 60 * 60 * 24))
    const hours = Math.floor((timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    const minutes = Math.floor((timeLeft % (1000 * 60 * 60)) / (1000 * 60))
    const seconds = Math.floor((timeLeft % (1000 * 60)) / 1000)

    this.daysTarget.textContent = days.toString().padStart(2, "0")
    this.hoursTarget.textContent = hours.toString().padStart(2, "0")
    this.minutesTarget.textContent = minutes.toString().padStart(2, "0")
    this.secondsTarget.textContent = seconds.toString().padStart(2, "0")
  }

  getNextSaturday() {
    const now = new Date()
    const nextSaturday = new Date(now)

    // Устанавливаем время на 9:00
    nextSaturday.setHours(9, 0, 0, 0)

    // Если сегодня суббота и время меньше 9:00, оставляем сегодня
    if (now.getDay() === 6 && now.getHours() < 9) {
      return nextSaturday
    }

    // Иначе ищем следующую субботу
    const daysUntilSaturday = (6 - now.getDay() + 7) % 7
    nextSaturday.setDate(now.getDate() + (daysUntilSaturday || 7))

    return nextSaturday
  }
}
