import { Controller } from '@hotwired/stimulus';
import { addEventMarker, applyGeolocation, createMap, queryMapCenter } from 'maps/config';
import { createEventClusterGroup } from 'maps/marker_cluster';

export default class extends Controller {
  static values = { buttonLabel: String };

  connect() {
    this.initializeMap();
  }

  disconnect() {
    this.map?.remove();
  }

  async initializeMap() {
    const queryCenter = queryMapCenter();
    this.map = createMap(this.element, queryCenter || {});

    if (!queryCenter) applyGeolocation(this.map);

    try {
      const response = await fetch('/events.json?all=true');
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);

      const events = await response.json();
      const clusterGroup = createEventClusterGroup();
      events.forEach((event) => addEventMarker(clusterGroup, event, this.buttonLabelValue));
      this.map.addLayer(clusterGroup);
    } catch (error) {
      console.error('Error loading events data:', error);
    }
  }
}
