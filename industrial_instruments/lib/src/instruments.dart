import 'package:flutter/material.dart';
import 'models.dart';
import 'styles.dart';
import 'rendering.dart';
import 'readout.dart';
import 'gauges.dart';

// Geometry and value behavior live in InstrumentBody, not parameter wrappers.
abstract class _Measurement<T extends InstrumentStyle> extends StatelessWidget {
  const _Measurement({
    super.key,
    required this.shape,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '',
    this.label = '',
    this.formatter,
    this.target,
    this.bands = const [],
    required this.style,
    this.width,
    this.height,
    this.animate = false,
    this.orientation = Axis.horizontal,
    this.reference = 0,
    this.direction = FlowDirection.forward,
    this.state = EquipmentState.stopped,
    this.caption,
    this.secondaryScale,
    this.heightFraction,
  });
  final Shape shape;

  /// Application-supplied reading. Null and non-finite values remain missing.
  final double? value;

  /// Finite lower visual bound.
  final double min;

  /// Finite upper visual bound, greater than min.
  final double max;

  /// Explicit engineering unit; no conversion is performed.
  final String unit;

  /// Optional visible and accessible measurement name.
  final String label;

  /// Formatter for finite actual values; does not change visual geometry.
  final InstrumentFormatter? formatter;

  /// Optional target in the same units.
  final double? target;

  /// Explicit operating bands where the geometry supports them.
  final List<InstrumentBand> bands;

  /// Focused local visual settings.
  final T style;

  /// Logical width; unbounded layouts use 240. Minimum supported width is 180.
  final double? width;

  /// Plot height, excluding text. See the sizing guide for shape minimums.
  final double? height;

  /// Optional interpolation and decorative motion, respecting reduced motion.
  final bool animate;

  /// Axis for travel and range geometries.
  final Axis orientation;

  /// Explicit reference in engineering units, or degrees for AngleIndicator.
  final double reference;

  /// Application-supplied physical direction, independent of value sign.
  final FlowDirection direction;

  /// Observed operating state; never inferred from the reading.
  final EquipmentState state;
  final String? caption;
  final SecondaryScale? secondaryScale;
  final double? heightFraction;
  @override
  Widget build(BuildContext context) {
    if (shape == Shape.deviation &&
        ((reference - min) - (max - reference)).abs() >
            (max - min).abs() * 1e-10) {
      throw ArgumentError(
        'A centered scale needs bounds symmetric about its reference',
      );
    }
    return InstrumentBody(
      shape: shape,
      value: value,
      min: min,
      max: max,
      unit: unit,
      label: label,
      formatter: formatter,
      target: target,
      bands: List.unmodifiable(bands),
      style: style,
      width: width,
      height: height,
      animate: animate,
      axis: orientation,
      reference: reference,
      direction: direction,
      state: state,
      caption:
          caption ??
          (shape == Shape.flow || shape == Shape.rotation
              ? '${state.name} · ${direction.name}'
              : shape == Shape.angle
              ? 'Reference $reference° · ${direction.name}'
              : null),
      secondaryScale: secondaryScale,
      heightFraction: heightFraction,
    );
  }
}

/// A signed reading on a scale with an explicit reference marker.
class DeviationIndicator extends _Measurement<GaugeStyle> {
  /// Creates a controlled instrument with transparent surroundings.
  const DeviationIndicator({
    super.key,
    required super.value,
    super.min = -100,
    super.max = 100,
    super.reference = 0,
    super.unit = '',
    super.label,
    super.formatter,
    super.target,
    super.style = const GaugeStyle(),
    super.width,
    super.height,
    super.animate,
  }) : super(shape: Shape.deviation, caption: 'Reference $reference $unit');
}

/// A compact point-in-range instrument with explicit endpoint marks.
class RangeIndicator extends _Measurement<GaugeStyle> {
  /// Creates a controlled instrument with transparent surroundings.
  const RangeIndicator({
    super.key,
    required super.value,
    super.min = 0,
    super.max = 100,
    super.unit = '',
    super.label,
    super.formatter,
    super.target,
    super.orientation,
    super.style = const GaugeStyle(),
    super.width,
    super.height,
    super.animate,
  }) : super(shape: Shape.range);
}

/// A vector probe and application-supplied temperature reading.
class TemperatureProbe extends _Measurement<GaugeStyle> {
  /// Creates a controlled instrument with transparent surroundings.
  const TemperatureProbe({
    super.key,
    required super.value,
    super.min = 0,
    super.max = 120,
    super.unit = '°C',
    super.label,
    super.formatter,
    super.style = const GaugeStyle(),
    super.width,
    super.height,
    super.animate,
  }) : super(shape: Shape.probe);
}

/// Slim sight glass whose fill represents normalized liquid height.
class LevelTube extends _Measurement<LevelStyle> {
  /// Creates a controlled instrument with transparent surroundings.
  const LevelTube({
    super.key,
    required super.value,
    super.min = 0,
    super.max = 100,
    super.unit = '',
    super.label,
    super.formatter,
    super.style = const LevelStyle(),
    super.width,
    super.height,
    super.animate,
  }) : super(shape: Shape.tube, caption: 'Height');
}

