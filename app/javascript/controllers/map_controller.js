import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mapView", "listView", "mapButton", "listButton"]

  connect() {
    this.showList()

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
    this.mapButtonTarget.classList.add('btn-primary')
    this.mapButtonTarget.classList.remove('btn-outline-primary')
    this.listButtonTarget.classList.remove('btn-primary')
    this.listButtonTarget.classList.add('btn-outline-primary')
    this.mapViewTarget.classList.remove('d-none')
    this.listViewTarget.classList.add('d-none')

    // Обновляем размер карты при переключении на карту
    if (this.map) {
      this.map.container.fitToViewport()
    }
  }

  showList() {
    this.mapButtonTarget.classList.remove('btn-primary')
    this.mapButtonTarget.classList.add('btn-outline-primary')
    this.listButtonTarget.classList.remove('btn-outline-primary')
    this.listButtonTarget.classList.add('btn-primary')
    this.mapViewTarget.classList.add('d-none')
    this.listViewTarget.classList.remove('d-none')
  }

  async initializeMap() {
    try {
      console.log('Initializing map')
      const mapElement = document.getElementById('map')
      if (!mapElement) {
        throw new Error('Map element not found')
      }

      mapElement.style.minHeight = '600px'

      const defaultCenters = {
        ru: [55.7558, 37.6173], // Москва
        rs: [44.8206, 20.4622], // Белград
        by: [53.9045, 27.5615]  // Минск
      }
      const defaultZooms = {
        ru: 5, // Россия
        rs: 8, // Сербия
        by: 5  // Беларусь
      }
      const defaultCenter = defaultCenters[document.documentElement.lang] || defaultCenters.ru
      const defaultZoom = defaultZooms[document.documentElement.lang] || defaultZooms.ru

      this.map = new window.ymaps.Map('map', {
        center: defaultCenter,
        zoom: defaultZoom,
        controls: ['zoomControl']
      });

      // Пытаемся получить местоположение пользователя
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
          (position) => {
            const userLocation = [position.coords.latitude, position.coords.longitude]
            this.map.setCenter(userLocation, 10)
          },
          (error) => {
            console.log('Ошибка получения местоположения:', error)
            this.map.setCenter(defaultCenter, defaultZoom)
          }
        )
      } else {
        console.log('Геолокация не поддерживается браузером')
        this.map.setCenter(defaultCenter, defaultZoom)
      }

      console.log('Map instance created')

      // Получаем данные о событиях через AJAX
      try {
        const response = await fetch('/events.json?all=true')
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }
        const events = await response.json()
        console.log('Events loaded:', events.length)

        events.forEach(event => {
          const placemark = new window.ymaps.Placemark(
            [event.latitude, event.longitude],
            {
              balloonContent: `
                <div>
                  <h5>${event.name}</h5>
                  <p class="py-1 text-muted">${event.slogan}</p>
                  <a href="/events/${event.code_name}" class="btn btn-primary">Подробнее</a>
                </div>
              `,
              hintContent: event.name
            },
            {
              preset: event.active ? 'islands#redGovernmentCircleIcon' : 'islands#grayGovernmentCircleIcon'
            }
          );

          this.map.geoObjects.add(placemark);
        });

        // Обновляем размер карты после добавления меток
        this.map.container.fitToViewport()
        console.log('Map initialization completed')
      } catch (error) {
        console.error('Ошибка при загрузке данных о событиях:', error)
      }
    } catch (error) {
      console.error('Ошибка при инициализации карты:', error);
      console.error('Stack trace:', error.stack);
    }
  }
}
