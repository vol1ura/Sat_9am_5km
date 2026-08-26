import { Controller } from '@hotwired/stimulus';
import { addEventMarker, createMap, queryMapCenter } from 'maps/config';
import { addLocateControl } from 'maps/locate';
import { createEventClusterGroup } from 'maps/marker_cluster';

export default class extends Controller {
  static values = {
    buttonLabel: String,
    locateLabel: String,
    locateFailedLabel: String,
  };

  connect() {
    this.initializeMap();
  }

  disconnect() {
    this.map?.remove();
  }

  async initializeMap() {
    const queryCenter = queryMapCenter();
    this.map = createMap(this.element, queryCenter || {});
    this.locateControl = addLocateControl(this.map, {
      locateLabel: this.locateLabelValue,
      locateFailedLabel: this.locateFailedLabelValue,
    });

    try {
      const response = await fetch('/events.json?all=true');
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);

      const events = await response.json();
      const clusterGroup = createEventClusterGroup();
      events.forEach((event) => addEventMarker(clusterGroup, event, this.buttonLabelValue));
      this.map.addLayer(clusterGroup);
      this.locateControl.setEvents(events);
    } catch (error) {
      console.error('Error loading events data:', error);
    }
  }
}
