import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'common.dart';
import 'models.dart';
import 'theme.dart';

/// Tank geometry, labeling and motion settings.
@immutable
class TankStyle {
  /// Creates tank settings. Liquid motion is off by default.
  const TankStyle({
    this.orientation = Axis.vertical,
    this.showPercentage = true,
    this.animateLiquid = false,
    this.motion = const IndustrialMotion(),
  });

  /// Fill direction: bottom-up or left-right.
  final Axis orientation;

  /// Show normalized percentage instead of engineering units.
  final bool showPercentage;

  /// Enables a subtle surface ripple while valid, fresh and connected.
  final bool animateLiquid;

  /// Level transition settings.
  final IndustrialMotion motion;
}

/// Controlled liquid-level instrument. Missing values leave an empty outline.
class IndustrialTank extends StatefulWidget {
  /// Creates a tank with immutable bands. A target must be finite.
  IndustrialTank({
    super.key,
    required this.reading,
    required this.range,
    required this.label,
    this.unit = '',
    this.formatter,
    this.target,
    List<IndustrialBand> bands = const [],
    this.style = const TankStyle(),
    this.theme,
  }) : bands = List.unmodifiable(bands) {
    if (target != null && !target!.isFinite) {
      throw ArgumentError('Target must be finite.');
    }
  }

  /// Current measurement.
  final IndustrialReading reading;

  /// Engineering range mapped onto the vessel.
  final IndustrialRange range;

  /// Vessel name.
  final String label;

  /// Unit used when percentage mode is disabled.
  final String unit;

  /// Formats percentage or engineering value according to style.
  final ValueFormatter? formatter;

  /// Target level in engineering units.
  final double? target;

  /// Low, normal and high bands shown along the vessel edge.
  final List<IndustrialBand> bands;

  /// Orientation, labels and animation.
  final TankStyle style;

  /// Local token override.
  final IndustrialTheme? theme;
  @override
  State<IndustrialTank> createState() => _IndustrialTankState();
}