/// Directional flow passage with a prominent application-supplied rate.
class FlowIndicator extends _Measurement<EquipmentStyle> {
  /// Creates a controlled instrument with transparent surroundings.
  const FlowIndicator({
    super.key,
    required super.value,
    super.min = 0,
    super.max = 100,
    super.unit = '',
    super.label,
    super.formatter,
    super.direction,
    super.state = EquipmentState.stopped,
    super.style = const EquipmentStyle(),
    super.width,
    super.height = 80,
    super.animate,
  }) : super(shape: Shape.flow);
}

/// Rotating shaft symbol with explicit speed, state and direction.
class RotationIndicator extends _Measurement<EquipmentStyle> {
  /// Creates a controlled instrument with transparent surroundings.
  const RotationIndicator({
    super.key,
    required super.value,
    super.min = 0,
    super.max = 3000,
    super.unit = 'rpm',
    super.label,
    super.formatter,
    super.direction,
    super.state = EquipmentState.stopped,
    super.style = const EquipmentStyle(),
    super.width,
    super.height,
    super.animate,
  }) : super(shape: Shape.rotation);
}

/// Linear travel with endpoint stops, position carriage and target.
class PositionIndicator extends _Measurement<GaugeStyle> {
  /// Creates a controlled instrument with transparent surroundings.
  const PositionIndicator({
    super.key,
    required super.value,
    super.min = 0,
    super.max = 100,
    super.unit = '',
    super.label,
    super.formatter,
    super.target,
    super.orientation,
    super.style = const GaugeStyle(),
    super.width,
    super.height,
    super.animate,
  }) : super(shape: Shape.position);
}

/// Angular position with an explicit reference axis and direction.
class AngleIndicator extends _Measurement<GaugeStyle> {
  /// Creates a controlled instrument with transparent surroundings.
  const AngleIndicator({
    super.key,
    required super.value,
    super.min = 0,
    super.max = 360,
    super.reference = 0,
    super.unit = '°',
    super.label,
    super.formatter,
    super.direction,
    super.style = const GaugeStyle(),
    super.width,
    super.height,
    super.animate,
  }) : super(shape: Shape.angle);
}

/// Pressure dial using the same needle and tick primitives as RadialGauge.
class PressureDial extends _Measurement<GaugeStyle> {
  /// Secondary labels are caller-supplied, not a hidden unit conversion.
  const PressureDial({
    super.key,
    required super.value,
    super.min = 0,
    super.max = 10,
    super.unit = 'bar',
    super.label,
    super.formatter,
    super.target,
    super.bands,
    super.secondaryScale,
    super.style = const GaugeStyle(),
    super.width,
    super.height,
    super.animate,
  }) : super(shape: Shape.radial);
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      super.build(context),
      if (secondaryScale != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '${secondaryScale!.min}–${secondaryScale!.max} ${secondaryScale!.unit} · secondary scale',
            style: InkSet(context, style).label,
          ),
        ),
    ],
  );
}

/// Differential pressure instrument with explicitly named measurement ports.
class DifferentialPressureIndicator extends _Measurement<GaugeStyle> {
  /// Negative or unidirectional ranges are application choices, not inferred.
  const DifferentialPressureIndicator({
    super.key,
    required super.value,
    super.min = -100,
    super.max = 100,
    super.reference = 0,
    super.unit = 'Pa',
    super.label,
    super.formatter,
    this.highPort = 'P+',
    this.lowPort = 'P−',
    super.target,
    super.style = const GaugeStyle(),
    super.width,
    super.height,
    super.animate,
  }) : super(shape: Shape.differential, caption: 'Reference $reference $unit');

  /// Upstream/high-side port name, without a safety interpretation.
  final String highPort;

  /// Downstream/low-side port name.
  final String lowPort;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 20,
        runSpacing: 8,
        children: [
          Text('○ $highPort', style: InkSet(context, style).label),
          Text('$lowPort ○', style: InkSet(context, style).label),
        ],
      ),
      const SizedBox(height: 6),
      super.build(context),
    ],
  );
}

/// Explicit gauge-relative or absolute-pressure dial; no pressure conversion.
class VacuumGauge extends _Measurement<GaugeStyle> {
  /// Requires the pressure convention and range to prevent ambiguous readings.
  const VacuumGauge({
    super.key,
    required super.value,
    required super.min,
    required super.max,
    required this.convention,
    super.unit = 'kPa',
    super.label,
    super.formatter,
    super.target,
    super.style = const GaugeStyle(),
    super.width,
    super.height,
    super.animate,
  }) : super(shape: Shape.radial);

  /// Atmospheric-relative (gauge) or perfect-vacuum-relative (absolute).
  final PressureConvention convention;
  @override
  Widget build(BuildContext context) {
    if (convention == PressureConvention.absolute && min < 0) {
      throw ArgumentError('Absolute pressure range cannot start below zero');
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        super.build(context),
        const SizedBox(height: 8),
        Text(
          convention == PressureConvention.gauge
              ? 'Gauge pressure · relative to atmosphere'
              : 'Absolute pressure · relative to vacuum',
          style: InkSet(context, style).label,
        ),
      ],
    );
  }
}

