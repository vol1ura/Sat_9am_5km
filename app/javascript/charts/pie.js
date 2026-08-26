import ApexCharts from 'apexcharts';
import { apexThemeOptions, chartColors, chartTitleOptions, pieDonutLabelColors } from 'charts/theme';

function formatCount(value) {
  const numeric = Number(value);
  if (Number.isNaN(numeric)) return String(value);

  return new Intl.NumberFormat(document.documentElement.lang || undefined).format(numeric);
}

function chartFont(variableName) {
  return getComputedStyle(document.documentElement).getPropertyValue(variableName).trim() || undefined;
}

function donutLabelOptions(totalLabel) {
  const colors = pieDonutLabelColors();
  const displayFont = chartFont('--font-display');
  const sansFont = chartFont('--font-sans');

  return {
    show: true,
    name: {
      show: true,
      fontSize: '13px',
      fontFamily: sansFont,
      fontWeight: 400,
      offsetY: 18,
      ...colors.name,
    },
    value: {
      show: true,
      fontSize: '1.5rem',
      fontFamily: displayFont,
      fontWeight: 600,
      offsetY: -12,
      formatter: formatCount,
      ...colors.value,
    },
    total: {
      show: true,
      showAlways: true,
      label: totalLabel,
      fontSize: '13px',
      fontFamily: sansFont,
      fontWeight: 400,
      formatter: (w) => formatCount(w.globals.seriesTotals.reduce((sum, value) => sum + value, 0)),
      ...colors.total,
    },
  };
}

export function pieChartOptions({
  series,
  labels,
  chartId,
  unit,
  totalLabel,
  height = 240,
  title,
  showCountInLegend = false,
} = {}) {
  const { theme, colors, foreColor, legend } = apexThemeOptions();
  const { surface } = chartColors();

  return {
    chart: {
      id: chartId,
      height,
      width: '100%',
      type: 'donut',
      background: 'transparent',
      foreColor,
      animations: {
        speed: 400,
      },
    },
    series,
    labels,
    ...(title ? { title: chartTitleOptions(title) } : {}),
    legend: {
      position: 'bottom',
      fontSize: '13px',
      itemMargin: {
        horizontal: 8,
        vertical: 4,
      },
      ...legend,
      ...(showCountInLegend
        ? {
            formatter: (seriesName, opts) => (
              `${seriesName} (${formatCount(opts.w.globals.series[opts.seriesIndex])})`
            ),
          }
        : {}),
    },
    dataLabels: {
      enabled: true,
      style: {
        fontSize: '11px',
        fontWeight: 600,
      },
      dropShadow: {
        enabled: false,
      },
    },
    plotOptions: {
      pie: {
        dataLabels: {
          minAngleToShowLabel: 14,
        },
        donut: {
          size: '62%',
          labels: donutLabelOptions(totalLabel),
        },
      },
    },
    stroke: {
      width: 2,
      colors: [surface],
    },
    tooltip: {
      y: {
        formatter: (value) => `${value} ${unit}`,
      },
    },
    colors,
    theme,
    fill: {
      opacity: 0.92,
    },
  };
}

export function renderPieChart(element, options) {
  const chart = new ApexCharts(element, pieChartOptions(options));
  chart.render();
  return chart;
}
