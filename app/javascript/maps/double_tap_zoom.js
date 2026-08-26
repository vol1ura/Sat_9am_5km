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
// Finger must travel this far on the second tap before we steal the gesture.
// Below this, a short double tap is left to Leaflet's doubleClickZoom (+1).
const DRAG_START_PX = 8;
// Zoom levels per pixel of vertical travel: ~700px of map height covers about
// six levels, enough to go from a region to a district in a single move.
const ZOOM_PER_PX = 1 / 110;

// Center that keeps `anchor` under the finger at the new zoom — the same math
// Map.setZoomAround does internally.
function centerKeepingAnchor(map, anchor, zoom) {
  const scale = map.getZoomScale(zoom);
  const viewHalf = map.getSize().divideBy(2);
  const offset = map.latLngToContainerPoint(anchor).subtract(viewHalf).multiplyBy(1 - 1 / scale);

  return map.containerPointToLatLng(viewHalf.add(offset));
}

function mapIsLive(map) {
  return Boolean(map._mapPane && map._mapPane.parentNode);
}

export function addDoubleTapDragZoom(map) {
  const container = map.getContainer();

  let lastTapAt = 0;
  let lastTapPoint = null;

  // Second tap is down, but the finger has not moved enough to zoom yet.
  let candidate = false;
  // The map is being zoomed by this gesture.
  let zooming = false;
  let startPoint = null;
  let startY = 0;
  let startZoom = 0;
  let anchor = null;
  // The map has been moved at least once, so it has to be settled afterwards:
  // tiles for the final zoom level are loaded only then.
  let moved = false;
  let lastCenter = null;
  let lastZoom = 0;
  let pendingY = 0;
  let animRequest = null;
  let snapBeforeGesture = map.options.zoomSnap;
  let draggingWasEnabled = false;
  let doubleClickWasEnabled = false;
  let handlersHeld = false;

  const forgetTap = () => {
    lastTapAt = 0;
    lastTapPoint = null;
  };

  const holdHandlers = () => {
    if (handlersHeld) return;

    snapBeforeGesture = map.options.zoomSnap;
    map.options.zoomSnap = 0;
    draggingWasEnabled = map.dragging.enabled();
    doubleClickWasEnabled = map.doubleClickZoom.enabled();
    map.dragging.disable();
    map.doubleClickZoom.disable();
    handlersHeld = true;
  };

  const releaseHandlers = () => {
    if (!handlersHeld) return;

    map.options.zoomSnap = snapBeforeGesture;
    if (draggingWasEnabled) map.dragging.enable();
    if (doubleClickWasEnabled) map.doubleClickZoom.enable();
    handlersHeld = false;
  };

  const resetGesture = () => {
    candidate = false;
    zooming = false;
    startPoint = null;
    anchor = null;
    moved = false;
    lastCenter = null;
    forgetTap();
  };

  const cancelPendingFrame = () => {
    if (animRequest === null) return;
    L.Util.cancelAnimFrame(animRequest);
    animRequest = null;
  };

  // Settle tiles after a one-finger zoom. Restores dragging only on zoomend so
  // a new pan cannot start while the zoom animation is still running.
  const settle = () => {
    if (!moved || !lastCenter || !mapIsLive(map)) {
      releaseHandlers();
      resetGesture();
      return;
    }

    const settleZoom = map._limitZoom(lastZoom);
    const center = lastCenter;
    resetGesture();

    const restore = () => {
      map.off('zoomend', restore);
      releaseHandlers();
    };

    if (map.options.zoomAnimation) {
      map.once('zoomend', restore);
      map._animateZoom(center, settleZoom, true, false);
    } else {
      map._resetView(center, settleZoom);
      releaseHandlers();
    }
  };

  // Drop the gesture without rebuilding tiles — used when a second finger
  // arrives so Leaflet's own pinch can take over (it settles on lift).
  const abort = () => {
    cancelPendingFrame();
    releaseHandlers();
    resetGesture();
  };

  const applyZoom = () => {
    animRequest = null;
    if (!zooming || !anchor) return;

    const zoom = Math.max(map.getMinZoom(), Math.min(map.getMaxZoom(), startZoom + (pendingY - startY) * ZOOM_PER_PX));
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

  const beginZoom = (point) => {
    map._stop();
    holdHandlers();
    zooming = true;
    startY = point.y;
    startZoom = map.getZoom();
    anchor = map.containerPointToLatLng(point);
    lastCenter = null;
    lastZoom = startZoom;
    moved = false;
    pendingY = point.y;
  };

  const onTouchStart = (event) => {
    if (event.touches.length !== 1) {
      // Two fingers: a pinch, handled by Leaflet's own touchZoom.
      abort();
      return;
    }

    const point = map.mouseEventToContainerPoint(event.touches[0]);
    const now = event.timeStamp || Date.now();
    const isSecondTap = lastTapPoint
      && now - lastTapAt < DOUBLE_TAP_MS
      && lastTapPoint.distanceTo(point) < TAP_SLOP_PX;

    if (!isSecondTap) {
      lastTapAt = now;
      lastTapPoint = point;
      candidate = false;
      return;
    }

    // Remember the candidate only. Handlers stay on so a short double tap
    // still goes to Leaflet's doubleClickZoom (+1 level).
    candidate = true;
    startPoint = point;
    startY = point.y;
    startZoom = map.getZoom();
    lastZoom = startZoom;
  };

  const onTouchMove = (event) => {
    if (event.touches.length !== 1) {
      abort();
      return;
    }

    const point = map.mouseEventToContainerPoint(event.touches[0]);

    if (!candidate && !zooming) {
      // First tap turned into a pan — it must not count toward a double tap.
      if (lastTapPoint && lastTapPoint.distanceTo(point) > TAP_SLOP_PX) {
        forgetTap();
      }
      return;
    }

    if (candidate && !zooming) {
      if (startPoint.distanceTo(point) < DRAG_START_PX) return;
      beginZoom(startPoint);
    }

    if (!zooming) return;

    // Keep the page from scrolling under the gesture. Requires a non-passive
    // listener, otherwise the browser ignores preventDefault.
    event.preventDefault();
    pendingY = point.y;
    if (animRequest === null) {
      animRequest = L.Util.requestAnimFrame(applyZoom, map);
    }
  };

  const onTouchEnd = () => {
    if (zooming) {
      cancelPendingFrame();
      applyZoom();
      settle();
      return;
    }

    // Second tap lifted without dragging: leave doubleClickZoom alone.
    candidate = false;
    startPoint = null;
  };

  const onTouchCancel = () => {
    if (zooming || candidate) abort();
  };

  // Capture phase: Leaflet's own handlers sit on the same container, and
  // dragging has to be disabled before they see the touch.
  const options = { capture: true, passive: false };
  container.addEventListener('touchstart', onTouchStart, options);
  container.addEventListener('touchmove', onTouchMove, options);
  container.addEventListener('touchend', onTouchEnd, options);
  container.addEventListener('touchcancel', onTouchCancel, options);

  return () => {
    cancelPendingFrame();
    candidate = false;
    zooming = false;
    container.removeEventListener('touchstart', onTouchStart, options);
    container.removeEventListener('touchmove', onTouchMove, options);
    container.removeEventListener('touchend', onTouchEnd, options);
    container.removeEventListener('touchcancel', onTouchCancel, options);
  };
}
