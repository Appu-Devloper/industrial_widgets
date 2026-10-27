import 'package:flutter/material.dart';
import 'package:industrial_instruments/industrial_instruments.dart';

const names = [
  'RadialGauge',
  'ArcMeter',
  'LinearScale',
  'SegmentedMeter',
  'DigitalReadout',
  'DeviationIndicator',
  'RangeIndicator',
  'Thermometer',
  'TemperatureProbe',
  'PressureDial',
  'DifferentialPressureIndicator',
  'VacuumGauge',
  'LiquidTank',
  'CylindricalTank',
  'HorizontalTank',
  'SiloIndicator',
  'LevelTube',
  'FlowIndicator',
  'PipeFlow',
  'RotationIndicator',
  'PositionIndicator',
  'AngleIndicator',
  'BatteryIndicator',
  'ThreePhaseReadout',
  'CenterZeroMeter',
  'FrequencyMeter',
  'PumpIndicator',
  'MotorIndicator',
  'ValveIndicator',
  'FanIndicator',
  'ConveyorIndicator',
  'StateLight',
  'ContactIndicator',
];
const categories = [
  'All instruments',
  'Temperature',
  'Pressure',
  'Level',
  'Flow',
  'Mechanical',
  'Electrical',
  'Analytical',
  'Digital',
];
const groups = [
  2,
  2,
  5,
  6,
  7,
  5,
  5,
  1,
  1,
  2,
  2,
  2,
  3,
  3,
  3,
  3,
  3,
  4,
  4,
  5,
  5,
  5,
  6,
  6,
  6,
  6,
  4,
  5,
  4,
  5,
  5,
  8,
  8,
];
const units = [
  'bar',
  '%',
  'mm',
  '%',
  'pH',
  'mm',
  'kg',
  '°C',
  '°C',
  'bar',
  'Pa',
  'kPa',
  '%',
  '%',
  '%',
  '%',
  'mm',
  'L/min',
  '',
  'rpm',
  'mm',
  '°',
  '%',
  'V',
  'kW',
  'Hz',
  '',
  'rpm',
  '',
  '',
  '',
  '',
  '',
];
const minima = <double>[
  0.0,
  0,
  0,
  0,
  0,
  -10,
  0,
  -20,
  -20,
  0,
  -100,
  -100,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  -100,
  45,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
];
const maxima = <double>[
  10.0,
  100,
  500,
  100,
  14,
  10,
  1000,
  120,
  120,
  10,
  100,
  0,
  100,
  100,
  100,
  100,
  1000,
  100,
  100,
  3000,
  500,
  360,
  100,
  260,
  100,
  55,
  100,
  3000,
  100,
  100,
  100,
  100,
  100,
];
const readings = <double>[
  6.4,
  68,
  320,
  68,
  7.2,
  2.4,
  680,
  72,
  72,
  6.4,
  24,
  -65,
  68,
  68,
  68,
  68,
  680,
  64,
  64,
  1480,
  320,
  120,
  68,
  230.2,
  24,
  50.02,
  68,
  1480,
  65,
  68,
  68,
  68,
  68,
];
String displayName(int i) => names[i].replaceAllMapped(
  RegExp(r'([a-z])([A-Z])'),
  (m) => '${m[1]} ${m[2]}',
);

