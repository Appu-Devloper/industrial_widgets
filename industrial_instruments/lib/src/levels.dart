import 'package:flutter/material.dart';
import 'models.dart';
import 'styles.dart';
import 'rendering.dart';

/// Standalone LiquidTank with transparent surroundings and controlled engineering values.
/// Missing/nonfinite values omit the indicator. Out-of-range positions clamp,
/// while the original reading stays visible. Unbounded width defaults to 240.
class LiquidTank extends StatelessWidget {
  /// Creates an instrument; no controller or app-wide theme is required.
  const LiquidTank({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '',
    this.label = '',
    this.formatter,
    this.target,
    this.style = const LevelStyle(),
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

  /// Focused local visual style.
  final LevelStyle style;

  /// Optional logical width. Unbounded parents default to 240.
  final double? width;

  /// Optional plot height, excluding labels and value text.
  final double? height;

  /// Enables value transitions; reduced motion always takes precedence.
  final bool animate;
  @override
  Widget build(BuildContext context) => InstrumentBody(
    shape: Shape.liquid,
    style: style,
    value: value,
    min: min,
    max: max,
    unit: unit,
    label: label,
    formatter: formatter,
    target: target,
    width: width,
    height: height,
    animate: animate,
  );
}

/// Standalone CylindricalTank with transparent surroundings and controlled engineering values.
/// Missing/nonfinite values omit the indicator. Out-of-range positions clamp,
/// while the original reading stays visible. Unbounded width defaults to 240.
class CylindricalTank extends StatelessWidget {
  /// Creates an instrument; no controller or app-wide theme is required.
  const CylindricalTank({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '',
    this.label = '',
    this.formatter,
    this.target,
    this.style = const LevelStyle(),
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

  /// Focused local visual style.
  final LevelStyle style;

  /// Optional logical width. Unbounded parents default to 240.
  final double? width;

  /// Optional plot height, excluding labels and value text.
  final double? height;

  /// Enables value transitions; reduced motion always takes precedence.
  final bool animate;
  @override
  Widget build(BuildContext context) => InstrumentBody(
    shape: Shape.cylinder,
    style: style,
    value: value,
    min: min,
    max: max,
    unit: unit,
    label: label,
    formatter: formatter,
    target: target,
    width: width,
    height: height,
    animate: animate,
  );
}

/// Standalone SiloIndicator with transparent surroundings and controlled engineering values.
/// Missing/nonfinite values omit the indicator. Out-of-range positions clamp,
/// while the original reading stays visible. Unbounded width defaults to 240.
class SiloIndicator extends StatelessWidget {
  /// Creates an instrument; no controller or app-wide theme is required.
  const SiloIndicator({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '',
    this.label = '',
    this.formatter,
    this.target,
    this.style = const LevelStyle(),
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

  /// Focused local visual style.
  final LevelStyle style;

  /// Optional logical width. Unbounded parents default to 240.
  final double? width;

  /// Optional plot height, excluding labels and value text.
  final double? height;

  /// Enables value transitions; reduced motion always takes precedence.
  final bool animate;
  @override
  Widget build(BuildContext context) => InstrumentBody(
    shape: Shape.silo,
    style: style,
    value: value,
    min: min,
    max: max,
    unit: unit,
    label: label,
    formatter: formatter,
    target: target,
    width: width,
    height: height,
    animate: animate,
  );
}

/// Standalone BatteryIndicator with transparent surroundings and controlled engineering values.
/// Missing/nonfinite values omit the indicator. Out-of-range positions clamp,
/// while the original reading stays visible. Unbounded width defaults to 240.
class BatteryIndicator extends StatelessWidget {
  /// Creates an instrument; no controller or app-wide theme is required.
  const BatteryIndicator({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '',
    this.label = '',
    this.formatter,
    this.style = const LevelStyle(),
    this.orientation = Axis.horizontal,
    this.width,
    this.height,
    this.animate = false,
    this.activity = BatteryActivity.idle,
    this.showValue = true,
  });

  /// Observed activity; charging is independent of the animation setting.
  final BatteryActivity activity;

  /// Whether to display the actual numeric charge reading.
  final bool showValue;

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
  final LevelStyle style;

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
    shape: Shape.battery,
    style: style,
    value: value,
    min: min,
    max: max,
    unit: unit,
    label: label,
    formatter: formatter,
    axis: orientation,
    width: width,
    height: height,
    animate: animate,
    state: activity == BatteryActivity.charging
        ? EquipmentState.running
        : EquipmentState.stopped,
    showValue: showValue,
    caption: activity.name,
  );
}
