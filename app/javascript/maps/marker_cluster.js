import L from 'leaflet';
import 'leaflet.markercluster';

export function createEventClusterGroup() {
  return L.markerClusterGroup({
    showCoverageOnHover: false,
    maxClusterRadius: 60,
    spiderfyOnMaxZoom: true,
    zoomToBoundsOnClick: true,
  });
}
