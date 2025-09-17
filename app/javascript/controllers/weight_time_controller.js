import { Controller } from "@hotwired/stimulus"

// Stimulus controller: calculates estimated finish time vs weight changes
export default class extends Controller {
  static targets = ["distance", "weight", "time", "tbody"]

  connect() {
    this.recalculate()
  }

  clear() {
    this.tbodyTarget.innerHTML = ""
  }

  recalculate() {
    const distanceMeters = this.#toNumber(this.distanceTarget?.value)
    const weightKg = this.#toNumber(this.weightTarget?.value)
    const baseTimeStr = (this.timeTarget?.value || "").trim()

    if (!distanceMeters || !weightKg || !this.#isValidTime(baseTimeStr)) {
      this.clear()
      return
    }
    if (baseTimeStr.length < 8) return

    const baseTimeSec = this.#timeToSeconds(baseTimeStr)
    const rows = []

    const deltas = [-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5]
    deltas.forEach((delta) => {
      const newWeight = Math.round((weightKg + delta) * 10) / 10
      const newTime = baseTimeSec * ((newWeight / weightKg)**((distanceMeters * 0.00000027) + 0.81865573))
      const timeDelta = newTime - baseTimeSec
      rows.push({ weight: newWeight, timeDelta: (timeDelta > 0 ? '+' : '') + timeDelta.toFixed(0), timeStr: this.#secondsToHMS(newTime) })
    })

    this.#renderRows(rows)
  }

  #renderRows(rows) {
    const html = rows
      .map((r) => `<tr><td>${r.weight}</td><td>${r.timeStr}</td><td>${this.#secondsToHMS(r.timeDelta)}</td></tr>`)
      .join("")
    this.tbodyTarget.innerHTML = html
  }

  #toNumber(value) {
    if (!value) return NaN
    const n = Number(value)
    return Number.isFinite(n) ? n : NaN
  }

  #isValidTime(str) {
    // Accept H:MM:SS or MM:SS
    const parts = str.split(":").map((p) => p.trim())
    if (parts.length < 2 || parts.length > 3) return false
    return parts.every((p) => p !== "" && !isNaN(Number(p)))
  }

  #timeToSeconds(str) {
    const parts = str.split(":").map((p) => Number(p))
    let h = 0, m = 0, s = 0
    if (parts.length === 3) {
      [h, m, s] = parts
    } else if (parts.length === 2) {
      [m, s] = parts
    }
    return Math.max(0, h * 3600 + m * 60 + s)
  }

  #secondsToHMS(sec) {
    const sign = sec < 0 ? "-" : ""
    const s = Math.round(Math.abs(sec))
    const h = Math.floor(s / 3600)
    const m = Math.floor((s % 3600) / 60)
    const ss = s % 60
    const mm = m.toString().padStart(2, "0")
    const sss = ss.toString().padStart(2, "0")
    return h ? `${sign}${h}:${mm}:${sss}` : `${sign}${mm}:${sss}`
  }
}
