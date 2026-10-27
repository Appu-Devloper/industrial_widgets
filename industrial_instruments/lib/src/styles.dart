import 'package:flutter/material.dart';
import 'models.dart';

/// Shared visual primitives, supplied locally rather than forcing a host theme.
@immutable
class InstrumentStyle {
  /// Creates transparent instrument styling. Stroke and duration are validated.
  const InstrumentStyle({
    this.appearance = InstrumentAppearance.precision,
    this.accent,
    this.foreground,
    this.muted,
    this.surface,
    this.strokeWidth = 1.5,
    this.valueStyle,
    this.labelStyle,
    this.duration = const Duration(milliseconds: 300),
  });

  /// Flat or physically constructed geometry.
  final InstrumentAppearance appearance;

  /// Single measurement/operating accent; defaults to teal adapted to brightness.
  final Color? accent;

  /// Essential marks and primary text.
  final Color? foreground;

  /// Supporting text and inactive geometry.
  final Color? muted;

  /// Internal instrument material, not a widget background.
  final Color? surface;

  /// Vector outline thickness in logical pixels, greater than zero.
  final double strokeWidth;

  /// Optional main numeric text style; inherits host font otherwise.
  final TextStyle? valueStyle;

  /// Optional supporting text style; inherits host font otherwise.
  final TextStyle? labelStyle;

  /// Value-transition time. Zero disables transitions.
  final Duration duration;
}

/// Dial, arc, linear and segmented scale settings.
@immutable
class GaugeStyle extends InstrumentStyle {
  /// Tick density is deliberately capped for readable geometry.
  const GaugeStyle({
    super.appearance,
    super.accent,
    super.foreground,
    super.muted,
    super.surface,
    super.strokeWidth,
    super.valueStyle,
    super.labelStyle,
    super.duration,
    this.startAngle = 135,
    this.sweepAngle = 270,
    this.divisions = 5,
    this.minorTicks = 4,
    this.showLabels = true,
    this.roundCaps = true,
    this.segments = 20,
    this.scaleFormatter,
  });

  /// Clockwise starting angle in degrees, measured from the rightward axis.
  final double startAngle;

  /// Clockwise sweep in degrees, greater than zero and at most 360.
  final double sweepAngle;

  /// Major intervals, 2–10.
  final int divisions;

  /// Minor ticks between major ticks, 0–5; hidden in small dials.
  final int minorTicks;

  /// Show optional numeric tick labels when room permits.
  final bool showLabels;

  /// Rounded versus flat ends on the arc gauge.
  final bool roundCaps;

  /// Segmented meter count, 4–40.
  final int segments;

  /// Optional numeric scale formatter, independent of current-value precision.
  final InstrumentFormatter? scaleFormatter;
}

/// Vessel geometry and optional surface motion.
@immutable
class LevelStyle extends InstrumentStyle {
  /// Creates level styling; vessel width is a fraction of available plot width.
  const LevelStyle({
    super.appearance,
    super.accent,
    super.foreground,
    super.muted,
    super.surface,
    super.strokeWidth,
    super.valueStyle,
    super.labelStyle,
    super.duration,
    this.vesselWidth = .58,
    this.showMarks = true,
    this.waves = false,
  });

  /// Vessel width fraction, .3–.8; space is reserved for an external ruler.
  final double vesselWidth;

  /// Show five engineering-value marks; explicitly mapped volume uses height %.
  final bool showMarks;

  /// Subtle liquid surface movement, only when animate is also true.
  final bool waves;
}

/// Equipment silhouette and restrained operating motion.
@immutable
class EquipmentStyle extends InstrumentStyle {
  /// One rotation takes [cycle]; running state alone does not start animation.
  const EquipmentStyle({
    super.appearance,
    super.accent,
    super.foreground,
    super.muted,
    super.surface,
    super.strokeWidth,
    super.valueStyle,
    super.labelStyle,
    super.duration,
    this.cycle = const Duration(seconds: 4),
    this.showState = true,
  });

  /// Positive decorative-motion period.
  final Duration cycle;

  /// Show a concise observed-state caption below the graphic.
  final bool showState;
}

/// Numerical presentation.
enum ReadoutPresentation {
  /// Host-font numeric typography with tabular figures.
  standard,

  /// Locally painted seven-segment numerals; unsupported strings fall back.
  sevenSegment,
}
