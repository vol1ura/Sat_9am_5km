import { Controller } from '@hotwired/stimulus';
import { createMap, defaultCenter, defaultZoom } from 'maps/config';
import { loadGeoJsonLayer } from 'maps/geojson';

export default class extends Controller {
  static values = {
    url: String,
    latitude: Number,
    longitude: Number,
  };

  connect() {
    this.initializeMap();
  }

  disconnect() {
    this.map?.remove();
  }

  async initializeMap() {
    const center = this.hasLatitudeValue && this.hasLongitudeValue
      ? [this.latitudeValue, this.longitudeValue]
      : defaultCenter();

    this.map = createMap(this.element, { center, zoom: 15 });

    try {
      await loadGeoJsonLayer(this.map, this.urlValue);
    } catch (error) {
      console.error('Error loading route map:', error);
      this.map.setView(center, this.hasLatitudeValue ? 15 : defaultZoom());
    }
  }
}
