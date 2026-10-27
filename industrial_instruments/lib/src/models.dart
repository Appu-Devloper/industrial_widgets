import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Physical construction of an instrument; behavior is unchanged.
enum InstrumentAppearance {
  /// Open, flat marks and simple geometry.
  precision,

  /// Recessed dials, casing, collars and restrained physical depth.
  instrument,
}

/// Observed operating state supplied by the application.
enum EquipmentState {
  /// Operating normally.
  running,

  /// Confirmed stopped.
  stopped,

  /// Observed fault; shown with a cross as well as text.
  fault,

  /// Observation is unavailable; never inferred as stopped.
  unknown,
}

/// Observed valve position, independent of user intent.
enum ValvePosition {
  /// Confirmed open.
  open,

  /// Confirmed closed.
  closed,

  /// Partially open; optional opening percentage may be supplied.
  intermediate,

  /// No confirmed observation.
  unknown,
}

/// Physical motion direction.
enum FlowDirection {
  /// Left to right or clockwise.
  forward,

  /// Right to left or counter-clockwise.
  reverse,
}

/// Number formatter. Invoked only with finite engineering values.
typedef InstrumentFormatter = String Function(double value);

/// User-configured operating range, clipped to the visible instrument scale.
@immutable
class InstrumentBand {
  /// Creates an ordered, finite range.
  InstrumentBand(this.min, this.max, this.color, {this.label = ''}) {
    validateRange(min, max);
  }

  /// Lower engineering value.
  final double min;

  /// Upper engineering value.
  final double max;

  /// Explicit range color; not assigned automatically by the library.
  final Color color;

  /// Accessible description.
  final String label;
}

/// Validates a finite, positive display span. Throws rather than hiding mistakes.
void validateRange(double min, double max) {
  if (!min.isFinite || !max.isFinite || min >= max || !(max - min).isFinite) {
    throw ArgumentError('Range requires finite min < max and a finite span.');
  }
}

/// Maps a valid value into a clipped visual fraction. Missing remains null.
double? instrumentFraction(double? value, double min, double max) {
  validateRange(min, max);
  if (value == null || !value.isFinite) return null;
  return ((value - min) / (max - min)).clamp(0.0, 1.0);
}

/// Explicit interpretation of a pressure reading.
enum PressureConvention {
  /// Relative to atmospheric pressure; values may be negative.
  gauge,

  /// Relative to a perfect vacuum; configured minimum cannot be negative.
  absolute,
}

/// Observed battery activity, independent of animation.
enum BatteryActivity {
  /// No charging or discharging reported.
  idle,

  /// Application reports charging.
  charging,

  /// Application reports discharging.
  discharging,

  /// Activity is unavailable.
  unknown,
}

/// Meaning of a vessel's displayed reading.
enum LevelQuantity {
  /// Normalized liquid height; no volume conversion is implied.
  height,

  /// Volume supplied by the application; an explicit height fraction is required.
  volume,
}

/// Optional secondary dial labels. Values are supplied, never converted.
@immutable
class SecondaryScale {
  /// Defines a linear secondary scale aligned with the primary endpoints.
  SecondaryScale({
    required this.min,
    required this.max,
    required this.unit,
    this.formatter,
  }) {
    validateRange(min, max);
  }

  /// Secondary lower endpoint.
  final double min;

  /// Secondary upper endpoint.
  final double max;

  /// Explicit secondary unit.
  final String unit;

  /// Optional label formatter.
  final InstrumentFormatter? formatter;
}
