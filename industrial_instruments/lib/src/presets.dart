import 'package:flutter/foundation.dart';
import 'gauges.dart';
import 'levels.dart';
import 'readout.dart';
import 'styles.dart';

/// Editable label/unit/format choices. Presets never define safety bands or limits.
@immutable
class InstrumentPreset {
  /// Configuration only; values and ranges remain application responsibilities.
  InstrumentPreset({
    required this.label,
    required this.unit,
    this.precision = 1,
    this.convention = '',
  }) {
    if (precision < 0 || precision > 6) {
      throw ArgumentError('precision must be 0–6');
    }
  }

  /// Human-readable parameter name.
  final String label;

  /// Explicit engineering unit; no conversion is performed.
  final String unit;

  /// Number of decimal places for finite values.
  final int precision;

  /// Application-defined pressure, sign, or leading/lagging convention.
  final String convention;

  /// Returns an edited copy; there are no locked parameter assumptions.
  InstrumentPreset copyWith({
    String? label,
    String? unit,
    int? precision,
    String? convention,
  }) => InstrumentPreset(
    label: label ?? this.label,
    unit: unit ?? this.unit,
    precision: precision ?? this.precision,
    convention: convention ?? this.convention,
  );

  /// Formats a value without inventing a missing zero.
  String format(double value) =>
      value.isFinite ? value.toStringAsFixed(precision) : '—';
  String get _label => convention.isEmpty ? label : '$label · $convention';

  /// Builds a generic dial; every installation must provide its own range.
  RadialGauge radialGauge({
    required double? value,
    required double min,
    required double max,
    GaugeStyle style = const GaugeStyle(),
    bool animate = false,
  }) => RadialGauge(
    value: value,
    min: min,
    max: max,
    unit: unit,
    label: _label,
    formatter: format,
    style: style,
    animate: animate,
  );

  /// Builds a generic linear scale with caller-supplied range.
  LinearScale linearScale({
    required double? value,
    required double min,
    required double max,
    GaugeStyle style = const GaugeStyle(),
    bool animate = false,
  }) => LinearScale(
    value: value,
    min: min,
    max: max,
    unit: unit,
    label: _label,
    formatter: format,
    style: style,
    animate: animate,
  );

  /// Builds a numerical display without introducing a measurement range.
  DigitalReadout readout({
    required double? value,
    InstrumentStyle style = const InstrumentStyle(),
  }) => DigitalReadout(
    value: value,
    unit: unit,
    label: _label,
    precision: precision,
    style: style,
  );

  /// Builds a height-based liquid instrument with caller-supplied range.
  LiquidTank liquidTank({
    required double? value,
    required double min,
    required double max,
    LevelStyle style = const LevelStyle(),
    bool animate = false,
  }) => LiquidTank(
    value: value,
    min: min,
    max: max,
    unit: unit,
    label: _label,
    formatter: format,
    style: style,
    animate: animate,
  );
}

/// Unit-explicit starting points; none contain operating limits or safe ranges.
abstract final class ParameterPresets {
  /// Temperature in °C; no inferred operating limits.
  static final temperatureC = InstrumentPreset(
    label: 'Temperature',
    unit: '°C',
    precision: 1,
  );

  /// Temperature in °F; no inferred operating limits.
  static final temperatureF = InstrumentPreset(
    label: 'Temperature',
    unit: '°F',
    precision: 1,
  );

  /// Temperature in K; no inferred operating limits.
  static final temperatureK = InstrumentPreset(
    label: 'Temperature',
    unit: 'K',
    precision: 1,
  );

  /// Pressure in bar; no inferred operating limits.
  static final pressureBar = InstrumentPreset(
    label: 'Pressure',
    unit: 'bar',
    precision: 2,
  );

  /// Pressure in psi; no inferred operating limits.
  static final pressurePsi = InstrumentPreset(
    label: 'Pressure',
    unit: 'psi',
    precision: 1,
  );

  /// Pressure in kPa; no inferred operating limits.
  static final pressureKpa = InstrumentPreset(
    label: 'Pressure',
    unit: 'kPa',
    precision: 1,
  );

  /// Differential pressure in Pa; no inferred operating limits.
  static final differentialPressure = InstrumentPreset(
    label: 'Differential pressure',
    unit: 'Pa',
    precision: 1,
  );

