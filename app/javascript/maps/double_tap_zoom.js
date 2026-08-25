import L from 'leaflet';

// One-handed zoom gesture used by Google/Yandex Maps mobile apps: tap twice and,
// without lifting the second tap, drag. Dragging up zooms out, dragging down
// zooms in. Leaflet ships only pinch (touchZoom) and "double tap = +1 level"
// (doubleClickZoom), so the handler below is built from the same internal calls
// its own pinch handler uses.

// The second tap has to start within this time after the first one...
const DOUBLE_TAP_MS = 320;
// ...and no further than this from it, otherwise these are two separate taps.
const TAP_SLOP_PX = 32;
// Zoom levels per pixel of vertical travel: ~700px of map height covers about
// six levels, enough to go from a region to a district in a single move.
const ZOOM_PER_PX = 1 / 110;
// At most once per frame. requestAnimationFrame is avoided on purpose: it does
// not tick in background tabs, and the gesture would freeze there.
const FRAME_MS = 16;

// Center that keeps `anchor` under the finger at the new zoom — the same math
// Map.setZoomAround does internally.
function centerKeepingAnchor(map, anchor, zoom) {
  const scale = map.getZoomScale(zoom);
  const viewHalf = map.getSize().divideBy(2);
  const offset = map.latLngToContainerPoint(anchor).subtract(viewHalf).multiplyBy(1 - 1 / scale);

  return map.containerPointToLatLng(viewHalf.add(offset));
}

export function addDoubleTapDragZoom(map) {
  const container = map.getContainer();

  let lastTapAt = 0;
  let lastTapPoint = null;

  let active = false;
  let startY = 0;
  let startZoom = 0;
  let anchor = null;
  let lastMoveAt = 0;
  // The map has been moved at least once, so it has to be settled afterwards:
  // tiles for the final zoom level are loaded only then.
  let moved = false;
  let lastCenter = null;
  let lastZoom = 0;
  let snapBeforeGesture = map.options.zoomSnap;
  let draggingWasEnabled = false;
  let doubleClickWasEnabled = false;

  const stop = () => {
    if (!active) return;

    active = false;
    anchor = null;
    // Settle on the final zoom BEFORE restoring zoomSnap: with zoomSnap = 0
    // Leaflet keeps the fractional zoom the gesture ended on instead of jumping
    // to a whole level. This is the single tile reload of the whole gesture.
    if (moved && lastCenter) {
      const settleZoom = map._limitZoom(lastZoom);
      if (map.options.zoomAnimation) {
        map._animateZoom(lastCenter, settleZoom, true, false);
      } else {
        map._resetView(lastCenter, settleZoom);
      }
    }
    moved = false;
    lastCenter = null;
    map.options.zoomSnap = snapBeforeGesture;
    if (draggingWasEnabled) map.dragging.enable();
    if (doubleClickWasEnabled) map.doubleClickZoom.enable();
    // Forget the first tap so that lifting the finger after a gesture does not
    // start a new double tap.
    lastTapAt = 0;
    lastTapPoint = null;
  };

  const onTouchStart = (event) => {
    if (event.touches.length !== 1) {
      // Two fingers: a pinch, handled by Leaflet's own touchZoom.
      stop();
      return;
    }

    const touch = event.touches[0];
    const point = { x: touch.clientX, y: touch.clientY };
    const now = event.timeStamp || Date.now();
    const isSecondTap = lastTapPoint
      && now - lastTapAt < DOUBLE_TAP_MS
      && Math.abs(point.x - lastTapPoint.x) < TAP_SLOP_PX
      && Math.abs(point.y - lastTapPoint.y) < TAP_SLOP_PX;

    if (!isSecondTap) {
      lastTapAt = now;
      lastTapPoint = point;
      return;
    }

    active = true;
    startY = point.y;
    startZoom = map.getZoom();
    // Zoom around the touched point rather than the map center: the finger is
    // on the very place the user wants to look at.
    const bounds = container.getBoundingClientRect();
    anchor = map.containerPointToLatLng(L.point(point.x - bounds.left, point.y - bounds.top));
    snapBeforeGesture = map.options.zoomSnap;
    // Without this Leaflet rounds the zoom to whole levels and the smooth zoom
    // turns into jumps.
    map.options.zoomSnap = 0;
    draggingWasEnabled = map.dragging.enabled();
    doubleClickWasEnabled = map.doubleClickZoom.enabled();
    // Panning would drag the map along with the zoom, and Leaflet's own double
    // tap would add its level on top of ours.
    map.dragging.disable();
    map.doubleClickZoom.disable();
    lastMoveAt = 0;
    moved = false;
    lastCenter = null;
    lastZoom = startZoom;
    event.preventDefault();
  };

  const onTouchMove = (event) => {
    if (!active || !anchor) return;

    if (event.touches.length !== 1) {
      stop();
      return;
    }

    // Keep the page from scrolling under the gesture. Requires a non-passive
    // listener, otherwise the browser ignores preventDefault.
    event.preventDefault();

    const now = event.timeStamp || Date.now();
    if (now - lastMoveAt < FRAME_MS) return;

    lastMoveAt = now;
    // Dragging up zooms OUT: the finger pushes the map away from the viewer.
    const delta = (event.touches[0].clientY - startY) * ZOOM_PER_PX;
    const zoom = Math.max(map.getMinZoom(), Math.min(map.getMaxZoom(), startZoom + delta));
    if (Math.abs(zoom - map.getZoom()) < 0.01) return;

    const center = centerKeepingAnchor(map, anchor, zoom);
    if (!moved) {
      map._moveStart(true, false);
      moved = true;
    }
    lastCenter = center;
    lastZoom = zoom;
    // Move the map exactly like the built-in pinch does: the `pinch` flag tells
    // the tile layer to only re-transform already loaded tiles instead of
    // rebuilding the grid, so nothing flickers while the finger moves.
    map._move(center, zoom, { pinch: true, round: false });
  };

  // Capture phase: Leaflet's own handlers sit on the same container, and
  // dragging has to be disabled before they see the touch.
  const options = { capture: true, passive: false };
  container.addEventListener('touchstart', onTouchStart, options);
  container.addEventListener('touchmove', onTouchMove, options);
  container.addEventListener('touchend', stop, options);
  container.addEventListener('touchcancel', stop, options);

  return () => {
    stop();
    container.removeEventListener('touchstart', onTouchStart, options);
    container.removeEventListener('touchmove', onTouchMove, options);
    container.removeEventListener('touchend', stop, options);
    container.removeEventListener('touchcancel', stop, options);
  };
}
