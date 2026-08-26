import L from 'leaflet';

const FALLBACKS = {
  ru: { enter: 'На весь экран', exit: 'Свернуть' },
  en: { enter: 'Full screen', exit: 'Exit full screen' },
  sr: { enter: 'Ceo ekran', exit: 'Zatvori ceo ekran' },
};

const ENTER_SVG = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M7 14H5v5h5v-2H7v-3zm-2-4h2V7h3V5H5v5zm12 7h-3v2h5v-5h-2v3zM14 5v2h3v3h2V5h-5z"/></svg>';
const EXIT_SVG = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M5 16h3v3h2v-5H5v2zm3-8H5v2h5V5H8v3zm6 11h2v-3h3v-2h-5v5zm2-11V5h-2v5h5V8h-3z"/></svg>';

function langFallbacks() {
  return FALLBACKS[document.documentElement.lang] || FALLBACKS.ru;
}

function nativeFullscreenElement() {
  return document.fullscreenElement || document.webkitFullscreenElement || null;
}

function requestNativeFullscreen(element) {
  const request = element.requestFullscreen || element.webkitRequestFullscreen;
  if (!request) return Promise.reject();
  return Promise.resolve(request.call(element));
}

function exitNativeFullscreen() {
  const exit = document.exitFullscreen || document.webkitExitFullscreen;
  if (!exit) return Promise.resolve();
  return Promise.resolve(exit.call(document));
}

function invalidateSoon(map) {
  map.invalidateSize();
  requestAnimationFrame(() => map.invalidateSize());
}

const FullscreenControl = L.Control.extend({
  options: {
    position: 'topright',
    enterLabel: '',
    exitLabel: '',
  },

  onAdd(map) {
    this._map = map;
    this._containerEl = map.getContainer();
    const fallbacks = langFallbacks();
    this._enterLabel = this.options.enterLabel || fallbacks.enter;
    this._exitLabel = this.options.exitLabel || fallbacks.exit;

    const wrap = L.DomUtil.create('div', 'leaflet-control-fullscreen leaflet-bar');
    const link = L.DomUtil.create('a', 'leaflet-control-fullscreen-button', wrap);

    link.href = '#';
    link.setAttribute('role', 'button');
    link.setAttribute('aria-pressed', 'false');

    L.DomEvent.disableClickPropagation(link);
    L.DomEvent.on(link, 'click', L.DomEvent.stop);
    L.DomEvent.on(link, 'click', this._onClick, this);

    this._button = link;
    this._onChange = this._onChange.bind(this);
    this._onKeydown = this._onKeydown.bind(this);

    document.addEventListener('fullscreenchange', this._onChange);
    document.addEventListener('webkitfullscreenchange', this._onChange);
    document.addEventListener('keydown', this._onKeydown);

    this._syncButton();
    return wrap;
  },

  onRemove() {
    this._exit({ skipInvalidate: true });
    document.removeEventListener('fullscreenchange', this._onChange);
    document.removeEventListener('webkitfullscreenchange', this._onChange);
    document.removeEventListener('keydown', this._onKeydown);
  },

  _isPseudo() {
    return this._containerEl.classList.contains('map-is-fullscreen');
  },

  _isOn() {
    return nativeFullscreenElement() === this._containerEl || this._isPseudo();
  },

  _syncButton() {
    const on = this._isOn();
    this._button.innerHTML = on ? EXIT_SVG : ENTER_SVG;
    const label = on ? this._exitLabel : this._enterLabel;
    this._button.title = label;
    this._button.setAttribute('aria-label', label);
    this._button.setAttribute('aria-pressed', on ? 'true' : 'false');
  },

  _onClick() {
    if (this._isOn()) this._exit();
    else this._enter();
  },

  _onChange() {
    const native = nativeFullscreenElement();
    if (native && native !== this._containerEl) return;
    invalidateSoon(this._map);
    this._syncButton();
  },

  _onKeydown(event) {
    if (event.key === 'Escape' && this._isPseudo()) this._exit();
  },

  _enter() {
    requestNativeFullscreen(this._containerEl).catch(() => this._enterPseudo());
  },

  _enterPseudo() {
    this._containerEl.classList.add('map-is-fullscreen');
    document.body.classList.add('map-pseudo-fullscreen');
    invalidateSoon(this._map);
    this._syncButton();
  },

  _exit({ skipInvalidate = false } = {}) {
    if (nativeFullscreenElement() === this._containerEl) {
      exitNativeFullscreen();
    }

    if (this._isPseudo()) {
      this._containerEl.classList.remove('map-is-fullscreen');
      document.body.classList.remove('map-pseudo-fullscreen');
      if (!skipInvalidate && this._map) invalidateSoon(this._map);
    }

    this._syncButton();
  },
});

export function addFullscreenControl(map, { enterLabel, exitLabel } = {}) {
  const control = new FullscreenControl({ enterLabel, exitLabel });
  map.addControl(control);
  return control;
}
