import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common.dart';
import 'models.dart';
import 'theme.dart';
import 'trend_controller.dart';
import 'trend_sampling.dart';

/// Horizontal reference on the shared numeric axis.
@immutable
class TrendThreshold {
  /// Requires a finite value.
  TrendThreshold({
    required this.value,
    required this.label,
    required this.color,
  }) {
    if (!value.isFinite) throw ArgumentError('Threshold must be finite.');
  }

  /// Engineering value.
  final double value;

  /// Legend label.
  final String label;

  /// Line color.
  final Color color;
}

/// Window, axes and overlays for a trend chart.
@immutable
class TrendChartStyle {
  /// Requires a positive window and plotHeight of at least 60.
  TrendChartStyle({
    this.window = const Duration(minutes: 2),
    this.bounds,
    this.plotHeight = 180,
    this.showLegend = true,
    this.valueFormatter,
    this.timestampFormatter,
    Map<String, Color> seriesColors = const {},
    List<IndustrialBand> bands = const [],
    List<TrendThreshold> thresholds = const [],
  }) : seriesColors = Map.unmodifiable(seriesColors),
       bands = List.unmodifiable(bands),
       thresholds = List.unmodifiable(thresholds) {
    if (window <= Duration.zero || !plotHeight.isFinite || plotHeight < 60) {
      throw ArgumentError('Invalid window or height.');
    }
  }

  /// Visible duration ending at endTime or newest event time.
  final Duration window;

  /// Fixed bounds; null computes visible-data bounds.
  final IndustrialRange? bounds;

  /// Height of plot, excluding legend and axes.
  final double plotHeight;

  /// Show series and units.
  final bool showLegend;

  /// Formats numeric axis and inspected values.
  final ValueFormatter? valueFormatter;

  /// Formats time; default HH:mm:ss preserves original timezone.
  final TimestampFormatter? timestampFormatter;

  /// Optional series-ID color overrides, useful when switching themes.
  final Map<String, Color> seriesColors;

  /// Shaded bands, included in automatic bounds.
  final List<IndustrialBand> bands;

  /// Threshold lines, included in automatic bounds.
  final List<TrendThreshold> thresholds;
}

/// Live chart listening to an externally owned controller.
///
/// Hover, touch drag or focused arrow keys inspect original retained samples.
/// All series share one numeric axis; units are not converted. Rendering uses
/// pixel buckets preserving extrema and gaps. Application must dispose controller.
class IndustrialTrendChart extends StatefulWidget {
  /// Creates a view, without taking ownership of controller.
  IndustrialTrendChart({
    super.key,
    required this.controller,
    this.label = 'Live trends',
    TrendChartStyle? style,
    this.endTime,
    this.theme,
  }) : style = style ?? TrendChartStyle();

  /// External ingestion model.
  final IndustrialTrendController controller;

  /// Heading and accessible name.
  final String label;

  /// Rendering configuration.
  final TrendChartStyle style;

  /// Explicit right edge; omit to follow latest event, freezing when paused.
  final DateTime? endTime;

  /// Local theme override.
  final IndustrialTheme? theme;
  @override
  State<IndustrialTrendChart> createState() => _IndustrialTrendChartState();
}