  /// Flow in L/min; no inferred operating limits.
  static final flowLitres = InstrumentPreset(
    label: 'Flow',
    unit: 'L/min',
    precision: 1,
  );

  /// Flow in m³/h; no inferred operating limits.
  static final flowCubicMetres = InstrumentPreset(
    label: 'Flow',
    unit: 'm³/h',
    precision: 2,
  );

  /// Mass flow in kg/h; no inferred operating limits.
  static final massFlow = InstrumentPreset(
    label: 'Mass flow',
    unit: 'kg/h',
    precision: 1,
  );

  /// Liquid height in %; no inferred operating limits.
  static final levelPercent = InstrumentPreset(
    label: 'Liquid height',
    unit: '%',
    precision: 1,
  );

  /// Liquid height in mm; no inferred operating limits.
  static final levelMillimetres = InstrumentPreset(
    label: 'Liquid height',
    unit: 'mm',
    precision: 1,
  );

  /// Liquid height in m; no inferred operating limits.
  static final levelMetres = InstrumentPreset(
    label: 'Liquid height',
    unit: 'm',
    precision: 2,
  );

  /// Volume in L; no inferred operating limits.
  static final volumeLitres = InstrumentPreset(
    label: 'Volume',
    unit: 'L',
    precision: 1,
  );

  /// Volume in m³; no inferred operating limits.
  static final volumeCubicMetres = InstrumentPreset(
    label: 'Volume',
    unit: 'm³',
    precision: 2,
  );

  /// Mass in g; no inferred operating limits.
  static final massGrams = InstrumentPreset(
    label: 'Mass',
    unit: 'g',
    precision: 1,
  );

  /// Mass in kg; no inferred operating limits.
  static final massKilograms = InstrumentPreset(
    label: 'Mass',
    unit: 'kg',
    precision: 1,
  );

  /// Mass in t; no inferred operating limits.
  static final massTonnes = InstrumentPreset(
    label: 'Mass',
    unit: 't',
    precision: 2,
  );

  /// Load in N; no inferred operating limits.
  static final force = InstrumentPreset(label: 'Load', unit: 'N', precision: 1);

  /// Speed in rpm; no inferred operating limits.
  static final speedRpm = InstrumentPreset(
    label: 'Speed',
    unit: 'rpm',
    precision: 0,
  );

  /// Speed in m/min; no inferred operating limits.
  static final speedMetresMinute = InstrumentPreset(
    label: 'Speed',
    unit: 'm/min',
    precision: 1,
  );

  /// Speed in m/s; no inferred operating limits.
  static final speedMetresSecond = InstrumentPreset(
    label: 'Speed',
    unit: 'm/s',
    precision: 2,
  );

  /// Torque in N·m; no inferred operating limits.
  static final torque = InstrumentPreset(
    label: 'Torque',
    unit: 'N·m',
    precision: 1,
  );

  /// Position in mm; no inferred operating limits.
  static final positionMillimetres = InstrumentPreset(
    label: 'Position',
    unit: 'mm',
    precision: 1,
  );

  /// Position in cm; no inferred operating limits.
  static final positionCentimetres = InstrumentPreset(
    label: 'Position',
    unit: 'cm',
    precision: 2,
  );

  /// Position in m; no inferred operating limits.
  static final positionMetres = InstrumentPreset(
    label: 'Position',
    unit: 'm',
    precision: 3,
  );

  /// Angle in °; no inferred operating limits.
  static final angle = InstrumentPreset(
    label: 'Angle',
    unit: '°',
    precision: 1,
  );

  /// Voltage in V; no inferred operating limits.
  static final voltage = InstrumentPreset(
    label: 'Voltage',
    unit: 'V',
    precision: 1,
  );

  /// Voltage in kV; no inferred operating limits.
  static final voltageKv = InstrumentPreset(
    label: 'Voltage',
    unit: 'kV',
    precision: 2,
  );

  /// Current in mA; no inferred operating limits.
  static final currentMa = InstrumentPreset(
    label: 'Current',
    unit: 'mA',
    precision: 2,
  );

  /// Current in A; no inferred operating limits.
  static final current = InstrumentPreset(
    label: 'Current',
    unit: 'A',
    precision: 2,
  );

