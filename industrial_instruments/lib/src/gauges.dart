import 'package:flutter/material.dart';
import 'models.dart';
import 'styles.dart';
import 'rendering.dart';

/// Standalone RadialGauge with transparent surroundings and controlled engineering values.
/// Missing/nonfinite values omit the indicator. Out-of-range positions clamp,
/// while the original reading stays visible. Unbounded width defaults to 240.
class RadialGauge extends StatelessWidget {
  /// Creates an instrument; no controller or app-wide theme is required.
  const RadialGauge({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '',
    this.label = '',
    this.formatter,
    this.target,
    this.bands = const [],
    this.style = const GaugeStyle(),
    this.width,
    this.height,
    this.animate = false,
  });

  /// Actual engineering reading; null/NaN/infinity means missing.
  final double? value;

  /// Finite lower display bound.
  final double min;

  /// Finite upper display bound, greater than min.
  final double max;

  /// Engineering unit, shown separately from the value.
  final String unit;

  /// Optional descriptive label and semantic name.
  final String label;

  /// Finite-value formatter; does not alter the visual position.
  final InstrumentFormatter? formatter;

  /// Optional target in engineering units; must be finite.
  final double? target;

  /// Optional explicitly colored operating bands.
  final List<InstrumentBand> bands;

  /// Focused local visual style.
  final GaugeStyle style;

  /// Optional logical width. Unbounded parents default to 240.
  final double? width;

  /// Optional plot height, excluding labels and value text.
  final double? height;

  /// Enables value transitions; reduced motion always takes precedence.
  final bool animate;
  @override
  Widget build(BuildContext context) => InstrumentBody(
    shape: Shape.radial,
    style: style,
    value: value,
    min: min,
    max: max,
    unit: unit,
    label: label,
    formatter: formatter,
    target: target,
    bands: List.unmodifiable(bands),
    width: width,
    height: height,
    animate: animate,
  );
}

/// Standalone ArcMeter with transparent surroundings and controlled engineering values.
/// Missing/nonfinite values omit the indicator. Out-of-range positions clamp,
/// while the original reading stays visible. Unbounded width defaults to 240.
class ArcMeter extends StatelessWidget {
  /// Creates an instrument; no controller or app-wide theme is required.
  const ArcMeter({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '',
    this.label = '',
    this.formatter,
    this.target,
    this.bands = const [],
    this.style = const GaugeStyle(),
    this.width,
    this.height,
    this.animate = false,
  });

  /// Actual engineering reading; null/NaN/infinity means missing.
  final double? value;

  /// Finite lower display bound.
  final double min;

  /// Finite upper display bound, greater than min.
  final double max;

  /// Engineering unit, shown separately from the value.
  final String unit;

  /// Optional descriptive label and semantic name.
  final String label;

  /// Finite-value formatter; does not alter the visual position.
  final InstrumentFormatter? formatter;

  /// Optional target in engineering units; must be finite.
  final double? target;

  /// Optional explicitly colored operating bands.
  final List<InstrumentBand> bands;

  /// Focused local visual style.
  final GaugeStyle style;

  /// Optional logical width. Unbounded parents default to 240.
  final double? width;

  /// Optional plot height, excluding labels and value text.
  final double? height;

  /// Enables value transitions; reduced motion always takes precedence.
  final bool animate;
  @override
  Widget build(BuildContext context) => InstrumentBody(
    shape: Shape.arc,
    style: style,
    value: value,
    min: min,
    max: max,
    unit: unit,
    label: label,
    formatter: formatter,
    target: target,
    bands: List.unmodifiable(bands),
    width: width,
    height: height,
    animate: animate,
  );
}

/// Standalone LinearScale with transparent surroundings and controlled engineering values.
/// Missing/nonfinite values omit the indicator. Out-of-range positions clamp,
/// while the original reading stays visible. Unbounded width defaults to 240.
class LinearScale extends StatelessWidget {
  /// Creates an instrument; no controller or app-wide theme is required.
  const LinearScale({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '',
    this.label = '',
    this.formatter,
    this.target,
    this.bands = const [],
    this.style = const GaugeStyle(),
    this.orientation = Axis.horizontal,
    this.width,
    this.height,
    this.animate = false,
  });

  /// Actual engineering reading; null/NaN/infinity means missing.
  final double? value;

  /// Finite lower display bound.
  final double min;

  /// Finite upper display bound, greater than min.
  final double max;

  /// Engineering unit, shown separately from the value.
  final String unit;