Widget buildInstrument(
  int i, {
  double? value,
  double? min,
  double? max,
  String? unit,
  Color? accent,
  bool animate = false,
  bool vertical = false,
  EquipmentState state = EquipmentState.running,
  FlowDirection direction = FlowDirection.forward,
}) {
  final valid = value?.isFinite ?? false;
  final lo = min ?? minima[i], hi = max ?? maxima[i], u = unit ?? units[i];
  final g = GaugeStyle(accent: accent),
      l = LevelStyle(accent: accent, waves: true),
      e = EquipmentStyle(accent: accent),
      s = InstrumentStyle(accent: accent),
      axis = vertical ? Axis.vertical : Axis.horizontal;
  final target = lo + (hi - lo) * .8;
  return switch (i) {
    0 => RadialGauge(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      target: target,
      style: g,
      animate: animate,
    ),
    1 => ArcMeter(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      target: target,
      style: g,
      animate: animate,
    ),
    2 => LinearScale(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      target: target,
      orientation: axis,
      style: g,
      animate: animate,
    ),
    3 => SegmentedMeter(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      orientation: axis,
      style: g,
      animate: animate,
    ),
    4 => DigitalReadout(value: value, unit: u, precision: 2, style: s),
    5 => DeviationIndicator(
      value: value,
      min: lo,
      max: hi,
      reference: 0,
      unit: u,
      style: g,
      animate: animate,
    ),
    6 => RangeIndicator(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      style: g,
      orientation: axis,
      animate: animate,
    ),
    7 => Thermometer(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      style: g,
      animate: animate,
    ),
    8 => TemperatureProbe(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      style: g,
      animate: animate,
    ),
    9 => PressureDial(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      style: g,
      animate: animate,
    ),
    10 => DifferentialPressureIndicator(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      style: g,
      animate: animate,
    ),
    11 => VacuumGauge(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      convention: PressureConvention.gauge,
      style: g,
      animate: animate,
    ),
    12 => LiquidTank(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      style: l,
      animate: animate,
    ),
    13 => CylindricalTank(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      style: l,
      animate: animate,
    ),
    14 => HorizontalTank(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      style: l,
      animate: animate,
    ),
    15 => SiloIndicator(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      style: l,
      animate: animate,
    ),
    16 => LevelTube(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      style: l,
      animate: animate,
    ),
    17 => FlowIndicator(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      style: e,
      state: state,
      direction: direction,
      animate: animate,
    ),
    18 => PipeFlow(
      path: const [
        Offset(0, .7),
        Offset(.3, .7),
        Offset(.3, .2),
        Offset(.75, .2),
        Offset(.75, .7),
        Offset(1, .7),
      ],
      style: e,
      state: state,
      direction: direction,
      animate: animate,
    ),
    19 => RotationIndicator(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      style: e,
      state: state,
      direction: direction,
      animate: animate,
    ),
    20 => PositionIndicator(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      target: target,
      style: g,
      orientation: axis,
      animate: animate,
    ),
    21 => AngleIndicator(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      direction: direction,
      style: g,
      animate: animate,
    ),
    22 => BatteryIndicator(
      value: value,
      min: lo,
      max: hi,
      unit: u,
      activity: BatteryActivity.charging,
      orientation: axis,
      style: l,
      animate: animate,
    ),
    23 => ThreePhaseReadout(
      values: [
        value,
        value == null ? null : value + 1.2,
        value == null ? null : value - .4,
      ],
      unit: u,
      style: s,
    ),
    24 => CenterZeroMeter(
      value: value,
      extent: hi,
      unit: u,
      style: g,
      animate: animate,
    ),
    25 => FrequencyMeter(
      value: value,
      min: lo,
      max: hi,
      reference: 50,
      unit: u,
      style: g,
      animate: animate,
    ),
    26 => PumpIndicator(
      state: state,
      direction: direction,
      style: e,
      animate: animate,
    ),
    27 => MotorIndicator(
      value: value,
      unit: u,
      showSpeed: true,
      state: state,
      direction: direction,
      style: e,
      animate: animate,
    ),
    28 => ValveIndicator(
      position: !valid
          ? ValvePosition.unknown
          : value! <= lo
          ? ValvePosition.closed
          : value >= hi
          ? ValvePosition.open
          : ValvePosition.intermediate,
      openingPercent: valid
          ? (((value! - lo) / (hi - lo) * 100).clamp(0, 100))
          : 50,
      style: e,
      animate: animate,
    ),
    29 => FanIndicator(
      state: state,
      direction: direction,
      style: e,
      animate: animate,
    ),
    30 => ConveyorIndicator(
      state: state,
      direction: direction,
      style: e,
      animate: animate,
    ),
    31 => StateLight(
      active: !valid ? null : value! > (lo + hi) / 2,
      label: 'Drive ready',
      style: s,
    ),
    _ => ContactIndicator(
      closed: !valid ? null : value! > (lo + hi) / 2,
      label: 'Limit contact',
      style: s,
    ),
  };
}

