import L from 'leaflet';

const USER_ZOOM = 14;
const FIT_MAX_ZOOM = 15;
const FIT_DURATION = 0.8;
const GEO_OPTIONS = { enableHighAccuracy: false, timeout: 10000, maximumAge: 300_000 };

const CROSSHAIR_SVG = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M12 2a1 1 0 0 1 1 1v1.07A8.01 8.01 0 0 1 19.93 11H21a1 1 0 1 1 0 2h-1.07A8.01 8.01 0 0 1 13 19.93V21a1 1 0 1 1-2 0v-1.07A8.01 8.01 0 0 1 4.07 13H3a1 1 0 1 1 0-2h1.07A8.01 8.01 0 0 1 11 4.07V3a1 1 0 0 1 1-1zm0 5a5 5 0 1 0 0 10 5 5 0 0 0 0-10zm0 3a2 2 0 1 1 0 4 2 2 0 0 1 0-4z"/></svg>';

function nearestEvent(map, origin, events) {
  const withCoords = events.filter((event) => (
    Number.isFinite(event.latitude) && Number.isFinite(event.longitude)
  ));
  const active = withCoords.filter((event) => event.active);
  const pool = active.length ? active : withCoords;

  let best = null;
  let bestDistance = Infinity;

  pool.forEach((event) => {
    const distance = map.distance(origin, L.latLng(event.latitude, event.longitude));
    if (distance < bestDistance) {
      bestDistance = distance;
      best = event;
    }
  });

  return best;
}

const LocateControl = L.Control.extend({
  options: {
    position: 'bottomright',
    locateLabel: '',
    locateFailedLabel: '',
  },

  initialize(options) {
    L.Util.setOptions(this, options);
    this._events = [];
    this._pendingOrigin = null;
  },

  onAdd(map) {
    this._map = map;
    const container = L.DomUtil.create('div', 'leaflet-control-locate leaflet-bar');
    const link = L.DomUtil.create('a', 'leaflet-control-locate-button', container);

    link.href = '#';
    link.innerHTML = CROSSHAIR_SVG;
    link.title = this.options.locateLabel;
    link.setAttribute('role', 'button');
    link.setAttribute('aria-label', this.options.locateLabel);

    L.DomEvent.disableClickPropagation(link);
    L.DomEvent.on(link, 'click', L.DomEvent.stop);
    L.DomEvent.on(link, 'click', this._onClick, this);

    this._button = link;
    return container;
  },

  onRemove() {
    this._clearUserLayer();
    this._pendingOrigin = null;
  },

  setEvents(events) {
    this._events = events;
    if (!this._pendingOrigin) return;

    const origin = this._pendingOrigin;
    this._pendingOrigin = null;
    this._flyToUserAndVenue(origin);
  },

  _setButtonLabel(text) {
    this._button.title = text;
    this._button.setAttribute('aria-label', text);
  },

  _onClick() {
    if (!navigator.geolocation) {
      this._setButtonLabel(this.options.locateFailedLabel);
      return;
    }

    this._button.setAttribute('aria-busy', 'true');

    navigator.geolocation.getCurrentPosition(
      (position) => {
        if (!this._map || !this._button) return;
        this._button.removeAttribute('aria-busy');
        this._setButtonLabel(this.options.locateLabel);
        this._onPosition(position);
      },
      () => {
        if (!this._button) return;
        this._button.removeAttribute('aria-busy');
        this._setButtonLabel(this.options.locateFailedLabel);
      },
      GEO_OPTIONS,
    );
  },

  _onPosition(position) {
    const origin = L.latLng(position.coords.latitude, position.coords.longitude);
    this._showUser(origin, position.coords.accuracy);
    this._flyToUserAndVenue(origin);
  },

  _showUser(latlng, accuracy) {
    const radius = Number.isFinite(accuracy) ? accuracy : 0;

    if (this._marker) {
      this._marker.setLatLng(latlng);
      this._circle.setLatLng(latlng).setRadius(radius);
      return;
    }

    this._circle = L.circle(latlng, {
      radius,
      color: '#0d6efd',
      weight: 1,
      fillColor: '#0d6efd',
      fillOpacity: 0.15,
      interactive: false,
    }).addTo(this._map);

    this._marker = L.circleMarker(latlng, {
      radius: 8,
      color: '#fff',
      weight: 2,
      fillColor: '#0d6efd',
      fillOpacity: 1,
      interactive: false,
    }).addTo(this._map);
  },

  _clearUserLayer() {
    this._marker?.remove();
    this._circle?.remove();
    this._marker = null;
    this._circle = null;
  },

  _flyToUserAndVenue(origin) {
    const event = nearestEvent(this._map, origin, this._events);

    if (!event) {
      this._map.flyTo(origin, USER_ZOOM, { duration: FIT_DURATION });
      if (!this._events.length) this._pendingOrigin = origin;
      return;
    }

    this._pendingOrigin = null;
    const venue = L.latLng(event.latitude, event.longitude);
    this._map.flyToBounds(L.latLngBounds([origin, venue]), {
      paddingTopLeft: [40, 40],
      paddingBottomRight: [48, 96],
      maxZoom: FIT_MAX_ZOOM,
      duration: FIT_DURATION,
    });
  },
});

export function addLocateControl(map, { locateLabel, locateFailedLabel } = {}) {
  const control = new LocateControl({ locateLabel, locateFailedLabel });
  map.addControl(control);
  return control;
}
