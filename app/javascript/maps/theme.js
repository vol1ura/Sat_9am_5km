function cssVar(name, fallback = '') {
  return getComputedStyle(document.documentElement).getPropertyValue(name).trim() || fallback;
}

export function mapColors() {
  return {
    route: cssVar('--map-route', cssVar('--color-accent', '#c4526a')),
    start: cssVar('--map-start', cssVar('--color-success', '#2f7a52')),
    finish: cssVar('--map-finish', cssVar('--color-danger', '#c63b3b')),
    active: cssVar('--map-active', cssVar('--color-danger', '#c63b3b')),
    inactive: cssVar('--map-inactive', cssVar('--color-ink-muted', '#5a5a6c')),
    locate: cssVar('--map-locate', cssVar('--color-brand', '#2a2951')),
    stroke: '#fff',
  };
}