String integrationCode(
  int i, {
  required double? value,
  required double min,
  required double max,
  required String unit,
  required Color accent,
  bool animate = false,
  bool vertical = false,
  EquipmentState state = EquipmentState.running,
  FlowDirection direction = FlowDirection.forward,
}) {
  final v = value?.toStringAsFixed(2) ?? 'null',
      u = unit
          .replaceAll('\\', '\\\\')
          .replaceAll("'", "\\'")
          .replaceAll(r'$', r'\$')
          .replaceAll('\n', r'\n');
  var args = 'value: $v,\n  min: $min, max: $max,\n  unit: \'$u\',';
  if (i == 4) args = "value: $v, unit: '$u', precision: 2,";
  if (i == 11) args += '\n  convention: PressureConvention.gauge,';
  if (i == 23) {
    args =
        "values: [$v, ${value == null ? 'null' : (value + 1.2).toStringAsFixed(2)}, ${value == null ? 'null' : (value - .4).toStringAsFixed(2)}],\n  unit: '$u',";
  }
  if (i == 24) args = "value: $v, extent: $max, unit: '$u',";
  if (i == 25) args += '\n  reference: 50,';
  if ([18, 26, 27, 29, 30].contains(i)) {
    args =
        'state: EquipmentState.${state.name},\n  direction: FlowDirection.${direction.name},';
  }
  if (i == 18) {
    args +=
        '\n  path: const [Offset(0, .7), Offset(.3, .7), Offset(.3, .2), Offset(.75, .2), Offset(.75, .7), Offset(1, .7)],';
  }
  if (i == 27) args += "\n  value: $v, unit: '$u', showSpeed: true,";
  if (i == 28) {
    args =
        'position: ValvePosition.${value == null
            ? 'unknown'
            : value <= min
            ? 'closed'
            : value >= max
            ? 'open'
            : 'intermediate'},\n  openingPercent: ${(((value ?? min) - min) / (max - min) * 100).clamp(0, 100).toStringAsFixed(1)},';
  }
  if (i == 31) {
    args = 'active: ${value == null ? 'null' : value > (min + max) / 2},';
  }
  if (i == 32) {
    args = 'closed: ${value == null ? 'null' : value > (min + max) / 2},';
  }
  if ([2, 3, 6, 20, 22].contains(i)) {
    args += '\n  orientation: Axis.${vertical ? 'vertical' : 'horizontal'},';
  }
  if (i == 22) args += '\n  activity: BatteryActivity.charging,';
  if ([17, 19].contains(i)) {
    args +=
        '\n  state: EquipmentState.${state.name}, direction: FlowDirection.${direction.name},';
  }
  if (i == 21) args += '\n  direction: FlowDirection.${direction.name},';
  if (![4, 23, 31, 32].contains(i)) args += '\n  animate: $animate,';
  final style = [12, 13, 14, 15, 16, 22].contains(i)
      ? 'LevelStyle'
      : [17, 18, 19, 26, 27, 28, 29, 30].contains(i)
      ? 'EquipmentStyle'
      : [4, 23, 31, 32].contains(i)
      ? 'InstrumentStyle'
      : 'GaugeStyle';
  return '${names[i]}(\n  $args\n  style: $style(accent: Color(0x${accent.toARGB32().toRadixString(16).padLeft(8, '0')})),\n)';
}