/// Horizontal vessel with explicit height-versus-volume semantics.
class HorizontalTank extends _Measurement<LevelStyle> {
  /// Volume mode requires a caller-calculated heightFraction for valid readings.
  const HorizontalTank({
    super.key,
    required super.value,
    super.min = 0,
    super.max = 100,
    super.unit = '%',
    super.label,
    super.formatter,
    this.quantity = LevelQuantity.height,
    super.heightFraction,
    super.style = const LevelStyle(),
    super.width,
    super.height = 140,
    super.animate,
  }) : super(shape: Shape.horizontalTank);

  /// Whether the displayed value denotes height or volume.
  final LevelQuantity quantity;
  @override
  Widget build(BuildContext context) {
    if (quantity == LevelQuantity.volume &&
        (value?.isFinite ?? false) &&
        heightFraction == null) {
      throw ArgumentError(
        'Volume readings require an application-calculated heightFraction',
      );
    }
    if (quantity == LevelQuantity.height && heightFraction != null) {
      throw ArgumentError('heightFraction is only used in volume mode');
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        super.build(context),
        const SizedBox(height: 6),
        Text(
          quantity == LevelQuantity.height
              ? 'Liquid height'
              : 'Volume · fill height supplied by application',
          style: InkSet(context, style).label,
        ),
      ],
    );
  }
}

/// Bipolar meter with zero at its center and an explicitly symmetric range.
class CenterZeroMeter extends _Measurement<GaugeStyle> {
  /// [extent] is the positive magnitude of both endpoints; no safe limits implied.
  const CenterZeroMeter({
    super.key,
    required super.value,
    this.extent = 100,
    super.unit = '',
    super.label,
    super.formatter,
    super.target,
    super.style = const GaugeStyle(),
    super.width,
    super.height,
    super.animate,
  }) : super(
         shape: Shape.deviation,
         min: -extent,
         max: extent,
         reference: 0,
         caption: 'Zero reference',
       );

  /// Positive finite half-range in engineering units.
  final double extent;
}

/// Frequency-focused readout with an optional explicit narrow-range scale.
class FrequencyMeter extends StatelessWidget {
  /// Supply both min/max to show the scale; no installation range is assumed.
  const FrequencyMeter({
    super.key,
    required this.value,
    this.min,
    this.max,
    this.reference,
    this.unit = 'Hz',
    this.label = 'Frequency',
    this.precision = 2,
    this.style = const GaugeStyle(),
    this.width,
    this.animate = false,
  });

  /// Observed frequency, or missing.
  final double? value;

  /// Optional lower visual bound, paired with max.
  final double? min;

  /// Optional upper visual bound, paired with min.
  final double? max;

  /// Optional reference marker, only valid with an explicit range.
  final double? reference;

  /// Engineering unit; defaults to Hz without converting data.
  final String unit;

  /// Descriptive label.
  final String label;

  /// Decimal places in the actual reading.
  final int precision;

  /// Local scale and readout styling.
  final GaugeStyle style;

  /// Defaults to available width or 240 unbounded. Minimum supported 180.
  final double? width;

  /// Optional scale interpolation, respecting reduced motion.
  final bool animate;
  @override
  Widget build(BuildContext context) {
    if ((min == null) != (max == null) || reference != null && min == null) {
      throw ArgumentError('Supply paired bounds for a reference scale');
    }
    if (min != null) validateRange(min!, max!);
    if (precision < 0 || precision > 6) {
      throw ArgumentError('precision must be 0–6');
    }
    return min == null
        ? DigitalReadout(
            value: value,
            unit: unit,
            label: label,
            precision: precision,
            style: style,
            width: width,
          )
        : LinearScale(
            value: value,
            min: min!,
            max: max!,
            target: reference,
            unit: unit,
            label: label,
            formatter: (v) => v.toStringAsFixed(precision),
            style: style,
            width: width,
            animate: animate,
          );
  }
}

/// Open/closed electrical contact, independent of any control command.
class ContactIndicator extends StatelessWidget {
  /// Null means unknown and never implies an open or closed contact.
  const ContactIndicator({
    super.key,
    required this.closed,
    this.label = '',
    this.style = const InstrumentStyle(),
    this.width,
    this.height = 80,
  });

  /// Application-supplied observed state.
  final bool? closed;

  /// Optional visible and semantic name.
  final String label;

  /// Local colors and stroke weight.
  final InstrumentStyle style;

  /// Defaults to available width or 240 unbounded. Minimum supported 180.
  final double? width;

  /// Drawing height, excluding the state caption; minimum supported 64.
  final double height;
  @override
  Widget build(BuildContext context) => InstrumentBody(
    shape: Shape.contact,
    style: style,
    value: closed == null
        ? null
        : closed!
        ? 1
        : 0,
    min: 0,
    max: 1,
    label: label,
    width: width,
    height: height,
    showValue: false,
    caption: closed == null
        ? 'Unknown'
        : closed!
        ? 'Closed'
        : 'Open',
  );
}
