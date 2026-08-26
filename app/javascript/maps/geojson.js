import L from 'leaflet';
import { mapColors } from 'maps/theme';

function routeStyle() {
  return { color: mapColors().route, weight: 4, opacity: 0.9 };
}

function pointColor(name = '') {
  const { start, finish, route } = mapColors();
  const label = name.toLowerCase();

  if (label.includes('старт') || label.includes('start')) return start;
  if (label.includes('финиш') || label.includes('finish')) return finish;

  return route;
}

function addStyledLayer(map, geojson) {
  const layers = L.geoJSON(geojson, {
    pointToLayer(_feature, latlng) {
      const name = _feature.properties?.name || '';
      return L.circleMarker(latlng, {
        radius: 6,
        color: mapColors().stroke,
        weight: 2,
        fillColor: pointColor(name),
        fillOpacity: 1,
      });
    },
    style(feature) {
      const geometryType = feature.geometry?.type;
      if (geometryType === 'LineString' || geometryType === 'MultiLineString') {
        return routeStyle();
      }

      return {};
    },
    onEachFeature(feature, layer) {
      const name = feature.properties?.name;
      if (name) layer.bindPopup(name);
    },
  });

  layers.addTo(map);
  return layers;
}

export async function loadGeoJsonLayer(map, url) {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`Failed to load GeoJSON: ${response.status}`);

  const geojson = await response.json();
  const layers = addStyledLayer(map, geojson);

  if (layers.getBounds().isValid()) {
    map.fitBounds(layers.getBounds(), { padding: [30, 30] });
  }

  return layers;
}
