import 'package:flutter/material.dart';
import 'styles.dart';
import 'models.dart';
import 'rendering.dart';

/// Tabular numerical display with an optional native seven-segment face.
class DigitalReadout extends StatelessWidget {
  /// Missing and non-finite readings display an em dash, never zero.
  const DigitalReadout({
    super.key,
    required this.value,
    this.unit = '',
    this.label,
    this.precision = 1,
    this.formatter,
    this.presentation = ReadoutPresentation.standard,
    this.style = const InstrumentStyle(),
    this.width,
  });

  /// Actual reading, without clamping.
  final double? value;

  /// Engineering unit shown separately from the digits.
  final String unit;

  /// Optional descriptive label.
  final String? label;

  /// Optional finite-value formatter, without changing the underlying reading.
  final InstrumentFormatter? formatter;

  /// Decimal places, from zero through six.
  final int precision;

  /// Standard typography or seven-segment geometry.
  final ReadoutPresentation presentation;

  /// Local colors, typography and appearance.
  final InstrumentStyle style;

  /// Defaults to available width, or 240 when unconstrained.
  final double? width;
  @override
  Widget build(BuildContext context) {
    if (precision < 0 || precision > 6) {
      throw ArgumentError('precision must be 0–6');
    }
    if (width != null && (!width!.isFinite || width! <= 0)) {
      throw ArgumentError('width must be finite and positive');
    }
    final ink = InkSet(context, style);
    final reading = value != null && value!.isFinite
        ? (formatter?.call(value!) ?? value!.toStringAsFixed(precision))
        : '—';
    return Semantics(
      label:
          '${label ?? 'Reading'}: ${reading == '—' ? 'No reading' : '$reading $unit'}',
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, c) {
            final w = width ?? (c.hasBoundedWidth ? c.maxWidth : 240.0);
            final segments =
                presentation == ReadoutPresentation.sevenSegment &&
                reading.length * 29 < w - 24 &&
                MediaQuery.textScalerOf(context).scale(1) <= 1.3 &&
                RegExp(r'^-?[0-9]+(\.[0-9]+)?$|^—$').hasMatch(reading);
            return SizedBox(
              width: w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (label != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(label!, style: ink.label),
                    ),
                  Container(
                    padding: ink.physical
                        ? const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          )
                        : EdgeInsets.zero,
                    decoration: ink.physical
                        ? BoxDecoration(
                            color: ink.material,
                            border: Border.all(color: ink.track),
                            boxShadow: [
                              BoxShadow(
                                color: ink.track,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          )
                        : null,
                    child: segments
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 46,
                                width:
                                    reading.length * 29 -
                                    (reading.contains('.') ? 20 : 0),
                                child: CustomPaint(
                                  painter: _Digits(
                                    reading,
                                    ink.accent,
                                    ink.track,
                                  ),
                                ),
                              ),
                              if (unit.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(unit, style: ink.label),
                                ),
                            ],
                          )
                        : Text.rich(
                            TextSpan(
                              text: reading,
                              children: [
                                TextSpan(
                                  text: ' $unit',
                                  style: ink.label.copyWith(fontSize: 16),
                                ),
                              ],
                            ),
                            style: ink.value.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Digits extends CustomPainter {
  _Digits(this.text, this.color, this.track);
  final String text;
  final Color color, track;
  static const masks = [
    0x3f,
    0x06,
    0x5b,
    0x4f,
    0x66,
    0x6d,
    0x7d,
    0x07,
    0x7f,
    0x6f,
  ];
  @override
  void paint(Canvas c, Size s) {
    const lines = [
      [5.0, 2.0, 20.0, 2.0],
      [23.0, 5.0, 23.0, 20.0],
      [23.0, 26.0, 23.0, 41.0],
      [5.0, 44.0, 20.0, 44.0],
      [2.0, 26.0, 2.0, 41.0],
      [2.0, 5.0, 2.0, 20.0],
      [5.0, 23.0, 20.0, 23.0],
    ];
    double x = 0;
    for (var i = 0; i < text.length; i++) {
      final ch = text[i],
          digit = int.tryParse(ch),
          mask = digit == null
              ? (ch == '-' || ch == '—' ? 0x40 : 0)
              : masks[digit];
      if (ch == '.') {
        c.drawCircle(Offset(x + 2, 43), 2, Paint()..color = color);
        x += 9;
        continue;
      }
      for (var j = 0; j < 7; j++) {
        final l = lines[j];
        c.drawLine(
          Offset(x + l[0], l[1]),
          Offset(x + l[2], l[3]),
          Paint()
            ..color = (mask & (1 << j)) != 0
                ? color
                : track.withValues(alpha: .3)
            ..strokeWidth = 2.4
            ..strokeCap = StrokeCap.square,
        );
      }
      x += 29;
    }
  }

  @override
  bool shouldRepaint(_Digits old) =>
      old.text != text || old.color != color || old.track != track;
}

/// Compact observed-state lamp; state is also conveyed through readable text.
class StateLight extends StatelessWidget {
  /// Null means unknown; this widget does not send control commands.
  const StateLight({
    super.key,
    required this.active,
    this.label,
    this.style = const InstrumentStyle(),
    this.size = 18,
  });

  /// True on, false off, null unknown.
  final bool? active;

  /// Optional name preceding the state text.
  final String? label;

  /// Local accent and physical bezel appearance.
  final InstrumentStyle style;

  /// Lamp diameter, at least 12 logical pixels.
  final double size;
  @override
  Widget build(BuildContext context) {
    if (!size.isFinite || size < 12) {
      throw ArgumentError('size must be at least 12');
    }
    final ink = InkSet(context, style),
        state = active == null
            ? 'Unknown'
            : active!
            ? 'On'
            : 'Off';
    return Semantics(
      label: '${label ?? 'Indicator'}: $state',
      child: ExcludeSemantics(
        child: Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox.square(
              dimension: size,
              child: CustomPaint(painter: _Lamp(active, ink)),
            ),
            Text('${label == null ? '' : '$label · '}$state', style: ink.label),
          ],
        ),
      ),
    );
  }
}

class _Lamp extends CustomPainter {
  _Lamp(this.active, this.ink);
  final bool? active;
  final InkSet ink;
  @override
  void paint(Canvas c, Size s) {
    final center = s.center(Offset.zero), r = s.shortestSide / 2 - 1;
    c.drawCircle(
      center,
      r,
      Paint()
        ..color = ink.track
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    c.drawCircle(
      center,
      r * (ink.physical ? .68 : .55),
      Paint()..color = active == true ? ink.accent : ink.material,
    );
    if (ink.physical && active == true) {
      c.drawArc(
        Rect.fromCircle(center: center, radius: r * .45),
        3.7,
        1.2,
        false,
        Paint()
          ..color = ink.foreground.withValues(alpha: .5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
    if (active != true) {
      c.drawLine(
        center + Offset(-r * .35, 0),
        center + Offset(r * .35, 0),
        Paint()
          ..color = ink.muted
          ..strokeWidth = active == null ? 1 : 2,
      );
    }
  }

  @override
  bool shouldRepaint(_Lamp old) =>
      old.active != active ||
      old.ink.style != ink.style ||
      old.ink.foreground != ink.foreground;
}

/// Three application-supplied phase readings with stable column alignment.
class ThreePhaseReadout extends StatelessWidget {
  /// Exactly three values and nonempty labels are required. No phase math occurs.
  ThreePhaseReadout({
    super.key,
    required List<double?> values,
    List<String> labels = const ['L1', 'L2', 'L3'],
    this.unit = 'V',
    this.precision = 1,
    this.formatter,
    this.style = const InstrumentStyle(),
    this.width,
  }) : values = List.unmodifiable(values),
       labels = List.unmodifiable(labels) {
    if (values.length != 3 ||
        labels.length != 3 ||
        labels.any((s) => s.trim().isEmpty)) {
      throw ArgumentError(
        'Provide three values and three nonempty phase labels.',
      );
    }
    if (precision < 0 || precision > 6) {
      throw ArgumentError('precision must be 0–6');
    }
    if (width != null && (!width!.isFinite || width! < 180)) {
      throw ArgumentError('width must be at least 180');
    }
  }

  /// Readings in the supplied unit; missing phases remain individually missing.
  final List<double?> values;

  /// Phase labels such as L1/L2/L3 or R/Y/B, without implied phase colors.
  final List<String> labels;

  /// Shared engineering unit; no conversion is performed.
  final String unit;

  /// Optional formatter for each finite phase reading.
  final InstrumentFormatter? formatter;

  /// Decimal places, zero through six.
  final int precision;

  /// Local typography and colors.
  final InstrumentStyle style;

  /// Defaults to bounded width, or 320 when unbounded. Minimum supported 180.
  final double? width;
  @override
  Widget build(BuildContext context) {
    final ink = InkSet(context, style);
    return LayoutBuilder(
      builder: (context, c) {
        final w = width ?? (c.hasBoundedWidth ? c.maxWidth : 320.0);
        final stacked =
            w < 260 || MediaQuery.textScalerOf(context).scale(1) > 1.3;
        return SizedBox(
          width: w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++)
                Builder(
                  builder: (context) {
                    final valid = values[i]?.isFinite ?? false;
                    final reading = valid
                        ? (formatter?.call(values[i]!) ??
                              values[i]!.toStringAsFixed(precision))
                        : '—';
                    final number = Text.rich(
                      TextSpan(
                        text: reading,
                        children: [
                          TextSpan(
                            text: ' $unit',
                            style: ink.label.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                      style: ink.value,
                      textAlign: TextAlign.right,
                    );
                    return Semantics(
                      label:
                          '${labels[i]}: ${valid ? '$reading $unit' : 'No reading'}',
                      child: ExcludeSemantics(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (stacked) ...[
                                Text(labels[i], style: ink.label),
                                number,
                              ] else
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Text(labels[i], style: ink.label),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(flex: 4, child: number),
                                  ],
                                ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 1,
                                child: ColoredBox(color: ink.track),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
