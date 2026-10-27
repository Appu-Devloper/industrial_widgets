// Internal painting and layout infrastructure; not part of the public API.
// ignore_for_file: public_member_api_docs
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'models.dart';
import 'styles.dart';

enum Shape {
  radial,
  arc,
  linear,
  segments,
  thermometer,
  liquid,
  cylinder,
  silo,
  battery,
  pump,
  valve,
  motor,
  fan,
  pipe,
  conveyor,
  deviation,
  range,
  probe,
  horizontalTank,
  tube,
  flow,
  rotation,
  position,
  angle,
  differential,
  contact,
  light,
}

class InkSet {
  InkSet(BuildContext c, this.style) {
    if (!style.strokeWidth.isFinite ||
        style.strokeWidth <= 0 ||
        style.duration.isNegative) {
      throw ArgumentError(
        'Use a positive finite stroke and nonnegative duration',
      );
    }
    final dark = Theme.of(c).brightness == Brightness.dark;
    accent = style.accent ?? Color(dark ? 0xFF65D5C2 : 0xFF13796E);
    foreground = style.foreground ?? Color(dark ? 0xFFE9EFEF : 0xFF233432);
    muted = style.muted ?? Color(dark ? 0xFFA0B3B0 : 0xFF526863);
    material = style.surface ?? Color(dark ? 0xFF233632 : 0xFFF0F3EF);
    track = Color.lerp(material, foreground, .16)!;
    label = (style.labelStyle ?? DefaultTextStyle.of(c).style).copyWith(
      fontSize: style.labelStyle?.fontSize ?? 12,
      color: muted,
    );
    value = (style.valueStyle ?? DefaultTextStyle.of(c).style).copyWith(
      fontSize: style.valueStyle?.fontSize ?? 32,
      fontWeight: style.valueStyle?.fontWeight ?? FontWeight.w500,
      color: foreground,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
  final InstrumentStyle style;
  late final Color accent, foreground, muted, material, track;
  late final TextStyle label, value;
  bool get physical => style.appearance == InstrumentAppearance.instrument;
}

class InstrumentBody extends StatefulWidget {
  InstrumentBody({
    super.key,
    required this.shape,
    required this.style,
    this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '',
    this.label = '',
    this.formatter,
    this.target,
    this.reference = 0,
    this.secondaryScale,
    this.heightFraction,
    this.startLabel = '',
    this.endLabel = '',
    this.bands = const [],
    this.axis = Axis.horizontal,
    this.width,
    this.height,
    this.animate = false,
    this.state = EquipmentState.stopped,
    this.position = ValvePosition.unknown,
    this.direction = FlowDirection.forward,
    this.path = const [Offset(0, .5), Offset(1, .5)],
    this.caption,
    this.showValue = true,
  }) {
    validateRange(min, max);
    if ((shape == Shape.deviation || shape == Shape.differential) &&
        (reference < min || reference > max)) {
      throw ArgumentError('Reference must lie inside the configured range');
    }
    if (!reference.isFinite) throw ArgumentError('reference must be finite');
    if (heightFraction != null &&
        (!heightFraction!.isFinite ||
            heightFraction! < 0 ||
            heightFraction! > 1)) {
      throw ArgumentError('heightFraction must be 0–1');
    }
    if (target != null && !target!.isFinite) {
      throw ArgumentError('Target must be finite.');
    }
    if (style.strokeWidth <= 0 ||
        !style.strokeWidth.isFinite ||
        style.duration.isNegative) {
      throw ArgumentError('Stroke must be positive; duration nonnegative.');
    }
    for (final d in [width, height]) {
      if (d != null && (!d.isFinite || d <= 0)) {
        throw ArgumentError('Explicit dimensions must be finite and positive.');
      }
    }
    if (style case final GaugeStyle s) {
      if (!s.startAngle.isFinite ||
          !s.sweepAngle.isFinite ||
          s.sweepAngle <= 0 ||
          s.sweepAngle > 360) {
        throw ArgumentError("Gauge sweep must be finite and in (0, 360]");
      }
      if (s.divisions < 2 ||
          s.divisions > 10 ||
          s.minorTicks < 0 ||
          s.minorTicks > 5 ||
          s.segments < 4 ||
          s.segments > 40) {
        throw ArgumentError('Invalid tick or segment density.');
      }
    }
    if (style case final LevelStyle s) {
      if (!s.vesselWidth.isFinite || s.vesselWidth < .3 || s.vesselWidth > .8) {
        throw ArgumentError('Vessel width must be .3–.8.');
      }
    }
    if (style case final EquipmentStyle s) {
      if (s.cycle <= Duration.zero) {
        throw ArgumentError('Motion cycle must be positive.');
      }
    }
  }
  final double reference;
  final SecondaryScale? secondaryScale;
  final double? heightFraction;
  final String startLabel, endLabel;
  final Shape shape;
  final InstrumentStyle style;
  final double? value, target, width, height;
  final double min, max;
  final String unit, label;
  final String? caption;
  final InstrumentFormatter? formatter;
  final List<InstrumentBand> bands;
  final Axis axis;
  final bool animate, showValue;
  final EquipmentState state;
  final ValvePosition position;
  final FlowDirection direction;
  final List<Offset> path;
  @override
  State<InstrumentBody> createState() => _InstrumentBodyState();
}

class _InstrumentBodyState extends State<InstrumentBody>
    with SingleTickerProviderStateMixin {
  late final phase = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );
  bool get valid => widget.value != null && widget.value!.isFinite;
  bool get reduced =>
      MediaQuery.disableAnimationsOf(context) || !TickerMode.of(context);
  void sync() {
    final w = widget;
    final motion =
        w.animate &&
        !reduced &&
        ((w.shape.index >= Shape.pump.index &&
                w.shape.index <= Shape.conveyor.index &&
                w.state == EquipmentState.running) ||
            ((w.shape == Shape.flow || w.shape == Shape.rotation) &&
                valid &&
                w.state == EquipmentState.running) ||
            (w.shape == Shape.battery &&
                w.state == EquipmentState.running &&
                valid) ||
            (w.shape == Shape.liquid &&
                valid &&
                w.style is LevelStyle &&
                (w.style as LevelStyle).waves));
    final cycle = w.style is EquipmentStyle
        ? (w.style as EquipmentStyle).cycle
        : const Duration(seconds: 4);
    if (phase.duration != cycle) {
      phase.duration = cycle;
      if (phase.isAnimating) phase.repeat();
    }
    if (motion && !phase.isAnimating) phase.repeat();
    if (!motion) {
      phase.stop();
      if (phase.value != 0) phase.value = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sync();
  }

  @override
  void didUpdateWidget(InstrumentBody old) {
    super.didUpdateWidget(old);
    sync();
  }

  @override
  void dispose() {
    phase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget, ink = InkSet(context, w.style);
    final fraction = valid && w.heightFraction != null
        ? w.heightFraction
        : instrumentFraction(w.value, w.min, w.max);
    final value = valid
        ? (w.formatter?.call(w.value!) ??
              w.value!.toStringAsFixed(w.value!.abs() >= 100 ? 0 : 1))
        : '—';
    final outside = valid && (w.value! < w.min || w.value! > w.max);
    final equipment =
        w.shape.index >= Shape.pump.index &&
        w.shape.index <= Shape.conveyor.index;
    final status = [
      if (w.caption?.isNotEmpty ?? false) w.caption!,
      if (equipment && w.caption == null) w.state.name,
      if (!equipment && w.shape != Shape.contact && w.shape != Shape.light)
        if (!valid) 'No reading' else if (outside) 'Outside ${w.min}–${w.max}',
    ].join(' · ');
    return Semantics(
      label: [
        if (w.label.isNotEmpty) w.label,
        if (w.showValue || w.shape == Shape.battery) '$value ${w.unit}',
        if (!equipment && status.isNotEmpty) status,
        if (equipment)
          w.shape == Shape.valve
              ? '${w.position.name}${w.position == ValvePosition.intermediate ? ' · ${w.value}% open' : ''}'
              : w.state.name,
        if (equipment && w.shape != Shape.valve) w.direction.name,
        if (w.shape == Shape.battery && w.state == EquipmentState.running)
          'Charging',
        if (w.target != null) 'Target ${w.target} ${w.unit}',
        ...w.bands.where((b) => b.label.isNotEmpty).map((b) => b.label),
      ].join('. '),
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, c) {
            final width = w.width ?? (c.hasBoundedWidth ? c.maxWidth : 240.0);
            final plotHeight =
                w.height ??
                switch (w.shape) {
                  Shape.linear ||
                  Shape.segments ||
                  Shape.range ||
                  Shape.deviation ||
                  Shape.differential ||
                  Shape.position => w.axis == Axis.horizontal ? 72.0 : 180.0,
                  Shape.light => 48.0,
                  Shape.pump ||
                  Shape.valve ||
                  Shape.motor ||
                  Shape.fan ||
                  Shape.pipe ||
                  Shape.conveyor => 140.0,
                  _ => math.min(240.0, width * .86),
                };
            return SizedBox(
              width: width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (w.label.isNotEmpty) ...[
                    Text(w.label, style: ink.label),
                    const SizedBox(height: 12),
                  ],
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: fraction ?? 0),
                    duration: w.animate && !reduced && valid
                        ? w.style.duration
                        : Duration.zero,
                    curve: Curves.easeOutCubic,
                    builder: (context, f, _) => RepaintBoundary(
                      child: SizedBox(
                        height: plotHeight,
                        child: CustomPaint(
                          painter: InstrumentPainter(
                            w,
                            ink,
                            f,
                            valid,
                            phase,
                            MediaQuery.textScalerOf(context).scale(1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (w.showValue) ...[
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: value, style: ink.value),
                          if (w.unit.isNotEmpty)
                            TextSpan(
                              text: ' ${w.unit}',
                              style: ink.label.copyWith(fontSize: 16),
                            ),
                        ],
                      ),
                      textAlign: w.shape == Shape.radial || w.shape == Shape.arc
                          ? TextAlign.center
                          : TextAlign.start,
                    ),
                  ],
                  if (status.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(status, style: ink.label),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class InstrumentPainter extends CustomPainter {
  InstrumentPainter(
    this.w,
    this.ink,
    this.fraction,
    this.present,
    this.phase,
    this.textScale,
  ) : super(repaint: phase);
  final InstrumentBody w;
  final InkSet ink;
  final double fraction, textScale;
  final bool present;
  final Animation<double> phase;
  Paint stroke([Color? color, double? width]) => Paint()
    ..color = color ?? ink.foreground
    ..style = PaintingStyle.stroke
    ..strokeWidth = width ?? w.style.strokeWidth
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  Paint fill(Color c) => Paint()..color = c;
  void text(
    Canvas c,
    String text,
    Offset p, {
    double size = 12,
    bool center = true,
    Color? color,
  }) {
    final t = TextPainter(
      text: TextSpan(
        text: text,
        style: ink.label.copyWith(
          fontSize: size * textScale,
          color: color ?? ink.muted,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    t.paint(c, p - (center ? Offset(t.width / 2, t.height / 2) : Offset.zero));
  }

  String number(double n) =>
      (w.style is GaugeStyle ? (w.style as GaugeStyle).scaleFormatter : null)
          ?.call(n) ??
      (n.abs() >= 10000 || (n != 0 && n.abs() < .01)
          ? n.toStringAsExponential(0)
          : n.toStringAsFixed(n.abs() < 10 && n != n.roundToDouble() ? 1 : 0));
  @override
  void paint(Canvas c, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    switch (w.shape) {
      case Shape.radial:
        dial(c, size);
        break;
      case Shape.liquid:
        vessel(c, size);
        break;
      case Shape.linear:
        linear(c, size);
        break;
      case Shape.pump:
        equipment(c, size);
        break;
      case Shape.arc:
        arc(c, size);
        break;
      case Shape.segments:
        segments(c, size);
        break;
      case Shape.thermometer:
        thermometer(c, size);
        break;
      case Shape.cylinder:
      case Shape.silo:
        shapedVessel(c, size);
        break;
      case Shape.battery:
        battery(c, size);
        break;
      case Shape.valve:
      case Shape.motor:
      case Shape.fan:
      case Shape.conveyor:
        machinery(c, size);
        break;
      case Shape.pipe:
        pipe(c, size);
        break;
      case Shape.deviation:
      case Shape.differential:
        deviation(c, size);
        break;
      case Shape.range:
      case Shape.position:
        travel(c, size);
        break;
      case Shape.probe:
        probe(c, size);
        break;
      case Shape.horizontalTank:
      case Shape.tube:
        extraVessel(c, size);
        break;
      case Shape.flow:
      case Shape.rotation:
      case Shape.angle:
        movement(c, size);
        break;
      case Shape.contact:
        contact(c, size);
        break;
      case Shape.light:
        break;
    }
  }

  void dial(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height * .51),
        r = math.min(
          s.width * (w.secondaryScale == null ? .46 : .40),
          s.height * (w.secondaryScale == null ? .48 : .42),
        ),
        g = w.style as GaugeStyle;
    final start = g.startAngle * math.pi / 180,
        sweep = g.sweepAngle * math.pi / 180;
    Offset point(double f, double radius) =>
        center +
        Offset(math.cos(start + sweep * f), math.sin(start + sweep * f)) *
            radius;
    if (ink.physical) {
      c.drawCircle(center, r, fill(ink.material));
      c.drawCircle(center, r, stroke(ink.track, 5));
      c.drawCircle(
        center,
        r - 5,
        stroke(ink.foreground.withValues(alpha: .45), .7),
      );
      c.drawCircle(center, r * .88, stroke(ink.track, .8));
    } else {
      c.drawArc(
        Rect.fromCircle(center: center, radius: r * .95),
        start,
        sweep,
        false,
        stroke(ink.track, 1),
      );
    }
    for (final band in w.bands) {
      final a = instrumentFraction(band.min, w.min, w.max)!,
          b = instrumentFraction(band.max, w.min, w.max)!;
      if (b > a) {
        c.drawArc(
          Rect.fromCircle(center: center, radius: r * .94),
          start + a * sweep,
          (b - a) * sweep,
          false,
          stroke(band.color, 4),
        );
      }
    }
    final minor = s.width < 220 || textScale > 1.3 ? 0 : g.minorTicks,
        total = g.divisions * (minor + 1);
    for (var i = 0; i <= total; i++) {
      final major = i % (minor + 1) == 0;
      c.drawLine(
        point(i / total, r * .86),
        point(i / total, r * (major ? .75 : .81)),
        stroke(major ? ink.foreground : ink.muted, major ? 1.5 : .8),
      );
    }
    if (g.showLabels && s.width >= 180 && textScale <= 1.3) {
      for (var i = 0; i <= g.divisions; i++) {
        if (g.sweepAngle == 360 && i == g.divisions) continue;
        text(
          c,
          number(w.min + (w.max - w.min) * i / g.divisions),
          point(i / g.divisions, r * .65),
          size: 12,
        );
      }
    }
    if (w.secondaryScale case final SecondaryScale secondary) {
      if (s.width >= 260 && textScale <= 1.3) {
        for (var i = 0; i <= g.divisions; i++) {
          if (g.sweepAngle == 360 && i == g.divisions) continue;
          final v =
              secondary.min + (secondary.max - secondary.min) * i / g.divisions;
          text(
            c,
            secondary.formatter?.call(v) ?? v.toStringAsFixed(0),
            point(i / g.divisions, r * 1.08),
            size: 10,
          );
        }
      }
    }
    if (w.target != null) {
      final p = point(instrumentFraction(w.target, w.min, w.max)!, r * .92);
      c.drawCircle(p, 3, fill(ink.foreground));
    }
    if (present) {
      final tip = point(fraction, r * .56),
          angle = start + sweep * fraction,
          normal = Offset(-math.sin(angle), math.cos(angle));
      final path = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(center.dx + normal.dx * 3, center.dy + normal.dy * 3)
        ..lineTo(
          center.dx - math.cos(angle) * r * .12,
          center.dy - math.sin(angle) * r * .12,
        )
        ..lineTo(center.dx - normal.dx * 3, center.dy - normal.dy * 3)
        ..close();
      c.drawPath(path, fill(ink.accent));
    }
    c.drawCircle(center, ink.physical ? 8 : 5, fill(ink.foreground));
    c.drawCircle(center, ink.physical ? 4 : 2, fill(ink.material));
  }

  void linear(Canvas c, Size s) {
    final vertical = w.axis == Axis.vertical, g = w.style as GaugeStyle;
    final a = vertical ? Offset(s.width * .5, 18) : Offset(14, 26),
        b = vertical
            ? Offset(s.width * .5, s.height - 18)
            : Offset(s.width - 14, 26);
    Offset pos(double f) => vertical
        ? Offset(a.dx, b.dy - (b.dy - a.dy) * f)
        : Offset(a.dx + (b.dx - a.dx) * f, a.dy);
    c.drawLine(a, b, stroke(ink.track, ink.physical ? 12 : 5));
    if (ink.physical) c.drawLine(a, b, stroke(ink.material, 8));
    for (final band in w.bands) {
      final offset = vertical ? const Offset(14, 0) : const Offset(0, -12);
      c.drawLine(
        pos(instrumentFraction(band.min, w.min, w.max)!) + offset,
        pos(instrumentFraction(band.max, w.min, w.max)!) + offset,
        stroke(band.color, 3),
      );
    }
    for (var i = 0; i <= g.divisions; i++) {
      final p = pos(i / g.divisions);
      c.drawLine(
        p + (vertical ? const Offset(-7, 0) : const Offset(0, 8)),
        p + (vertical ? const Offset(-12, 0) : const Offset(0, 14)),
        stroke(ink.muted, 1),
      );
      if (g.showLabels &&
          textScale <= 1.3 &&
          (i == 0 || i == g.divisions || (!vertical && s.width > 320))) {
        text(
          c,
          number(w.min + (w.max - w.min) * i / g.divisions),
          p + (vertical ? const Offset(-32, 0) : const Offset(0, 30)),
        );
      }
    }
    if (present) {
      c.drawLine(pos(0), pos(fraction), stroke(ink.accent, 5));
      final p = pos(fraction);
      c.drawCircle(p, 5, fill(ink.material));
      c.drawCircle(p, 5, stroke(ink.accent, 2));
    }
    if (w.target != null) {
      final p = pos(instrumentFraction(w.target, w.min, w.max)!);
      c.drawLine(
        p + (vertical ? const Offset(-9, 0) : const Offset(0, -9)),
        p + (vertical ? const Offset(9, 0) : const Offset(0, 9)),
        stroke(ink.foreground, 2),
      );
    }
  }

  void vessel(Canvas c, Size s) {
    final v = w.style as LevelStyle;
    final r = Rect.fromCenter(
      center: Offset(s.width * .44, s.height * .48),
      width: math.min(s.width * v.vesselWidth, 150),
      height: s.height * .81,
    );
    final body = RRect.fromRectAndRadius(r, const Radius.circular(10));
    if (ink.physical) {
      c.drawRRect(body, fill(ink.material));
      c.drawLine(
        Offset(r.left - 5, r.top + 10),
        Offset(r.right + 5, r.top + 10),
        stroke(ink.foreground, 3),
      );
      c.drawLine(
        Offset(r.left - 5, r.bottom - 8),
        Offset(r.right + 5, r.bottom - 8),
        stroke(ink.foreground, 3),
      );
      for (final x in [r.left + 12, r.right - 12]) {
        c.drawLine(
          Offset(x, r.bottom),
          Offset(x, s.height * .95),
          stroke(ink.muted, 3),
        );
      }
    }
    c.save();
    c.clipRRect(body);
    if (present) {
      final y = r.bottom - r.height * fraction;
      final p = Path()
        ..moveTo(r.left, r.bottom)
        ..lineTo(r.left, y);
      for (var i = 0; i <= 40; i++) {
        p.lineTo(
          r.left + r.width * i / 40,
          y +
              (v.waves && fraction > 0 && fraction < 1
                  ? math.sin(i / 40 * math.pi * 2 + phase.value * math.pi * 2) *
                        2
                  : 0),
        );
      }
      p
        ..lineTo(r.right, r.bottom)
        ..close();
      c.drawPath(
        p,
        fill(ink.accent.withValues(alpha: ink.physical ? .66 : .42)),
      );
      c.drawLine(
        Offset(r.left, y),
        Offset(r.right, y),
        stroke(ink.accent, 1.5),
      );
    }
    c.restore();
    c.drawRRect(body, stroke());
    if (v.showMarks) {
      for (var i = 0; i <= 4; i++) {
        final y = r.bottom - r.height * i / 4;
        c.drawLine(
          Offset(r.right + 8, y),
          Offset(r.right + 14, y),
          stroke(ink.muted, 1),
        );
        if (textScale <= 1.3) {
          text(
            c,
            number(w.min + (w.max - w.min) * i / 4),
            Offset(r.right + 29, y),
            size: 11,
          );
        }
      }
    }
    if (w.target != null) {
      final y =
          r.bottom - r.height * instrumentFraction(w.target, w.min, w.max)!;
      c.drawLine(
        Offset(r.left - 5, y),
        Offset(r.left + 10, y),
        stroke(ink.foreground, 2),
      );
    }
  }

  void equipment(Canvas c, Size s) {
    final center = Offset(s.width * .46, s.height * .49),
        r = math.min(s.height * .28, s.width * .2),
        on = w.state == EquipmentState.running,
        color = on ? ink.accent : ink.muted;
    c.drawLine(Offset(4, center.dy), center - Offset(r, 0), stroke(color, 2));
    c.drawLine(
      center + Offset(r, 0),
      Offset(s.width - 4, center.dy),
      stroke(color, 2),
    );
    if (ink.physical) {
      c.drawCircle(center, r + 4, fill(ink.material));
      c.drawCircle(center, r + 4, stroke(ink.track, 3));
      for (var i = 0; i < 4; i++) {
        final a = math.pi / 4 + i * math.pi / 2;
        c.drawCircle(
          center + Offset(math.cos(a), math.sin(a)) * (r + 4),
          2,
          fill(ink.foreground),
        );
      }
    }
    c.drawCircle(center, r, stroke(color, 2));
    final angle =
        phase.value *
        math.pi *
        2 *
        (w.direction == FlowDirection.forward ? 1 : -1);
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(angle);
    final p = Path()
      ..moveTo(-r * .4, -r * .5)
      ..lineTo(r * .55, 0)
      ..lineTo(-r * .4, r * .5)
      ..close();
    c.drawPath(p, fill(color.withValues(alpha: on ? .8 : .3)));
    c.restore();
    final foot = Path()
      ..moveTo(center.dx - r * .6, center.dy + r * .8)
      ..lineTo(center.dx - r * .8, center.dy + r + 12)
      ..lineTo(center.dx + r * .8, center.dy + r + 12)
      ..lineTo(center.dx + r * .6, center.dy + r * .8);
    c.drawPath(foot, stroke(ink.muted));
    if (w.state == EquipmentState.fault) {
      c.drawLine(
        center - const Offset(9, 9),
        center + const Offset(9, 9),
        stroke(ink.foreground, 3),
      );
      c.drawLine(
        center + const Offset(9, -9),
        center + const Offset(-9, 9),
        stroke(ink.foreground, 3),
      );
    }
    if (w.state == EquipmentState.unknown) {
      text(c, '?', center, size: 20, color: ink.foreground);
    }
  }

  void arc(Canvas c, Size s) {
    final g = w.style as GaugeStyle,
        center = Offset(s.width / 2, s.height * .54),
        r = math.min(s.width * .43, s.height * .46);
    const start = math.pi * .78, sweep = math.pi * 1.44;
    final p = stroke(ink.track, ink.physical ? 18 : 10)
      ..strokeCap = g.roundCaps ? StrokeCap.round : StrokeCap.butt;
    final rect = Rect.fromCircle(center: center, radius: r);
    c.drawArc(rect, start, sweep, false, p);
    if (ink.physical) {
      c.drawArc(rect.deflate(3), start, sweep, false, stroke(ink.material, 10));
    }
    for (final band in w.bands) {
      final a = instrumentFraction(band.min, w.min, w.max)!,
          b = instrumentFraction(band.max, w.min, w.max)!;
      if (b > a) {
        c.drawArc(
          rect.inflate(12),
          start + a * sweep,
          (b - a) * sweep,
          false,
          stroke(band.color, 2),
        );
      }
    }
    if (present) {
      c.drawArc(
        rect,
        start,
        sweep * fraction,
        false,
        p
          ..color = ink.accent
          ..strokeWidth = ink.physical ? 10 : 10,
      );
    }
    if (w.target != null) {
      final angle = start + sweep * instrumentFraction(w.target, w.min, w.max)!,
          v = Offset(math.cos(angle), math.sin(angle));
      c.drawLine(
        center + v * (r - 12),
        center + v * (r + 12),
        stroke(ink.foreground, 2),
      );
    }
    if (g.showLabels && textScale <= 1.3) {
      text(
        c,
        number(w.min),
        center + Offset(math.cos(start), math.sin(start)) * (r - 22),
      );
      text(
        c,
        number(w.max),
        center +
            Offset(math.cos(start + sweep), math.sin(start + sweep)) * (r - 22),
      );
    }
  }

  void segments(Canvas c, Size s) {
    final g = w.style as GaugeStyle, vertical = w.axis == Axis.vertical;
    final area = vertical
        ? Rect.fromLTWH(s.width / 2 - 17, 8, 34, s.height - 16)
        : Rect.fromLTWH(5, 16, s.width - 10, 28);
    if (ink.physical) {
      c.drawRRect(
        RRect.fromRectAndRadius(area.inflate(5), const Radius.circular(5)),
        stroke(ink.track, 2),
      );
    }
    for (var i = 0; i < g.segments; i++) {
      final gap = 2.0,
          step = (vertical ? area.height : area.width) / g.segments;
      final rect = vertical
          ? Rect.fromLTWH(
              area.left,
              area.bottom - (i + 1) * step + gap / 2,
              area.width,
              math.max(.5, step - gap),
            )
          : Rect.fromLTWH(
              area.left + i * step + gap / 2,
              area.top,
              math.max(.5, step - gap),
              area.height,
            );
      var color = ink.accent;
      final value = w.min + (w.max - w.min) * (i + .5) / g.segments;
      for (final b in w.bands) {
        if (value >= b.min && value <= b.max) color = b.color;
      }
      c.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(ink.physical ? 1 : 2)),
        fill(
          present && fraction > i / g.segments
              ? color
              : ink.track.withValues(alpha: .55),
        ),
      );
    }
    if (w.target != null) {
      final f = instrumentFraction(w.target, w.min, w.max)!;
      if (vertical) {
        final y = area.bottom - area.height * f;
        c.drawLine(
          Offset(area.right + 5, y),
          Offset(area.right + 13, y),
          stroke(),
        );
      } else {
        final x = area.left + area.width * f;
        c.drawLine(
          Offset(x, area.bottom + 4),
          Offset(x, area.bottom + 12),
          stroke(),
        );
      }
    }
  }

  void thermometer(Canvas c, Size s) {
    final x = s.width * .4,
        top = 14.0,
        bottom = s.height - 25,
        bulb = math.min(18.0, s.width * .1),
        tube = 12.0;
    final tubePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x - tube / 2, top, x + tube / 2, bottom),
          const Radius.circular(6),
        ),
      );
    final body = Path.combine(
      PathOperation.union,
      tubePath,
      Path()..addOval(Rect.fromCircle(center: Offset(x, bottom), radius: bulb)),
    );
    if (ink.physical) {
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x - 30, 3, x + 60, s.height - 3),
          const Radius.circular(22),
        ),
        fill(ink.material),
      );
    }
    c.drawPath(body, fill(ink.track.withValues(alpha: .3)));
    c.save();
    c.clipPath(body);
    if (present) {
      c.drawRect(
        Rect.fromLTRB(
          x - bulb,
          bottom - (bottom - top) * fraction,
          x + bulb,
          bottom + bulb,
        ),
        fill(ink.accent),
      );
      c.drawCircle(Offset(x, bottom), bulb - 3, fill(ink.accent));
    }
    c.restore();
    c.drawPath(body, stroke());
    final g = w.style as GaugeStyle;
    for (var i = 0; i <= g.divisions; i++) {
      final y = bottom - (bottom - top) * i / g.divisions;
      c.drawLine(Offset(x + 17, y), Offset(x + 25, y), stroke(ink.muted, 1));
      if (g.showLabels && textScale <= 1.3) {
        text(
          c,
          number(w.min + (w.max - w.min) * i / g.divisions),
          Offset(x + 43, y),
        );
      }
    }
  }

  void shapedVessel(Canvas c, Size s) {
    final v = w.style as LevelStyle,
        r = Rect.fromCenter(
          center: Offset(s.width * .43, s.height * .48),
          width: math.min(s.width * v.vesselWidth, 150),
          height: s.height * .76,
        ),
        cylinder = w.shape == Shape.cylinder;
    final path = cylinder
        ? (Path()
            ..moveTo(r.left, r.top + 10)
            ..quadraticBezierTo(r.center.dx, r.top - 10, r.right, r.top + 10)
            ..lineTo(r.right, r.bottom - 10)
            ..quadraticBezierTo(
              r.center.dx,
              r.bottom + 12,
              r.left,
              r.bottom - 10,
            )
            ..close())
        : (Path()
            ..moveTo(r.left, r.top)
            ..lineTo(r.right, r.top)
            ..lineTo(r.right, r.bottom - 45)
            ..lineTo(r.center.dx + 12, r.bottom)
            ..lineTo(r.center.dx - 12, r.bottom)
            ..lineTo(r.left, r.bottom - 45)
            ..close());
    if (ink.physical) c.drawPath(path, fill(ink.material));
    c.save();
    c.clipPath(path);
    if (present) {
      final y = r.bottom - r.height * fraction;
      c.drawRect(
        Rect.fromLTRB(r.left, y, r.right, r.bottom + 12),
        fill(ink.accent.withValues(alpha: .5)),
      );
      if (cylinder) {
        c.drawOval(
          Rect.fromCenter(
            center: Offset(r.center.dx, y),
            width: r.width,
            height: 18,
          ),
          fill(ink.accent.withValues(alpha: .35)),
        );
      } else {
        c.drawLine(Offset(r.left, y), Offset(r.right, y), stroke(ink.accent));
      }
    }
    if (ink.physical) {
      c.drawRect(
        Rect.fromLTWH(r.left, r.top, 8, r.height),
        fill(ink.foreground.withValues(alpha: .07)),
      );
    }
    c.restore();
    c.drawPath(path, stroke());
    if (cylinder) {
      c.drawOval(
        Rect.fromLTRB(r.left, r.top, r.right, r.top + 20),
        stroke(ink.muted),
      );
      c.drawArc(
        Rect.fromLTRB(r.left, r.bottom - 20, r.right, r.bottom),
        0,
        math.pi,
        false,
        stroke(ink.muted),
      );
    } else {
      c.drawLine(
        Offset(r.left + 8, r.top + 8),
        Offset(r.left + 8, r.bottom + 10),
        stroke(ink.muted),
      );
      c.drawLine(
        Offset(r.right - 8, r.top + 8),
        Offset(r.right - 8, r.bottom + 10),
        stroke(ink.muted),
      );
    }
    if (v.showMarks) {
      for (var i = 0; i <= 4; i++) {
        final y = r.bottom - r.height * i / 4;
        c.drawLine(
          Offset(r.right + 7, y),
          Offset(r.right + 13, y),
          stroke(ink.muted, 1),
        );
        if (textScale <= 1.3) {
          text(
            c,
            number(w.min + (w.max - w.min) * i / 4),
            Offset(r.right + 28, y),
            size: 11,
          );
        }
      }
    }
    if (w.target != null) {
      final y =
          r.bottom - r.height * instrumentFraction(w.target, w.min, w.max)!;
      c.drawLine(
        Offset(r.left - 5, y),
        Offset(r.left + 10, y),
        stroke(ink.foreground, 2),
      );
    }
  }

  void battery(Canvas c, Size s) {
    final vertical = w.axis == Axis.vertical;
    final r = vertical
        ? Rect.fromCenter(
            center: Offset(s.width / 2, s.height / 2),
            width: 64,
            height: s.height * .76,
          )
        : Rect.fromCenter(
            center: Offset(s.width / 2 - 4, s.height / 2),
            width: s.width * .86,
            height: 62,
          );
    final shell = RRect.fromRectAndRadius(r, const Radius.circular(7));
    if (ink.physical) c.drawRRect(shell, fill(ink.material));
    c.drawRRect(shell, stroke());
    final cap = vertical
        ? Rect.fromLTWH(r.center.dx - 12, r.top - 6, 24, 5)
        : Rect.fromLTWH(r.right + 2, r.center.dy - 12, 5, 24);
    c.drawRRect(
      RRect.fromRectAndRadius(cap, const Radius.circular(2)),
      fill(ink.muted),
    );
    final inside = r.deflate(5);
    c.save();
    c.clipRRect(RRect.fromRectAndRadius(inside, const Radius.circular(3)));
    if (present) {
      final f = vertical
          ? Rect.fromLTRB(
              inside.left,
              inside.bottom - inside.height * fraction,
              inside.right,
              inside.bottom,
            )
          : Rect.fromLTRB(
              inside.left,
              inside.top,
              inside.left + inside.width * fraction,
              inside.bottom,
            );
      c.drawRect(f, fill(ink.accent.withValues(alpha: .7)));
      if (w.state == EquipmentState.running) {
        final x = inside.left + inside.width * phase.value;
        c.drawRect(
          Rect.fromLTWH(x, inside.top, 3, inside.height),
          fill(ink.foreground.withValues(alpha: .25)),
        );
      }
    }
    c.restore();
    if (ink.physical) {
      c.drawRRect(
        RRect.fromRectAndRadius(r.deflate(2), const Radius.circular(5)),
        stroke(ink.track, 1),
      );
    }
    if (w.state == EquipmentState.running) {
      final p = Path()
        ..moveTo(r.center.dx + 4, r.center.dy - 15)
        ..lineTo(r.center.dx - 8, r.center.dy + 2)
        ..lineTo(r.center.dx + 1, r.center.dy + 2)
        ..lineTo(r.center.dx - 4, r.center.dy + 15)
        ..lineTo(r.center.dx + 9, r.center.dy - 3)
        ..lineTo(r.center.dx, r.center.dy - 3)
        ..close();
      c.drawPath(p, fill(ink.foreground));
    }
  }

  void machinery(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height / 2),
        color = w.state == EquipmentState.running ? ink.accent : ink.muted,
        angle =
            phase.value *
            math.pi *
            2 *
            (w.direction == FlowDirection.forward ? 1 : -1),
        r = math.min(s.height * .36, s.width * .3);
    if (w.shape == Shape.valve) {
      final half = math.min(s.width * .24, 42.0),
          path = Path()
            ..moveTo(center.dx - half, center.dy - 25)
            ..lineTo(center.dx + half, center.dy + 25)
            ..lineTo(center.dx + half, center.dy - 25)
            ..lineTo(center.dx - half, center.dy + 25)
            ..close();
      if (ink.physical) {
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: half * 2 + 16, height: 62),
            const Radius.circular(6),
          ),
          fill(ink.material),
        );
      }
      c.save();
      c.clipPath(path);
      if (present) {
        c.drawRect(
          Rect.fromLTRB(
            center.dx - half,
            center.dy - 25,
            center.dx + half * (1 - 2 * fraction),
            center.dy + 25,
          ),
          fill(ink.accent.withValues(alpha: .65)),
        );
      }
      c.restore();
      c.drawPath(path, stroke());
      c.drawLine(Offset(5, center.dy), center - Offset(half, 0), stroke());
      c.drawLine(
        center + Offset(half, 0),
        Offset(s.width - 5, center.dy),
        stroke(),
      );
      c.drawLine(center, center - const Offset(0, 42), stroke());
      c.save();
      c.translate(center.dx, center.dy - 42);
      c.rotate(present ? (1 - fraction) * math.pi / 2 : 0);
      c.drawLine(
        const Offset(-16, 0),
        const Offset(16, 0),
        stroke(ink.accent, 3),
      );
      c.restore();
      if (!present) text(c, '?', center, size: 20, color: ink.foreground);
    } else if (w.shape == Shape.motor) {
      final body = Rect.fromCenter(
        center: center - const Offset(10, 0),
        width: math.min(s.width * .64, 150),
        height: 65,
      );
      if (ink.physical) {
        c.drawRRect(
          RRect.fromRectAndRadius(body.inflate(3), const Radius.circular(9)),
          fill(ink.material),
        );
      }
      c.drawRRect(
        RRect.fromRectAndRadius(body, const Radius.circular(7)),
        stroke(color, 2),
      );
      for (var i = 1; i < 7; i++) {
        final x = body.left + body.width * i / 7;
        c.drawLine(
          Offset(x, body.top + 8),
          Offset(x, body.bottom - 8),
          stroke(ink.muted, 1),
        );
      }
      c.drawRect(
        Rect.fromLTWH(body.center.dx - 16, body.top - 12, 32, 12),
        stroke(),
      );
      c.drawLine(
        Offset(body.right, center.dy),
        Offset(s.width - 8, center.dy),
        stroke(color, 6),
      );
      for (final x in [body.left + 15, body.right - 15]) {
        c.drawLine(
          Offset(x, body.bottom),
          Offset(x, body.bottom + 8),
          stroke(),
        );
        c.drawLine(
          Offset(x - 9, body.bottom + 8),
          Offset(x + 9, body.bottom + 8),
          stroke(),
        );
      }
      c.save();
      c.translate(s.width - 17, center.dy);
      c.rotate(angle);
      c.drawLine(
        const Offset(0, -10),
        const Offset(0, 10),
        stroke(ink.foreground, 2),
      );
      c.restore();
    } else if (w.shape == Shape.fan) {
      if (ink.physical) {
        final box = Rect.fromCircle(center: center, radius: r + 5);
        c.drawRRect(
          RRect.fromRectAndRadius(box, const Radius.circular(12)),
          fill(ink.material),
        );
        c.drawRRect(
          RRect.fromRectAndRadius(box, const Radius.circular(12)),
          stroke(ink.track, 2),
        );
        for (final x in [box.left + 7, box.right - 7]) {
          for (final y in [box.top + 7, box.bottom - 7]) {
            c.drawCircle(Offset(x, y), 2, fill(ink.muted));
          }
        }
      }
      c.drawCircle(center, r, stroke(ink.muted));
      c.save();
      c.translate(center.dx, center.dy);
      c.rotate(angle);
      for (var i = 0; i < 4; i++) {
        c.rotate(math.pi / 2);
        final blade = Path()
          ..moveTo(3, -3)
          ..quadraticBezierTo(r * .7, -r * .7, r * .88, 0)
          ..quadraticBezierTo(r * .6, r * .25, 7, 5)
          ..close();
        c.drawPath(blade, fill(color.withValues(alpha: .65)));
      }
      c.restore();
      c.drawCircle(center, 7, fill(ink.foreground));
    } else if (w.shape == Shape.conveyor) {
      final rect = Rect.fromCenter(
        center: center,
        width: s.width - 18,
        height: 46,
      );
      if (ink.physical) {
        c.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(5), const Radius.circular(28)),
          fill(ink.material),
        );
      }
      c.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(24)),
        stroke(color, 2),
      );
      for (var i = 0; i < 5; i++) {
        final x = rect.left + 23 + (rect.width - 46) * i / 4;
        c.drawCircle(Offset(x, center.dy), 12, stroke(ink.muted));
        c.drawLine(
          Offset(x, center.dy) + Offset(math.cos(angle), math.sin(angle)) * 8,
          Offset(x, center.dy) - Offset(math.cos(angle), math.sin(angle)) * 8,
          stroke(ink.track),
        );
      }
      final f = w.direction == FlowDirection.forward
          ? phase.value
          : 1 - phase.value;
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rect.left + (rect.width - 26) * f,
            rect.top - 22,
            26,
            20,
          ),
          const Radius.circular(2),
        ),
        fill(color.withValues(alpha: .6)),
      );
      for (final x in [rect.left + 24, rect.right - 24]) {
        c.drawLine(
          Offset(x, rect.bottom),
          Offset(x, rect.bottom + 12),
          stroke(ink.muted),
        );
      }
    }
    if (w.state == EquipmentState.fault) {
      c.drawLine(
        const Offset(5, 5),
        const Offset(15, 15),
        stroke(ink.foreground, 2),
      );
      c.drawLine(
        const Offset(5, 15),
        const Offset(15, 5),
        stroke(ink.foreground, 2),
      );
    }
  }

  void pipe(Canvas c, Size s) {
    final path = Path();
    for (var i = 0; i < w.path.length; i++) {
      final p = Offset(
        9 + w.path[i].dx * (s.width - 18),
        9 + w.path[i].dy * (s.height - 18),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    c.drawPath(
      path,
      stroke(ink.physical ? ink.foreground : ink.track, ink.physical ? 16 : 12),
    );
    c.drawPath(path, stroke(ink.material, ink.physical ? 12 : 8));
    if (w.state == EquipmentState.running) {
      c.drawPath(path, stroke(ink.accent.withValues(alpha: .65), 6));
    }
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    for (var i = 0; i < 3; i++) {
      var f = (i / 3 + phase.value / 3) % 1;
      if (w.direction == FlowDirection.reverse) f = 1 - f;
      final tangent = metric.getTangentForOffset(
        6 + (metric.length - 12).clamp(0, double.infinity) * f,
      );
      if (tangent == null) continue;
      c.save();
      c.translate(tangent.position.dx, tangent.position.dy);
      c.rotate(
        tangent.angle + (w.direction == FlowDirection.reverse ? math.pi : 0),
      );
      c.drawPath(
        Path()
          ..moveTo(-3, -2.5)
          ..lineTo(1, 0)
          ..lineTo(-3, 2.5),
        stroke(ink.foreground, 1.5),
      );
      c.restore();
    }
  }

  void deviation(Canvas c, Size s) {
    final left = 18.0, right = s.width - 18, y = s.height * .42;
    final zero = instrumentFraction(w.reference, w.min, w.max)!;
    final zx = left + (right - left) * zero,
        x = left + (right - left) * fraction;
    c.drawLine(Offset(left, y), Offset(right, y), stroke(ink.track, 4));
    for (var i = 0; i <= 4; i++) {
      final xx = left + (right - left) * i / 4;
      c.drawLine(Offset(xx, y + 7), Offset(xx, y + 12), stroke(ink.muted, 1));
    }
    c.drawLine(
      Offset(zx, y - 18),
      Offset(zx, y + 16),
      stroke(ink.foreground, 1),
    );
    if (present) {
      c.drawLine(Offset(zx, y), Offset(x, y), stroke(ink.accent, 4));
      c.drawPath(
        Path()
          ..moveTo(x, y - 5)
          ..lineTo(x - 5, y - 13)
          ..lineTo(x + 5, y - 13)
          ..close(),
        fill(ink.accent),
      );
    }
    if (textScale <= 1.3) {
      text(c, number(w.min), Offset(left, y + 27));
      text(c, number(w.max), Offset(right, y + 27));
    }
    if (w.target != null) {
      final t =
          left + (right - left) * instrumentFraction(w.target, w.min, w.max)!;
      c.drawCircle(Offset(t, y), 3, fill(ink.foreground));
    }
  }

  void travel(Canvas c, Size s) {
    final vertical = w.axis == Axis.vertical;
    final a = vertical
        ? Offset(s.width / 2, s.height - 24)
        : Offset(18, s.height * .4);
    final b = vertical
        ? Offset(s.width / 2, 24)
        : Offset(s.width - 18, s.height * .4);
    final p = Offset.lerp(a, b, fraction)!;
    c.drawLine(a, b, stroke(ink.track, w.shape == Shape.position ? 8 : 5));
    for (final point in [a, b]) {
      c.drawLine(
        point + (vertical ? const Offset(-8, 0) : const Offset(0, -8)),
        point + (vertical ? const Offset(8, 0) : const Offset(0, 8)),
        stroke(ink.foreground, 1.5),
      );
    }
    if (present) {
      if (w.shape == Shape.position) {
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: p,
              width: vertical ? 28 : 12,
              height: vertical ? 12 : 28,
            ),
            const Radius.circular(2),
          ),
          fill(ink.accent),
        );
      } else {
        c.drawCircle(p, 6, fill(ink.material));
        c.drawCircle(p, 6, stroke(ink.accent, 2));
      }
    }
    if (w.target != null) {
      final t = Offset.lerp(a, b, instrumentFraction(w.target, w.min, w.max)!)!;
      c.drawLine(
        t + (vertical ? const Offset(-14, 0) : const Offset(0, -14)),
        t + (vertical ? const Offset(14, 0) : const Offset(0, 14)),
        stroke(ink.foreground, 1),
      );
    }
    if (textScale <= 1.3) {
      text(
        c,
        number(w.min),
        a + (vertical ? const Offset(-30, 0) : const Offset(0, 25)),
      );
      text(
        c,
        number(w.max),
        b + (vertical ? const Offset(-30, 0) : const Offset(0, 25)),
      );
    }
  }

  void probe(Canvas c, Size s) {
    final x = s.width * .42, top = 16.0, bottom = s.height - 18;
    final head = Rect.fromLTWH(x - 22, top, 44, 34);
    c.drawRRect(
      RRect.fromRectAndRadius(head, const Radius.circular(5)),
      fill(ink.material),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(head, const Radius.circular(5)),
      stroke(),
    );
    c.drawLine(
      Offset(x - 10, top + 9),
      Offset(x + 10, top + 9),
      stroke(ink.muted, 1),
    );
    c.drawPath(
      Path()
        ..moveTo(head.right, top + 17)
        ..lineTo(head.right + 30, top + 17)
        ..quadraticBezierTo(
          head.right + 40,
          top + 17,
          head.right + 40,
          top + 3,
        ),
      stroke(ink.muted, 2),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(x - 4, head.bottom, x + 4, bottom),
        const Radius.circular(4),
      ),
      stroke(ink.foreground, 1.5),
    );
    c.drawLine(
      Offset(x - 10, head.bottom + 10),
      Offset(x + 10, head.bottom + 10),
      stroke(),
    );
    c.drawLine(
      Offset(x, bottom - 18),
      Offset(x, bottom - 3),
      stroke(present ? ink.accent : ink.track, 4),
    );
  }

  void extraVessel(Canvas c, Size s) {
    final horizontal = w.shape == Shape.horizontalTank;
    final r = horizontal
        ? Rect.fromLTWH(12, 16, s.width - 45, s.height - 40)
        : Rect.fromLTWH(s.width * .38 - 12, 10, 24, s.height - 25);
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          r,
          Radius.circular(horizontal ? r.height / 2 : 10),
        ),
      );
    c.save();
    c.clipPath(path);
    if (ink.physical) c.drawPath(path, fill(ink.material));
    if (present && fraction > 0) {
      final y = r.bottom - r.height * fraction;
      c.drawRect(
        Rect.fromLTRB(r.left, y, r.right, r.bottom),
        fill(ink.accent.withValues(alpha: .5)),
      );
      if (fraction < 1) {
        c.drawLine(
          Offset(r.left, y),
          Offset(r.right, y),
          stroke(ink.accent, 1.2),
        );
      }
    }
    c.restore();
    c.drawPath(path, stroke());
    if (horizontal) {
      for (final x in [r.left + r.width * .25, r.right - r.width * .25]) {
        c.drawLine(
          Offset(x, r.bottom),
          Offset(x, r.bottom + 10),
          stroke(ink.muted, 2),
        );
      }
    } else {
      for (final y in [r.top + 3, r.bottom - 3]) {
        c.drawLine(
          Offset(r.left - 7, y),
          Offset(r.right + 7, y),
          stroke(ink.foreground, 3),
        );
      }
      if (present) {
        final y = r.bottom - r.height * fraction;
        c.drawPath(
          Path()
            ..moveTo(r.left - 4, y)
            ..lineTo(r.left - 11, y - 4)
            ..lineTo(r.left - 11, y + 4)
            ..close(),
          fill(ink.accent),
        );
      }
    }
    final style = w.style as LevelStyle;
    if (style.showMarks) {
      for (var i = 0; i <= 4; i++) {
        final y = r.bottom - r.height * i / 4;
        c.drawLine(
          Offset(r.right + 5, y),
          Offset(r.right + 11, y),
          stroke(ink.muted, 1),
        );
        if (textScale <= 1.3) {
          text(
            c,
            w.heightFraction != null
                ? '${i * 25}%'
                : number(w.min + (w.max - w.min) * i / 4),
            Offset(r.right + 22, y),
            size: 10,
          );
        }
      }
    }
  }

  void movement(Canvas c, Size s) {
    final reverse = w.direction == FlowDirection.reverse;
    if (w.shape == Shape.flow) {
      final y = s.height * .45;
      c.drawLine(
        Offset(10, y - 10),
        Offset(s.width - 10, y - 10),
        stroke(ink.track),
      );
      c.drawLine(
        Offset(10, y + 10),
        Offset(s.width - 10, y + 10),
        stroke(ink.track),
      );
      if (present) {
        for (var i = 0; i < 3; i++) {
          var f = (i / 3 + phase.value / 3) % 1;
          if (reverse) f = 1 - f;
          final x = 20 + (s.width - 40) * f;
          c.save();
          c.translate(x, y);
          if (reverse) c.rotate(math.pi);
          c.drawPath(
            Path()
              ..moveTo(-6, -5)
              ..lineTo(1, 0)
              ..lineTo(-6, 5),
            stroke(ink.accent, 2),
          );
          c.restore();
        }
      }
      return;
    }
    final center = s.center(Offset.zero), r = math.min(s.width, s.height) * .38;
    if (w.shape == Shape.rotation) {
      c.drawCircle(center, r * .72, stroke(ink.track, 2));
      c.save();
      c.translate(center.dx, center.dy);
      c.rotate(phase.value * math.pi * 2 * (reverse ? -1 : 1));
      for (var i = 0; i < 3; i++) {
        c.rotate(math.pi * 2 / 3);
        c.drawLine(Offset.zero, Offset(r * .62, 0), stroke(ink.accent, 3));
      }
      c.restore();
      c.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -.6,
        reverse ? -math.pi * 1.4 : math.pi * 1.4,
        false,
        stroke(ink.muted),
      );
      final angle = -.6 + (reverse ? -math.pi * 1.4 : math.pi * 1.4),
          p = center + Offset(math.cos(angle), math.sin(angle)) * r;
      c.save();
      c.translate(p.dx, p.dy);
      c.rotate(angle + (reverse ? -math.pi / 2 : math.pi / 2));
      c.drawPath(
        Path()
          ..moveTo(0, 0)
          ..lineTo(-7, -4)
          ..lineTo(-7, 4)
          ..close(),
        fill(ink.muted),
      );
      c.restore();
      c.drawCircle(center, 4, fill(ink.foreground));
      return;
    }
    final base = w.reference * math.pi / 180,
        angle =
            base +
            (w.min + (w.max - w.min) * fraction) *
                math.pi /
                180 *
                (reverse ? -1 : 1);
    c.drawCircle(center, r, stroke(ink.track));
    for (var i = 0; i < 12; i++) {
      final a = base + i * math.pi / 6;
      c.drawLine(
        center + Offset(math.cos(a), math.sin(a)) * r * .9,
        center + Offset(math.cos(a), math.sin(a)) * r,
        stroke(ink.muted, 1),
      );
    }
    c.drawLine(
      center,
      center + Offset(math.cos(base), math.sin(base)) * r,
      stroke(ink.muted, 1),
    );
    if (present) {
      c.drawArc(
        Rect.fromCircle(center: center, radius: r * .7),
        base,
        angle - base,
        false,
        stroke(ink.accent, 2),
      );
      c.drawLine(
        center,
        center + Offset(math.cos(angle), math.sin(angle)) * r * .85,
        stroke(ink.accent, 2),
      );
    }
    c.drawCircle(center, 3, fill(ink.foreground));
  }

  void contact(Canvas c, Size s) {
    final y = s.height * .58,
        a = Offset(s.width * .34, y),
        b = Offset(s.width * .66, y);
    c.drawLine(Offset(8, y), a, stroke());
    c.drawLine(b, Offset(s.width - 8, y), stroke());
    for (final p in [a, b]) {
      c.drawCircle(p, 4, fill(ink.material));
      c.drawCircle(p, 4, stroke());
    }
    final closed = present && fraction > .5;
    if (present) {
      c.drawLine(
        a + const Offset(4, 0),
        closed ? b - const Offset(4, 0) : b - const Offset(4, 26),
        stroke(ink.accent, 2),
      );
    } else {
      text(c, '?', Offset(s.width / 2, y - 12), size: 20);
    }
  }

  @override
  bool shouldRepaint(InstrumentPainter old) =>
      old.fraction != fraction ||
      old.present != present ||
      old.w != w ||
      old.textScale != textScale ||
      old.ink.accent != ink.accent ||
      old.ink.foreground != ink.foreground ||
      old.ink.material != ink.material;
}
