import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mapView", "listView"]

  connect() {
    console.log('Map controller connected')

    // Показываем карту по умолчанию
    this.showMap()

    // Ждем загрузки Яндекс.Карт API
    if (window.ymaps) {
      console.log('Yandex Maps API already loaded')
      window.ymaps.ready(() => this.initializeMap())
    } else {
      console.log('Waiting for Yandex Maps API to load')
      window.addEventListener('yandex-maps-ready', () => {
        console.log('Yandex Maps API ready event received')
        window.ymaps.ready(() => this.initializeMap())
      })
    }
  }

  showMap() {
    console.log('Showing map view')
    this.mapViewTarget.classList.remove('d-none')
    this.listViewTarget.classList.add('d-none')

    // Обновляем размер карты при переключении на карту
    if (this.map) {
      this.map.container.fitToViewport()
    }
  }

  showList() {
    console.log('Showing list view')
    this.mapViewTarget.classList.add('d-none')
    this.listViewTarget.classList.remove('d-none')
  }

  initializeMap() {
    try {
      console.log('Initializing map')
      const mapElement = document.getElementById('map')
      if (!mapElement) {
        throw new Error('Map element not found')
      }

      // Проверяем размеры контейнера
      const container = mapElement.parentElement
      console.log('Container dimensions:', {
        width: container.offsetWidth,
        height: container.offsetHeight
      })

      // Устанавливаем минимальную высоту для контейнера
      mapElement.style.minHeight = '600px'

      this.map = new window.ymaps.Map('map', {
        center: [55.7558, 37.6173], // Москва
        zoom: 5,
        controls: ['zoomControl']
      });

      console.log('Map instance created')

      const events = JSON.parse(this.element.dataset.events)
      console.log('Events loaded:', events.length)

      events.forEach(event => {
        const placemark = new window.ymaps.Placemark(
          [event.latitude, event.longitude],
          {
            balloonContent: `
              <div>
                <h5>${event.name}</h5>
                <p class="py-1">${event.town}</p>
                <a href="/events/${event.code_name}" class="btn btn-primary">Подробнее</a>
              </div>
            `,
            hintContent: event.name
          },
          {
            preset: 'islands#blueStretchyIcon'
          }
        );

        this.map.geoObjects.add(placemark);
      });

      // Обновляем размер карты после добавления меток
      this.map.container.fitToViewport()
      console.log('Map initialization completed')
    } catch (error) {
      console.error('Ошибка при инициализации карты:', error);
      console.error('Stack trace:', error.stack);
    }
  }
}
