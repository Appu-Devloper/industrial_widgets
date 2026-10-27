import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'common.dart';
import 'models.dart';
import 'theme.dart';

/// Visual representation of a radial measurement.
enum GaugePresentation {
  /// Rotating needle over operating bands.
  needle,

  /// Filled arc over operating bands.
  arc,
}

/// Geometry and transition settings for a gauge.
@immutable
class GaugeStyle {
  /// Creates gauge settings. Tick counts are validated when rendered.
  const GaugeStyle({
    this.presentation = GaugePresentation.needle,
    this.majorTicks = 5,
    this.minorTicks = 4,
    this.motion = const IndustrialMotion(),
  });

  /// Needle or arc display.
  final GaugePresentation presentation;

  /// Number of major intervals (1–20); both endpoints receive ticks.
  final int majorTicks;

  /// Minor marks between major ticks (0–10).
  final int minorTicks;

  /// Transition settings.
  final IndustrialMotion motion;
}

/// Controlled radial instrument; labels retain unclamped engineering values.
class IndustrialGauge extends StatelessWidget {
  /// Creates a gauge. Target must be finite when supplied.
  IndustrialGauge({
    super.key,
    required this.reading,
    required this.range,
    required this.label,
    this.unit = '',
    this.formatter,
    this.target,
    List<IndustrialBand> bands = const [],
    this.style = const GaugeStyle(),
    this.theme,
  }) : bands = List.unmodifiable(bands) {
    if (target != null && !target!.isFinite) {
      throw ArgumentError('Target must be finite.');
    }
    if (style.majorTicks < 1 ||
        style.majorTicks > 20 ||
        style.minorTicks < 0 ||
        style.minorTicks > 10) {
      throw ArgumentError('majorTicks must be 1–20 and minorTicks 0–10.');
    }
  }

  /// Current measurement.
  final IndustrialReading reading;

  /// Visual engineering bounds.
  final IndustrialRange range;

  /// Instrument name.
  final String label;

  /// Engineering unit.
  final String unit;

  /// Actual value formatter.
  final ValueFormatter? formatter;

  /// Optional target; visual position is clamped.
  final double? target;

  /// Operating bands, clipped to range; later bands paint over earlier ones.
  final List<IndustrialBand> bands;

  /// Geometry and transition configuration.
  final GaugeStyle style;

  /// Local design tokens.
  final IndustrialTheme? theme;
  @override
  Widget build(BuildContext context) {
    final t = theme ?? IndustrialTheme.of(context);
    return Semantics(
      label:
          '${readingSemantics(label, reading, unit, formatter, range)}'
          '${target == null ? '' : '. Target $target $unit'}'
          '${bands.isEmpty ? '' : '. Operating bands: ${bands.map((b) => b.label).where((s) => s.isNotEmpty).join(', ')}'}',
      child: ExcludeSemantics(
        child: InstrumentPanel(
          theme: t,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label, style: t.labelStyle.copyWith(color: t.muted)),
              RepaintBoundary(
                child: AspectRatio(
                  aspectRatio: 1.65,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      end: reading.hasValue
                          ? range.fraction(reading.value!)
                          : 0,
                    ),
                    duration: reading.hasValue
                        ? motionDuration(context, style.motion)
                        : Duration.zero,
                    curve: style.motion.curve,
                    builder: (context, fraction, child) => CustomPaint(
                      painter: _GaugePainter(
                        fraction,
                        reading.hasValue,
                        range,
                        target,
                        bands,
                        style,
                        t,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                '${reading.format(formatter)} $unit',
                textAlign: TextAlign.center,
                style: t.valueStyle.copyWith(color: t.foreground),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      range.min.toStringAsFixed(0),
                      style: TextStyle(color: t.muted),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      range.max.toStringAsFixed(0),
                      style: TextStyle(color: t.muted),
                    ),
                  ),
                ],
              ),
              ReadingStatus(reading: reading, theme: t, range: range),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(
    this.fraction,
    this.present,
    this.range,
    this.target,
    this.bands,
    this.style,
    this.theme,
  );
  final double fraction;
  final bool present;
  final IndustrialRange range;
  final double? target;
  final List<IndustrialBand> bands;
  final GaugeStyle style;
  final IndustrialTheme theme;
  static const start = math.pi * .85;
  static const sweep = math.pi * 1.3;
  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width / 2.15, size.height / 1.65);
    final center = Offset(size.width / 2, size.height * .72);
    final rect = Rect.fromCircle(center: center, radius: r);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep, false, paint..color = theme.border);
    for (final band in bands) {
      final a = range.fraction(band.range.min),
          b = range.fraction(band.range.max);
      if (b > a) {
        canvas.drawArc(
          rect,
          start + a * sweep,
          (b - a) * sweep,
          false,
          paint..color = band.color,
        );
      }
    }
    Offset point(double f, double radius) =>
        center +
        Offset(math.cos(start + f * sweep), math.sin(start + f * sweep)) *
            radius;
    paint
      ..strokeWidth = 1
      ..color = theme.muted;
    final ticks = style.majorTicks * (style.minorTicks + 1);
    for (var i = 0; i <= ticks; i++) {
      final major = i % (style.minorTicks + 1) == 0;
      canvas.drawLine(
        point(i / ticks, r * .82),
        point(i / ticks, r * (major ? .68 : .76)),
        paint,
      );
    }
    if (target != null) {
      paint
        ..color = theme.foreground
        ..strokeWidth = 3;
      canvas.drawLine(
        point(range.fraction(target!), r * .89),
        point(range.fraction(target!), r * 1.12),
        paint,
      );
    }
    if (!present) return;
    paint
      ..color = theme.accent
      ..strokeWidth = 3;
    if (style.presentation == GaugePresentation.needle) {
      canvas.drawLine(center, point(fraction, r * .66), paint);
      canvas.drawCircle(center, 5, paint..style = PaintingStyle.fill);
    } else {
      paint.strokeWidth = r * .10;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r * .55),
        start,
        fraction * sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      fraction != old.fraction ||
      present != old.present ||
      range != old.range ||
      target != old.target ||
      !listEquals(bands, old.bands) ||
      style != old.style ||
      theme != old.theme;
}