  /// Power in W; no inferred operating limits.
  static final powerWatts = InstrumentPreset(
    label: 'Power',
    unit: 'W',
    precision: 1,
  );

  /// Power in kW; no inferred operating limits.
  static final powerKw = InstrumentPreset(
    label: 'Power',
    unit: 'kW',
    precision: 2,
  );

  /// Power in MW; no inferred operating limits.
  static final powerMw = InstrumentPreset(
    label: 'Power',
    unit: 'MW',
    precision: 3,
  );

  /// Reactive power in kvar; no inferred operating limits.
  static final reactivePower = InstrumentPreset(
    label: 'Reactive power',
    unit: 'kvar',
    precision: 2,
  );

  /// Apparent power in kVA; no inferred operating limits.
  static final apparentPower = InstrumentPreset(
    label: 'Apparent power',
    unit: 'kVA',
    precision: 2,
  );

  /// Energy in Wh; no inferred operating limits.
  static final energyWh = InstrumentPreset(
    label: 'Energy',
    unit: 'Wh',
    precision: 1,
  );

  /// Energy in kWh; no inferred operating limits.
  static final energyKwh = InstrumentPreset(
    label: 'Energy',
    unit: 'kWh',
    precision: 2,
  );

  /// Frequency in Hz; no inferred operating limits.
  static final frequency = InstrumentPreset(
    label: 'Frequency',
    unit: 'Hz',
    precision: 2,
  );

  /// Humidity in %RH; no inferred operating limits.
  static final humidity = InstrumentPreset(
    label: 'Humidity',
    unit: '%RH',
    precision: 1,
  );

  /// pH in dimensionless units; no inferred operating limits.
  static final ph = InstrumentPreset(label: 'pH', unit: '', precision: 2);

  /// Conductivity in µS/cm; no inferred operating limits.
  static final conductivityMicro = InstrumentPreset(
    label: 'Conductivity',
    unit: 'µS/cm',
    precision: 1,
  );

  /// Conductivity in mS/cm; no inferred operating limits.
  static final conductivityMilli = InstrumentPreset(
    label: 'Conductivity',
    unit: 'mS/cm',
    precision: 2,
  );

  /// Dissolved oxygen in mg/L; no inferred operating limits.
  static final dissolvedOxygen = InstrumentPreset(
    label: 'Dissolved oxygen',
    unit: 'mg/L',
    precision: 2,
  );

  /// Turbidity in NTU; no inferred operating limits.
  static final turbidity = InstrumentPreset(
    label: 'Turbidity',
    unit: 'NTU',
    precision: 1,
  );

  /// Gas concentration in ppm; no inferred operating limits.
  static final gasPpm = InstrumentPreset(
    label: 'Gas concentration',
    unit: 'ppm',
    precision: 1,
  );

  /// Gas concentration in %vol; no inferred operating limits.
  static final gasVolume = InstrumentPreset(
    label: 'Gas concentration',
    unit: '%vol',
    precision: 2,
  );

  /// Gas concentration in %LEL; no inferred operating limits.
  static final gasLel = InstrumentPreset(
    label: 'Gas concentration',
    unit: '%LEL',
    precision: 1,
  );

  /// Vibration velocity in mm/s; no inferred operating limits.
  static final vibrationVelocity = InstrumentPreset(
    label: 'Vibration velocity',
    unit: 'mm/s',
    precision: 2,
  );

  /// Vibration acceleration in m/s²; no inferred operating limits.
  static final vibrationAcceleration = InstrumentPreset(
    label: 'Vibration acceleration',
    unit: 'm/s²',
    precision: 2,
  );

  /// Caller must state gauge or absolute convention; this performs no conversion.
  static InstrumentPreset vacuum({
    required String unit,
    required String convention,
  }) {
    if (convention.trim().isEmpty) {
      throw ArgumentError('State the pressure convention');
    }
    return InstrumentPreset(
      label: 'Vacuum',
      unit: unit,
      precision: 2,
      convention: convention,
    );
  }

  /// Caller must state sign and leading/lagging interpretation, without inference.
  static InstrumentPreset powerFactor({required String convention}) {
    if (convention.trim().isEmpty) {
      throw ArgumentError('State the sign and leading/lagging convention');
    }
    return InstrumentPreset(
      label: 'Power factor',
      unit: '',
      precision: 3,
      convention: convention,
    );
  }
}
