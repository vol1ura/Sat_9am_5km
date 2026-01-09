import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['mapView', 'listView', 'mapButton', 'listButton'];

  connect() {
    this.showList();

    // Ждем загрузки Яндекс.Карт API
    if (window.ymaps) {
      console.log('Yandex Maps API already loaded');
      window.ymaps.ready(() => this.initializeMap());
    } else {
      console.log('Waiting for Yandex Maps API to load');
      window.addEventListener('yandex-maps-ready', () => {
        console.log('Yandex Maps API ready event received');
        window.ymaps.ready(() => this.initializeMap());
      });
    }
  }

  showMap() {
    this.mapButtonTarget.classList.add('btn-primary');
    this.mapButtonTarget.classList.remove('btn-outline-primary');
    this.listButtonTarget.classList.remove('btn-primary');
    this.listButtonTarget.classList.add('btn-outline-primary');
    this.mapViewTarget.classList.remove('d-none');
    this.listViewTarget.classList.add('d-none');

    if (this.map) {
      this.map.container.fitToViewport();
    }
  }

  showList() {
    this.mapButtonTarget.classList.remove('btn-primary');
    this.mapButtonTarget.classList.add('btn-outline-primary');
    this.listButtonTarget.classList.remove('btn-outline-primary');
    this.listButtonTarget.classList.add('btn-primary');
    this.mapViewTarget.classList.add('d-none');
    this.listViewTarget.classList.remove('d-none');
  }

  async initializeMap() {
    try {
      console.log('Initializing map');
      const mapElement = document.getElementById('map');
      if (!mapElement) {
        throw new Error('Map element not found');
      }

      mapElement.style.minHeight = '600px';

      const defaultCenters = {
        ru: [55.7558, 37.6173], // Moscow
        sr: [44.8206, 20.4622], // Belgrade
        by: [53.9045, 27.5615]  // Minsk
      };
      const defaultZooms = {
        ru: 5, // Russia
        sr: 8, // Serbia
        by: 5  // Belarus
      };
      const defaultCenter = defaultCenters[document.documentElement.lang] || defaultCenters.ru;
      const defaultZoom = defaultZooms[document.documentElement.lang] || defaultZooms.ru;

      this.map = new window.ymaps.Map('map', {
        center: defaultCenter,
        zoom: defaultZoom,
        controls: ['zoomControl']
      });

      // Пытаемся получить местоположение пользователя
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
          (position) => {
            const userLocation = [position.coords.latitude, position.coords.longitude];
            this.map.setCenter(userLocation, 10);
          },
          (error) => {
            console.log('Error getting location:', error.message);
            this.map.setCenter(defaultCenter, defaultZoom);
          }
        );
      } else {
        console.log('Geolocation is not supported by this browser');
        this.map.setCenter(defaultCenter, defaultZoom);
      }

      console.log('Map instance created');

      try {
        const response = await fetch('/events.json?all=true');
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        const events = await response.json();
        console.log('Events loaded:', events.length);

        events.forEach(event => {
          const placemark = new window.ymaps.Placemark(
            [event.latitude, event.longitude],
            {
              balloonContent: `
                <h5 class="text-primary">${event.name}</h5>
                <p class="my-0 text-black">${event.town}</p>
                <a href="/events/${event.code_name}" class="btn btn-outline-primary btn-sm my-2">Подробнее</a>
              `,
              hintContent: event.name
            },
            {
              preset: event.active ? 'islands#redRunCircleIcon' : 'islands#grayAttentionCircleIcon'
            }
          );

          this.map.geoObjects.add(placemark);
        });

        this.map.container.fitToViewport();
        console.log('Map initialization completed');
      } catch (error) {
        console.error('Error loading events data:', error);
      }
    } catch (error) {
      console.error('Error initializing map:', error);
      console.error('Stack trace:', error.stack);
    }
  }
}
