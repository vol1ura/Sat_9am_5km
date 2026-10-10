export const CHART_SERIES_COUNT = 12;

const CHART_SERIES_FALLBACK_LIGHT = [
  '#5a5890', '#c4526a', '#b85c68', '#2f7a52', '#c4923a', '#7b78c0',
  '#c47a8a', '#8a6a9a', '#5a9e78', '#6a7088', '#a89878', '#2a2951',
];

const CHART_SERIES_FALLBACK_DARK = [
  '#b4b0d8', '#e08a96', '#d4a0a8', '#7aab8e', '#d9c08a', '#c4c0e8',
  '#e0b4bc', '#d4b0d4', '#a8c4a0', '#b0b4c4', '#d4ccb8', '#d9d3c8',
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
    ink: cssVar('--color-ink', dark ? '#f0f0f5' : '#1c1c28'),
    inkMuted: cssVar('--color-ink-muted', dark ? '#a8a8bc' : '#5a5a6c'),
    surface: cssVar('--color-surface', dark ? '#1a1a26' : '#ffffff'),
    surfaceElevated: cssVar('--color-surface-elevated', dark ? '#252536' : '#f7f7fb'),
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
    { from: 2, to: 2, color: cssVar('--chart-heatmap-ok', chartSeriesColors()[3]) },
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

export const BAR_FILL_OPACITY = 0.9;

export const AREA_ACCENT_FILL = {
  type: 'gradient',
  gradient: {
    shadeIntensity: 0.3,
    opacityFrom: 0.6,
    opacityTo: 0.1,
    stops: [0, 90, 100],
  },
};

export function formatMmSs(seconds) {
  return `${Math.floor(seconds / 60)}:${('00' + seconds % 60).slice(-2)}`;
}

export function formatCount(value) {
  return String(Math.round(value));
}

export function formatIntegerTick(value) {
  return Number.isInteger(value) ? formatCount(value) : '';
}

export function integerCountYaxis(overrides = {}) {
  const { labels: labelOverrides = {}, ...rest } = overrides;

  return {
    min: 0,
    decimalsInFloat: 0,
    stepSize: 1,
    forceNiceScale: false,
    ...rest,
    labels: {
      formatter: formatIntegerTick,
      ...labelOverrides,
    },
  };
}

export function barChartOptions({
  id,
  height,
  series,
  chart: chartOverrides = {},
  plotBar: plotBarOverrides = {},
  grid: gridOverrides = {},
  xaxis: xaxisOverrides = {},
  yaxis: yaxisOverrides = {},
  ...rest
} = {}) {
  const { theme, colors, foreColor, axisLabels } = apexThemeOptions();
  const layout = chartLayoutPadding();

  return {
    ...layout,
    grid: {
      ...layout.grid,
      ...gridOverrides,
      padding: {
        ...layout.grid.padding,
        ...gridOverrides.padding,
      },
    },
    series,
    chart: {
      ...layout.chart,
      id,
      type: 'bar',
      height,
      width: '100%',
      background: 'transparent',
      foreColor,
      toolbar: { show: false },
      zoom: { enabled: false },
      ...chartOverrides,
    },
    plotOptions: {
      bar: {
        horizontal: false,
        borderRadius: 10,
        borderRadiusApplication: 'around',
        ...plotBarOverrides,
      },
    },
    xaxis: {
      ...xaxisOverrides,
      labels: {
        ...axisLabels,
        ...xaxisOverrides.labels,
      },
      axisTicks: { show: false },
    },
    yaxis: {
      forceNiceScale: true,
      ...yaxisOverrides,
      labels: {
        ...axisLabels,
        ...yaxisOverrides.labels,
      },
    },
    colors,
    theme,
    fill: {
      opacity: BAR_FILL_OPACITY,
    },
    ...rest,
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

export const PIE_CHART_IDS = [
  'participants-chart',
  'gender-chart',
  'volunteers-chart',
  'volunteering-roles-chart',
];

export const CHART_IDS = [
  ...PIE_CHART_IDS,
  'results-count-chart',
  'volunteers-count-chart',
  'athlete-results-chart',
  'athlete-positions-chart',
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
    xaxis: { labels: axisLabels, axisTicks: { show: false } },
    yaxis: { labels: axisLabels },
  };
}

export function sparklineThemeUpdateOptions() {
  const { theme, foreColor, titleStyle } = apexThemeOptions();

  return {
    theme,
    chart: { foreColor },
    title: { style: titleStyle, margin: 16, offsetY: 12 },
    colors: [chartSparklineColors()[0]],
    yaxis: { min: 0, show: false },
  };
}

export function athleteResultsChartThemeUpdateOptions() {
  const accent = chartAccentColor();
  const { axisLabels } = apexThemeOptions();

  return {
    ...themeUpdateOptions(),
    colors: [accent],
    xaxis: { labels: axisLabels, axisTicks: { show: true } },
    yaxis: {
      reversed: true,
      opposite: true,
      labels: {
        ...axisLabels,
        formatter: formatMmSs,
      },
    },
    fill: AREA_ACCENT_FILL,
  };
}

export function volunteeringChartThemeUpdateOptions() {
  const { axisLabels } = apexThemeOptions();

  return {
    ...themeUpdateOptions(),
    yaxis: integerCountYaxis({
      labels: axisLabels,
    }),
  };
}

export function barAccentChartThemeUpdateOptions() {
  const { foreColor, axisLabels } = apexThemeOptions();

  return {
    ...themeUpdateOptions(),
    colors: [chartAccentColor()],
    fill: { opacity: BAR_FILL_OPACITY },
    dataLabels: {
      formatter: formatCount,
      style: { colors: [foreColor] },
    },
    yaxis: {
      labels: {
        ...axisLabels,
        formatter: formatCount,
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

export function pieDonutLabelColors() {
  const { ink, inkMuted } = chartColors();

  return {
    name: { color: inkMuted },
    value: { color: ink },
    total: { color: inkMuted },
  };
}

export function pieChartThemeUpdateOptions() {
  return {
    ...themeUpdateOptions(),
    plotOptions: {
      pie: {
        donut: {
          labels: pieDonutLabelColors(),
        },
      },
    },
  };
}
