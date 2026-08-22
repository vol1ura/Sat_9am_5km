export const CHART_SERIES_COUNT = 12;

const CHART_SERIES_FALLBACK_LIGHT = [
  '#6e69b8', '#2a9597', '#c45668', '#3b8559', '#c4923a', '#7b76c8',
  '#52b5b0', '#b86a9a', '#6a9e78', '#a85858', '#8a8578', '#524e78',
];

const CHART_SERIES_FALLBACK_DARK = [
  '#b5b0d9', '#8fd4d1', '#d4a0a8', '#7aab8e', '#d9c08a', '#c4c0e8',
  '#a8e0dc', '#d4b0d4', '#a8c4a0', '#c99595', '#c8c4d0', '#d9d3c8',
];

export function isDarkMode() {
  return document.documentElement.classList.contains('dark');
}

function cssVar(name, fallback = '') {
  return getComputedStyle(document.documentElement).getPropertyValue(name).trim() || fallback;
}

export function chartColors() {
  const dark = isDarkMode();

  return {
    ink: cssVar('--color-ink', dark ? '#f4f1ea' : '#1e1d2a'),
    inkMuted: cssVar('--color-ink-muted', dark ? '#a8a5b8' : '#5c5a68'),
    surfaceElevated: cssVar('--color-surface-elevated', dark ? '#2a2840' : '#fffcf7'),
  };
}

export function chartSeriesColors() {
  const fallback = isDarkMode() ? CHART_SERIES_FALLBACK_DARK : CHART_SERIES_FALLBACK_LIGHT;

  return Array.from({ length: CHART_SERIES_COUNT }, (_, index) => (
    cssVar(`--chart-series-${index + 1}`, fallback[index])
  ));
}

export function chartAccentColor() {
  return cssVar('--chart-accent', chartSeriesColors()[0]);
}

export function chartAccentFill() {
  return cssVar('--chart-accent-fill', chartSeriesColors()[0]);
}

export function chartSparklineColors() {
  return [
    cssVar('--chart-sparkline-1', chartSeriesColors()[0]),
    cssVar('--chart-sparkline-2', chartSeriesColors()[1]),
  ];
}

export function chartHeatmapScale() {
  const { surfaceElevated } = chartColors();

  return [
    { from: 0, to: 0, color: cssVar('--chart-heatmap-empty', surfaceElevated) },
    { from: 1, to: 1, color: cssVar('--chart-heatmap-deficit', chartSeriesColors()[2]) },
    { from: 2, to: 2, color: cssVar('--chart-heatmap-ok', chartSeriesColors()[1]) },
    { from: 3, to: 3, color: cssVar('--chart-heatmap-zone', chartSeriesColors()[4]) },
  ];
}

export function chartTitleOptions(text, overrides = {}) {
  const { titleStyle } = apexThemeOptions();
  const { style: styleOverride, ...rest } = overrides;

  return {
    text,
    align: 'center',
    margin: 16,
    offsetY: 12,
    style: { ...titleStyle, ...styleOverride },
    ...rest,
  };
}

export function chartLayoutPadding() {
  return {
    chart: {
      offsetY: 8,
    },
    grid: {
      padding: {
        top: 4,
        right: 8,
        left: 8,
      },
    },
  };
}

export function apexThemeOptions() {
  const dark = isDarkMode();
  const colors = chartColors();
  const seriesColors = chartSeriesColors();

  return {
    theme: {
      mode: dark ? 'dark' : 'light',
    },
    colors: seriesColors,
    foreColor: colors.ink,
    titleStyle: {
      color: colors.ink,
      fontSize: '1rem',
      fontWeight: 600,
    },
    legend: {
      labels: { colors: colors.ink },
    },
    axisLabels: {
      style: { colors: colors.inkMuted },
    },
  };
}

export const CHART_IDS = [
  'participants-chart',
  'gender-chart',
  'volunteers-chart',
  'results-count-chart',
  'volunteers-count-chart',
  'athlete-results-chart',
  'volunteering-chart',
  'h-index-chart',
];

export function themeUpdateOptions() {
  const { theme, foreColor, titleStyle, legend, colors, axisLabels } = apexThemeOptions();

  return {
    theme,
    chart: { foreColor, offsetY: 8 },
    title: { style: titleStyle, margin: 16, offsetY: 12 },
    legend,
    colors,
    xaxis: { labels: axisLabels },
    yaxis: { labels: axisLabels },
  };
}

export function sparklineThemeUpdateOptions(sparklineIndex = 0) {
  const sparklineColors = chartSparklineColors();

  return {
    ...themeUpdateOptions(),
    colors: [sparklineColors[sparklineIndex] ?? sparklineColors[0]],
  };
}

export function accentChartThemeUpdateOptions() {
  const accent = chartAccentColor();
  const { axisLabels } = apexThemeOptions();

  return {
    ...themeUpdateOptions(),
    colors: [accent],
    xaxis: { labels: axisLabels },
    yaxis: { labels: axisLabels },
    fill: {
      type: 'gradient',
      gradient: {
        shadeIntensity: 0.3,
        opacityFrom: 0.42,
        opacityTo: 0.08,
        stops: [0, 90, 100],
      },
    },
  };
}

export function heatmapThemeUpdateOptions() {
  return {
    ...themeUpdateOptions(),
    plotOptions: {
      heatmap: {
        colorScale: {
          ranges: chartHeatmapScale(),
        },
      },
    },
  };
}
