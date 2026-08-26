import L from 'leaflet';
import { addDoubleTapDragZoom } from 'maps/double_tap_zoom';

window.L = L;

const DEFAULT_CENTERS = {
  ru: [55.7558, 37.6173],
  sr: [44.8206, 20.4622],
  by: [53.9045, 27.5615],
};

const DEFAULT_ZOOMS = {
  ru: 5,
  sr: 8,
  by: 5,
};

const OSM_TILE_URL = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

export function defaultCenter() {
  return DEFAULT_CENTERS[document.documentElement.lang] || DEFAULT_CENTERS.ru;
}

export function defaultZoom() {
  return DEFAULT_ZOOMS[document.documentElement.lang] || DEFAULT_ZOOMS.ru;
}

const OSM_ATTRIBUTION =
  '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors';

export function createMap(element, { center, zoom } = {}) {
  const map = L.map(element);
  map.attributionControl.setPrefix('S95');
  map.setView(center || defaultCenter(), zoom ?? defaultZoom());

  L.tileLayer(OSM_TILE_URL, { maxZoom: 19, attribution: OSM_ATTRIBUTION }).addTo(map);

  map.once('unload', addDoubleTapDragZoom(map));

  return map;
}

export function eventMarkerColor(active) {
  return active ? '#dc3545' : '#6c757d';
}

export function addEventMarker(map, event, buttonLabel) {
  const marker = L.circleMarker([event.latitude, event.longitude], {
    radius: 8,
    color: '#fff',
    weight: 2,
    fillColor: eventMarkerColor(event.active),
    fillOpacity: 1,
  });

  marker.bindPopup(`
    <h5 class="text-primary mb-1">${event.name}</h5>
    <p class="my-0 text-black">${event.place} (${event.town})</p>
    <a href="/events/${event.code_name}" class="btn btn-outline-primary btn-sm my-2">${buttonLabel}</a>
  `);

  marker.addTo(map);
  return marker;
}

export function applyGeolocation(map, zoom = 10) {
  if (!navigator.geolocation) return;

  navigator.geolocation.getCurrentPosition(
    (position) => {
      map.setView([position.coords.latitude, position.coords.longitude], zoom);
    },
    () => {},
    { enableHighAccuracy: false, timeout: 10000, maximumAge: 300_000 },
  );
}

export function queryMapCenter() {
  const params = new URLSearchParams(window.location.search);
  const lat = parseFloat(params.get('lat'));
  const lon = parseFloat(params.get('lon'));
  const zoom = parseInt(params.get('zoom'), 10);

  if (Number.isFinite(lat) && Number.isFinite(lon)) {
    return { center: [lat, lon], zoom: Number.isFinite(zoom) ? zoom : 14 };
  }

  return null;
}