class _IndustrialTankState extends State<IndustrialTank>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );
  void _sync() {
    final active =
        widget.style.animateLiquid &&
        !MediaQuery.disableAnimationsOf(context) &&
        widget.reading.hasValue &&
        widget.reading.freshness == ReadingFreshness.fresh &&
        widget.reading.connection == ConnectionStatus.connected &&
        widget.reading.quality != MeasurementQuality.bad;
    if (active && !_wave.isAnimating) _wave.repeat();
    if (!active) {
      _wave.stop();
      _wave.value = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(IndustrialTank oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget, t = w.theme ?? IndustrialTheme.of(context);
    final displayed = w.reading.hasValue
        ? (w.style.showPercentage
              ? (w.reading.value! - w.range.min) /
                    (w.range.max - w.range.min) *
                    100
              : w.reading.value!)
        : null;
    final value = displayed == null
        ? '—'
        : w.formatter?.call(displayed) ?? displayed.toStringAsFixed(1);
    final unit = w.style.showPercentage ? '%' : w.unit;
    return Semantics(
      label: [
        '${w.label}: $value $unit',
        if (w.reading.status.isNotEmpty) w.reading.status,
        if (w.reading.hasValue && !w.range.contains(w.reading.value!))
          'Out of range',
        if (w.style.showPercentage && w.unit.isNotEmpty)
          'Engineering reading ${w.reading.format()} ${w.unit}',
        if (w.target != null) 'Target ${w.target} ${w.unit}'.trim(),
        if (w.bands.any((b) => b.label.isNotEmpty))
          'Operating bands: ${w.bands.map((b) => b.label).where((s) => s.isNotEmpty).join(', ')}',
      ].join('. '),
      child: ExcludeSemantics(
        child: InstrumentPanel(
          theme: t,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(w.label, style: t.labelStyle.copyWith(color: t.muted)),
              const SizedBox(height: 12),
              RepaintBoundary(
                child: SizedBox(
                  height: w.style.orientation == Axis.vertical ? 155 : 90,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      end: w.reading.hasValue
                          ? w.range.fraction(w.reading.value!)
                          : 0,
                    ),
                    duration: w.reading.hasValue
                        ? motionDuration(context, w.style.motion)
                        : Duration.zero,
                    curve: w.style.motion.curve,
                    builder: (context, fraction, _) => CustomPaint(
                      painter: _TankPainter(
                        fraction,
                        w.reading.hasValue,
                        w.range,
                        w.target,
                        w.bands,
                        w.style.orientation,
                        t,
                        _wave,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$value $unit',
                style: t.valueStyle.copyWith(color: t.foreground),
              ),
              ReadingStatus(reading: w.reading, theme: t, range: w.range),
            ],
          ),
        ),
      ),
    );
  }
}

class _TankPainter extends CustomPainter {
  _TankPainter(
    this.fraction,
    this.present,
    this.range,
    this.target,
    this.bands,
    this.axis,
    this.theme,
    this.wave,
  ) : super(repaint: wave);
  final double fraction;
  final bool present;
  final IndustrialRange range;
  final double? target;
  final List<IndustrialBand> bands;
  final Axis axis;
  final IndustrialTheme theme;
  final Animation<double> wave;
  @override
  void paint(Canvas canvas, Size size) {
    final width = axis == Axis.vertical
        ? math.min(size.width * .7, 150.0)
        : size.width - 8;
    final rect = Rect.fromLTWH(
      (size.width - width) / 2,
      3,
      width,
      size.height - 6,
    );
    final outline = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    final paint = Paint();
    canvas.save();
    canvas.clipRRect(outline);
    canvas.drawRect(rect, paint..color = theme.border.withValues(alpha: .25));
    if (present) {
      final fill = axis == Axis.vertical
          ? Rect.fromLTRB(
              rect.left,
              rect.bottom - rect.height * fraction,
              rect.right,
              rect.bottom,
            )
          : Rect.fromLTRB(
              rect.left,
              rect.top,
              rect.left + rect.width * fraction,
              rect.bottom,
            );
      canvas.drawRect(fill, paint..color = theme.accent.withValues(alpha: .65));
      if (axis == Axis.vertical &&
          fraction > 0 &&
          fraction < 1 &&
          wave.value != 0) {
        final path = Path()..moveTo(rect.left, fill.top);
        for (var i = 0; i <= 30; i++) {
          final x = rect.left + rect.width * i / 30;
          path.lineTo(
            x,
            fill.top +
                math.sin(i / 30 * math.pi * 2 + wave.value * math.pi * 2) * 2.5,
          );
        }
        path
          ..lineTo(rect.right, rect.bottom)
          ..lineTo(rect.left, rect.bottom)
          ..close();
        canvas.drawPath(
          path,
          paint..color = theme.accent.withValues(alpha: .5),
        );
      }
    }
    for (final band in bands) {
      final a = range.fraction(band.range.min),
          b = range.fraction(band.range.max);
      if (b <= a) continue;
      final strip = axis == Axis.vertical
          ? Rect.fromLTRB(
              rect.left,
              rect.bottom - b * rect.height,
              rect.left + 5,
              rect.bottom - a * rect.height,
            )
          : Rect.fromLTRB(
              rect.left + a * rect.width,
              rect.bottom - 5,
              rect.left + b * rect.width,
              rect.bottom,
            );
      canvas.drawRect(strip, paint..color = band.color);
    }
    if (target != null) {
      final f = range.fraction(target!);
      paint
        ..color = theme.foreground
        ..strokeWidth = 2;
      if (axis == Axis.vertical) {
        final y = rect.bottom - f * rect.height;
        canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
      } else {
        final x = rect.left + f * rect.width;
        canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), paint);
      }
    }
    canvas.restore();
    canvas.drawRRect(
      outline,
      paint
        ..color = theme.muted
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_TankPainter old) =>
      fraction != old.fraction ||
      present != old.present ||
      range != old.range ||
      target != old.target ||
      !listEquals(bands, old.bands) ||
      axis != old.axis ||
      theme != old.theme;
}