  /// Optional descriptive label and semantic name.
  final String label;

  /// Finite-value formatter; does not alter the visual position.
  final InstrumentFormatter? formatter;

  /// Optional target in engineering units; must be finite.
  final double? target;

  /// Optional explicitly colored operating bands.
  final List<InstrumentBand> bands;

  /// Focused local visual style.
  final GaugeStyle style;

  /// Orientation where meaningful; radial/vessel silhouettes stay upright.
  final Axis orientation;

  /// Optional logical width. Unbounded parents default to 240.
  final double? width;

  /// Optional plot height, excluding labels and value text.
  final double? height;

  /// Enables value transitions; reduced motion always takes precedence.
  final bool animate;
  @override
  Widget build(BuildContext context) => InstrumentBody(
    shape: Shape.linear,
    style: style,
    value: value,
    min: min,
    max: max,
    unit: unit,
    label: label,
    formatter: formatter,
    target: target,
    bands: List.unmodifiable(bands),
    axis: orientation,
    width: width,
    height: height,
    animate: animate,
  );
}

/// Standalone SegmentedMeter with transparent surroundings and controlled engineering values.
/// Missing/nonfinite values omit the indicator. Out-of-range positions clamp,
/// while the original reading stays visible. Unbounded width defaults to 240.
class SegmentedMeter extends StatelessWidget {
  /// Creates an instrument; no controller or app-wide theme is required.
  const SegmentedMeter({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '',
    this.label = '',
    this.formatter,
    this.target,
    this.bands = const [],
    this.style = const GaugeStyle(),
    this.orientation = Axis.horizontal,
    this.width,
    this.height,
    this.animate = false,
  });

  /// Actual engineering reading; null/NaN/infinity means missing.
  final double? value;

  /// Finite lower display bound.
  final double min;

  /// Finite upper display bound, greater than min.
  final double max;

  /// Engineering unit, shown separately from the value.
  final String unit;

  /// Optional descriptive label and semantic name.
  final String label;

  /// Finite-value formatter; does not alter the visual position.
  final InstrumentFormatter? formatter;

  /// Optional target in engineering units; must be finite.
  final double? target;

  /// Optional explicitly colored operating bands.
  final List<InstrumentBand> bands;

  /// Focused local visual style.
  final GaugeStyle style;

  /// Orientation where meaningful; radial/vessel silhouettes stay upright.
  final Axis orientation;

  /// Optional logical width. Unbounded parents default to 240.
  final double? width;

  /// Optional plot height, excluding labels and value text.
  final double? height;

  /// Enables value transitions; reduced motion always takes precedence.
  final bool animate;
  @override
  Widget build(BuildContext context) => InstrumentBody(
    shape: Shape.segments,
    style: style,
    value: value,
    min: min,
    max: max,
    unit: unit,
    label: label,
    formatter: formatter,
    target: target,
    bands: List.unmodifiable(bands),
    axis: orientation,
    width: width,
    height: height,
    animate: animate,
  );
}

/// Standalone Thermometer with transparent surroundings and controlled engineering values.
/// Missing/nonfinite values omit the indicator. Out-of-range positions clamp,
/// while the original reading stays visible. Unbounded width defaults to 240.
class Thermometer extends StatelessWidget {
  /// Creates an instrument; no controller or app-wide theme is required.
  const Thermometer({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '',
    this.label = '',
    this.formatter,
    this.style = const GaugeStyle(),
    this.width,
    this.height,
    this.animate = false,
  });

  /// Actual engineering reading; null/NaN/infinity means missing.
  final double? value;

  /// Finite lower display bound.
  final double min;

  /// Finite upper display bound, greater than min.
  final double max;

  /// Engineering unit, shown separately from the value.
  final String unit;

  /// Optional descriptive label and semantic name.
  final String label;

  /// Finite-value formatter; does not alter the visual position.
  final InstrumentFormatter? formatter;

  /// Focused local visual style.
  final GaugeStyle style;

  /// Optional logical width. Unbounded parents default to 240.
  final double? width;

  /// Optional plot height, excluding labels and value text.
  final double? height;

  /// Enables value transitions; reduced motion always takes precedence.
  final bool animate;
  @override
  Widget build(BuildContext context) => InstrumentBody(
    shape: Shape.thermometer,
    style: style,
    value: value,
    min: min,
    max: max,
    unit: unit,
    label: label,
    formatter: formatter,
    width: width,
    height: height,
    animate: animate,
  );
}
