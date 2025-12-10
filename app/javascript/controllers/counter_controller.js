import { Controller } from "@hotwired/stimulus"

// Animates numbers counting up from 0 to their final value
// Usage: data-controller="counter" on container, data-counter-target="value" on each number element
export default class extends Controller {
    static targets = ["value"]

    connect() {
        // Use Intersection Observer to start animation when visible
        this.observer = new IntersectionObserver(
            (entries) => {
                entries.forEach((entry) => {
                    if (entry.isIntersecting) {
                        this.animateAll()
                        this.observer.disconnect()
                    }
                })
            },
            { threshold: 0.3 }
        )

        this.observer.observe(this.element)
    }

    disconnect() {
        if (this.observer) {
            this.observer.disconnect()
        }
    }

    animateAll() {
        this.valueTargets.forEach((element) => {
            const value = element.dataset.value
            if (value && !isNaN(parseFloat(value))) {
                this.animateValue(element, parseFloat(value))
            }
        })
    }

    animateValue(element, endValue) {
        const duration = 1500 // ms
        const startTime = performance.now()
        const isPercentage = element.dataset.percentage === "true"
        const isFloat = endValue % 1 !== 0

        const animate = (currentTime) => {
            const elapsed = currentTime - startTime
            const progress = Math.min(elapsed / duration, 1)

            // Easing function (ease-out cubic)
            const easeOut = 1 - Math.pow(1 - progress, 3)

            const currentValue = endValue * easeOut

            if (isFloat) {
                element.textContent = currentValue.toFixed(1) + (isPercentage ? "%" : "")
            } else {
                element.textContent = Math.floor(currentValue).toLocaleString('ru-RU') + (isPercentage ? "%" : "")
            }

            if (progress < 1) {
                requestAnimationFrame(animate)
            } else {
                // Ensure final value is exact
                element.textContent = (isFloat ? endValue.toFixed(1) : endValue.toLocaleString('ru-RU')) + (isPercentage ? "%" : "")
            }
        }

        requestAnimationFrame(animate)
    }
}