class _IndustrialTrendChartState extends State<IndustrialTrendChart> {
  double? _inspection;
  bool _focused = false;
  String _time(DateTime t) =>
      widget.style.timestampFormatter?.call(t) ??
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
  String _value(double n) =>
      widget.style.valueFormatter?.call(n) ?? n.toStringAsFixed(1);
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final w = widget, t = w.theme ?? IndustrialTheme.of(context);
      final end =
          w.endTime ?? w.controller.latestTimestamp ?? DateTime.utc(2000);
      final start = end.subtract(w.style.window);
      final data = {
        for (final s in w.controller.series)
          s.id: w.controller
              .points(s.id)
              .where(
                (p) =>
                    !p.timestamp.isBefore(start) && !p.timestamp.isAfter(end),
              )
              .toList(),
      };
      final values = [
        for (final list in data.values)
          for (final p in list)
            if (p.hasValue) p.value!,
        for (final b in w.style.bands) ...[b.range.min, b.range.max],
        for (final h in w.style.thresholds) h.value,
      ];
      final lo = values.isEmpty ? 0.0 : values.reduce(math.min),
          hi = values.isEmpty ? 1.0 : values.reduce(math.max);
      final pad = hi == lo ? math.max(1.0, lo.abs() * .05) : (hi - lo) * .08;
      final lowBound = (lo - pad).isFinite ? lo - pad : lo;
      final highBound = (hi + pad).isFinite ? hi + pad : hi;
      final extremeSpan = !(highBound - lowBound).isFinite;
      final bounds =
          w.style.bounds ??
          IndustrialRange(
            extremeSpan ? -double.maxFinite / 2 : lowBound,
            extremeSpan ? double.maxFinite / 2 : highBound,
          );
      final selected = _inspection == null
          ? null
          : start.add(
              Duration(
                microseconds: (w.style.window.inMicroseconds * _inspection!)
                    .round(),
              ),
            );
      final inspected = <String>[];
      if (selected != null) {
        for (final s in w.controller.series) {
          final list = data[s.id]!;
          if (list.isEmpty) {
            inspected.add('${s.name}: —');
            continue;
          }
          final p = list.reduce(
            (a, b) =>
                a.timestamp.difference(selected).abs() <=
                    b.timestamp.difference(selected).abs()
                ? a
                : b,
          );
          inspected.add(
            '${s.name}: ${p.hasValue ? _value(p.value!) : '—'} ${s.unit} @ ${_time(p.timestamp)}',
          );
        }
      }
      return InstrumentPanel(
        theme: t,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(w.label, style: t.labelStyle),
            const SizedBox(height: 12),
            if (w.style.showLegend)
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  for (final s in w.controller.series)
                    Text(
                      '● ${s.name} (${s.unit})',
                      style: TextStyle(
                        color: w.style.seriesColors[s.id] ?? s.color,
                      ),
                    ),
                  for (final h in w.style.thresholds)
                    Text(
                      '— ${h.label}: ${_value(h.value)}',
                      style: TextStyle(color: h.color),
                    ),
                  for (final b in w.style.bands)
                    if (b.label.isNotEmpty)
                      Text(b.label, style: TextStyle(color: t.muted)),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              _value(bounds.max),
              style: TextStyle(color: t.muted, fontSize: 11),
            ),
            Focus(
              onFocusChange: (v) => setState(() => _focused = v),
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent || event is KeyRepeatEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                      event.logicalKey == LogicalKeyboardKey.arrowRight) {
                    setState(
                      () => _inspection =
                          ((_inspection ?? .5) +
                                  (event.logicalKey ==
                                          LogicalKeyboardKey.arrowRight
                                      ? .02
                                      : -.02))
                              .clamp(0.0, 1.0),
                    );
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.escape) {
                    setState(() => _inspection = null);
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: Semantics(
                label:
                    '${w.label}. ${data.values.expand((p) => p).any((p) => p.hasValue) ? '' : 'No data.'} '
                    '${w.controller.series.map((s) => '${s.name}, ${s.unit}').join('; ')}. Use arrow keys to inspect. ${inspected.join('; ')}',
                child: LayoutBuilder(
                  builder: (context, c) {
                    void inspect(Offset p) => setState(
                      () => _inspection = (p.dx / c.maxWidth).clamp(0.0, 1.0),
                    );
                    return MouseRegion(
                      onHover: (e) => inspect(e.localPosition),
                      onExit: (_) {
                        if (!_focused) setState(() => _inspection = null);
                      },
                      child: GestureDetector(
                        onTapDown: (e) => inspect(e.localPosition),
                        onHorizontalDragUpdate: (e) => inspect(e.localPosition),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: _focused
                                ? Border.all(color: t.accent)
                                : null,
                          ),
                          child: RepaintBoundary(
                            child: CustomPaint(
                              size: Size(c.maxWidth, w.style.plotHeight),
                              painter: _TrendPainter(
                                {
                                  for (final entry in data.entries)
                                    entry.key: sampleTrend(
                                      entry.value,
                                      math.max(1, c.maxWidth.floor()),
                                      (p) =>
                                          p.timestamp
                                              .difference(start)
                                              .inMicroseconds /
                                          w.style.window.inMicroseconds *
                                          c.maxWidth,
                                    ),
                                },
                                w.controller.series,
                                start,
                                end,
                                bounds,
                                w.style,
                                t,
                                _inspection,
                              ),
                              child: SizedBox(
                                height: w.style.plotHeight,
                                child:
                                    data.values
                                        .expand((e) => e)
                                        .any((p) => p.hasValue)
                                    ? null
                                    : Center(
                                        child: Text(
                                          'No data',
                                          style: TextStyle(color: t.muted),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Text(
              _value(bounds.min),
              style: TextStyle(color: t.muted, fontSize: 11),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    _time(start),
                    style: TextStyle(color: t.muted, fontSize: 11),
                  ),
                ),
                Flexible(
                  child: Text(
                    _time(end),
                    style: TextStyle(color: t.muted, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              selected == null
                  ? 'Inspect: hover, drag, or focus and use ← →'
                  : inspected.join('  ·  '),
              style: TextStyle(color: t.muted, fontSize: 12),
            ),
          ],
        ),
      );
    },
  );
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(
    this.data,
    this.series,
    this.start,
    this.end,
    this.bounds,
    this.style,
    this.theme,
    this.inspection,
  );
  final Map<String, List<TrendPoint>> data;
  final List<TrendSeries> series;
  final DateTime start, end;
  final IndustrialRange bounds;
  final TrendChartStyle style;
  final IndustrialTheme theme;
  final double? inspection;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 1;
    double y(double v) =>
        size.height *
        (1 -
                (v / (bounds.max - bounds.min) -
                    bounds.min / (bounds.max - bounds.min)))
            .clamp(-2.0, 3.0);
    double x(TrendPoint p) =>
        p.timestamp.difference(start).inMicroseconds /
        end.difference(start).inMicroseconds *
        size.width;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (final b in style.bands) {
      canvas.drawRect(
        Rect.fromLTRB(0, y(b.range.max), size.width, y(b.range.min)),
        paint..color = b.color.withValues(alpha: .12),
      );
    }
    for (var i = 0; i <= 4; i++) {
      canvas.drawLine(
        Offset(0, size.height * i / 4),
        Offset(size.width, size.height * i / 4),
        paint..color = theme.border,
      );
    }
    for (final h in style.thresholds) {
      if (bounds.contains(h.value)) {
        canvas.drawLine(
          Offset(0, y(h.value)),
          Offset(size.width, y(h.value)),
          paint..color = h.color,
        );
      }
    }
    for (final s in series) {
      final sampled = data[s.id]!;
      final path = Path();
      bool drawing = false;
      TrendPoint? previous;
      var runLength = 0;
      paint
        ..color = style.seriesColors[s.id] ?? s.color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      void dot() {
        if (runLength == 1 && previous != null) {
          canvas.drawCircle(
            Offset(x(previous), y(previous.value!)),
            3,
            Paint()..color = style.seriesColors[s.id] ?? s.color,
          );
        }
      }

      for (final p in sampled) {
        if (!p.hasValue) {
          dot();
          drawing = false;
          runLength = 0;
          previous = null;
          continue;
        }
        final pt = Offset(x(p), y(p.value!));
        if (drawing) {
          path.lineTo(pt.dx, pt.dy);
        } else {
          path.moveTo(pt.dx, pt.dy);
        }
        drawing = true;
        previous = p;
        runLength++;
      }
      dot();
      canvas.drawPath(path, paint);
    }
    if (inspection != null) {
      canvas.drawLine(
        Offset(size.width * inspection!, 0),
        Offset(size.width * inspection!, size.height),
        paint
          ..color = theme.foreground
          ..strokeWidth = 1,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      data != old.data ||
      start != old.start ||
      end != old.end ||
      bounds != old.bounds ||
      style != old.style ||
      theme != old.theme ||
      inspection != old.inspection;
}
