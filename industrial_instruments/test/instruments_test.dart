import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:industrial_instruments/industrial_instruments.dart';
import 'package:industrial_instruments/src/rendering.dart';
import 'support/catalog.dart';

Widget host(
  Widget child, {
  double width = 240,
  double scale = 1,
  bool reduced = false,
  bool ticker = true,
  Brightness brightness = Brightness.light,
}) => MaterialApp(
  theme: ThemeData(brightness: brightness),
  home: MediaQuery(
    data: MediaQueryData(
      textScaler: TextScaler.linear(scale),
      disableAnimations: reduced,
    ),
    child: TickerMode(
      enabled: ticker,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    ),
  ),
);
InstrumentPainter painter(WidgetTester t) => t
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((w) => w.painter)
    .whereType<InstrumentPainter>()
    .first;
void main() {
  test('range handling preserves missing values and clamps only positions', () {
    expect(instrumentFraction(null, 0, 100), isNull);
    expect(instrumentFraction(double.nan, 0, 100), isNull);
    expect(instrumentFraction(double.infinity, 0, 100), isNull);
    expect(instrumentFraction(-50, -20, 80), 0);
    expect(instrumentFraction(120, -20, 80), 1);
    expect(instrumentFraction(30, -20, 80), .5);
    expect(() => validateRange(1, 1), throwsArgumentError);
    expect(() => validateRange(0, double.infinity), throwsArgumentError);
  });
  for (final brightness in Brightness.values) {
    testWidgets(
      'all 33, ${brightness.name}: sizes, text scales, bounds and missing',
      (t) async {
        for (final width in [180.0, 360.0]) {
          for (final scale in [1.0, 2.0]) {
            for (var kind = 0; kind < 7; kind++) {
              final widgets = [
                for (var i = 0; i < 33; i++)
                  buildInstrument(
                    i,
                    value: switch (kind) {
                      0 => null,
                      1 => minima[i],
                      2 => maxima[i],
                      3 => minima[i] - (maxima[i] - minima[i]),
                      4 => maxima[i] + (maxima[i] - minima[i]),
                      5 => double.nan,
                      _ => double.infinity,
                    },
                  ),
              ];
              await t.pumpWidget(
                host(
                  Column(children: widgets),
                  width: width,
                  scale: scale,
                  brightness: brightness,
                ),
              );
              await t.pump();
              expect(
                t.takeException(),
                isNull,
                reason: 'width=$width scale=$scale kind=$kind',
              );
            }
          }
        }
      },
    );
  }
  testWidgets(
    'out-of-range text remains actual and captions do not mask missing',
    (t) async {
      final semantics = t.ensureSemantics();
      await t.pumpWidget(
        host(const RadialGauge(value: 170, label: 'Pressure', unit: 'bar')),
      );
      expect(painter(t).fraction, 1);
      expect(
        find.bySemanticsLabel(RegExp('Pressure.*170.*Outside')),
        findsOneWidget,
      );
      await t.pumpWidget(host(const DeviationIndicator(value: null)));
      expect(find.textContaining('No reading'), findsOneWidget);
      await t.pumpWidget(
        host(
          const BatteryIndicator(
            value: null,
            activity: BatteryActivity.charging,
            showValue: false,
          ),
        ),
      );
      expect(find.textContaining('No reading'), findsOneWidget);
      semantics.dispose();
    },
  );
  testWidgets('interrupted animation starts from current visual position', (
    t,
  ) async {
    Widget gauge(double v) => host(
      RadialGauge(
        value: v,
        animate: true,
        style: const GaugeStyle(duration: Duration(seconds: 1)),
      ),
    );
    await t.pumpWidget(gauge(0));
    await t.pumpWidget(gauge(100));
    await t.pump(const Duration(milliseconds: 300));
    final before = painter(t).fraction;
    expect(before, inExclusiveRange(0, 1));
    await t.pumpWidget(gauge(20));
    expect(painter(t).fraction, closeTo(before, .00001));
    await t.pump(const Duration(seconds: 1));
    expect(painter(t).fraction, closeTo(.2, .00001));
  });
  testWidgets('motion stops when disabled, reduced, hidden and disposed', (
    t,
  ) async {
    Widget pump({
      bool animate = true,
      bool reduced = false,
      bool ticker = true,
    }) => host(
      PumpIndicator(state: EquipmentState.running, animate: animate),
      reduced: reduced,
      ticker: ticker,
    );
    await t.pumpWidget(pump());
    await t.pump(const Duration(milliseconds: 20));
    expect(t.binding.transientCallbackCount, greaterThan(0));
    for (final w in [
      pump(animate: false),
      pump(reduced: true),
      pump(ticker: false),
    ]) {
      await t.pumpWidget(w);
      await t.pumpAndSettle();
      expect(t.binding.transientCallbackCount, 0);
    }
    await t.pumpWidget(pump());
    await t.pumpWidget(const SizedBox());
    await t.pump();
    expect(t.binding.transientCallbackCount, 0);
    expect(t.takeException(), isNull);
  });
  testWidgets('unbounded horizontal layout uses finite documented widths', (
    t,
  ) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const RadialGauge(value: 42),
                const HorizontalTank(value: 40),
                ThreePhaseReadout(values: [1, 2, 3]),
                const DigitalReadout(value: 42),
              ],
            ),
          ),
        ),
      ),
    );
    expect(t.takeException(), isNull);
    expect(t.getSize(find.byType(RadialGauge)).width, 240);
    expect(t.getSize(find.byType(ThreePhaseReadout)).width, 320);
  });
  test(
    'presets edit label/unit/format without conversion or inferred limits',
    () {
      final p = ParameterPresets.temperatureC.copyWith(
        label: 'Bearing',
        unit: 'K',
        precision: 2,
      );
      expect(p.format(72), '72.00');
      expect(p.unit, 'K');
      expect(ParameterPresets.temperatureC.unit, '°C');
      expect(p.format(double.nan), '—');
      final g = p.radialGauge(value: 72, min: 0, max: 500);
      expect(g.value, 72);
      expect(g.max, 500);
      expect(g.bands, isEmpty);
      expect(
        () => ParameterPresets.powerFactor(convention: ''),
        throwsArgumentError,
      );
      expect(
        ParameterPresets.powerFactor(
          convention: 'Negative = export; lagging',
        ).format(-.83),
        '-0.830',
      );
    },
  );
  test('three-phase input snapshots are immutable and validated', () {
    final values = <double?>[230, null, 231], labels = ['R', 'Y', 'B'];
    final w = ThreePhaseReadout(values: values, labels: labels);
    values[0] = 0;
    labels[0] = 'changed';
    expect(w.values.first, 230);
    expect(w.labels.first, 'R');
    expect(() => w.values.add(3), throwsUnsupportedError);
    expect(() => ThreePhaseReadout(values: [1, 2]), throwsArgumentError);
    expect(
      () => ThreePhaseReadout(values: [1, 2, 3], labels: ['', '', '']),
      throwsArgumentError,
    );
  });
  testWidgets('three-phase semantics distinguish the missing phase', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(host(ThreePhaseReadout(values: [230, null, 231])));
    expect(find.bySemanticsLabel('L1: 230.0 V'), findsOneWidget);
    expect(find.bySemanticsLabel('L2: No reading'), findsOneWidget);
    expect(find.bySemanticsLabel('L3: 231.0 V'), findsOneWidget);
    handle.dispose();
  });
  testWidgets('pressure convention and volume mappings are explicit', (
    t,
  ) async {
    await t.pumpWidget(
      host(
        const VacuumGauge(
          value: 20,
          min: -100,
          max: 0,
          convention: PressureConvention.absolute,
        ),
      ),
    );
    expect(t.takeException(), isArgumentError);
    await t.pumpWidget(
      host(
        const HorizontalTank(
          value: 500,
          min: 0,
          max: 1000,
          unit: 'L',
          quantity: LevelQuantity.volume,
        ),
      ),
    );
    expect(t.takeException(), isArgumentError);
    await t.pumpWidget(
      host(
        const HorizontalTank(
          value: 500,
          min: 0,
          max: 1000,
          unit: 'L',
          quantity: LevelQuantity.volume,
          heightFraction: .7,
        ),
      ),
    );
    expect(painter(t).fraction, .7);
    expect(find.textContaining('Volume'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('dual pressure scale uses caller endpoints and custom sweep', (
    t,
  ) async {
    await t.pumpWidget(
      host(
        PressureDial(
          value: 6.4,
          min: 0,
          max: 10,
          secondaryScale: SecondaryScale(min: 0, max: 145, unit: 'psi'),
          style: const GaugeStyle(startAngle: 180, sweepAngle: 180),
        ),
        width: 360,
      ),
    );
    expect(painter(t).w.secondaryScale!.max, 145);
    expect(find.textContaining('psi'), findsOneWidget);
    expect(t.takeException(), isNull);
    await t.pumpWidget(
      host(const RadialGauge(value: 50, style: GaugeStyle(sweepAngle: 0))),
    );
    expect(t.takeException(), isArgumentError);
  });
  testWidgets('vertical layouts and states remain legible at enlarged text', (
    t,
  ) async {
    final semantics = t.ensureSemantics();
    await t.pumpWidget(
      host(
        const PumpIndicator(
          state: EquipmentState.fault,
          style: EquipmentStyle(showState: false),
        ),
      ),
    );
    expect(find.bySemanticsLabel(RegExp('fault')), findsOneWidget);
    for (final value in [null, 0.0, 100.0]) {
      await t.pumpWidget(
        host(
          Column(
            children: [
              LinearScale(value: value, orientation: Axis.vertical),
              PositionIndicator(value: value, orientation: Axis.vertical),
              RangeIndicator(value: value, orientation: Axis.vertical),
              BatteryIndicator(value: value, orientation: Axis.vertical),
              SegmentedMeter(value: value, orientation: Axis.vertical),
            ],
          ),
          width: 180,
          scale: 2,
        ),
      );
      expect(t.takeException(), isNull);
    }
    semantics.dispose();
  });
  testWidgets('contact states are textual, including unknown', (t) async {
    final semantics = t.ensureSemantics();
    for (final closed in [true, false, null]) {
      await t.pumpWidget(
        host(ContactIndicator(closed: closed, label: 'Limit')),
      );
      expect(
        find.bySemanticsLabel(
          'Limit. ${closed == null
              ? 'Unknown'
              : closed
              ? 'Closed'
              : 'Open'}',
        ),
        findsOneWidget,
      );
    }
    semantics.dispose();
  });
  testWidgets('long signed readings and units wrap without shrinking', (
    t,
  ) async {
    await t.pumpWidget(
      host(
        Column(
          children: [
            const DigitalReadout(
              value: -123456789.1234,
              precision: 4,
              unit: 'micrometres per second',
              presentation: ReadoutPresentation.sevenSegment,
            ),
            ThreePhaseReadout(
              values: [-123456789, null, -12],
              labels: ['Phase one', 'Phase two', 'Phase three'],
              unit: 'kV',
            ),
          ],
        ),
        width: 180,
        scale: 2,
      ),
    );
    expect(t.takeException(), isNull);
  });
  test('invalid normalized pipe geometry is rejected', () {
    expect(() => PipeFlow(path: const [Offset(0, 0)]), throwsArgumentError);
    expect(
      () => PipeFlow(path: const [Offset(0, 0), Offset(2, 0)]),
      throwsArgumentError,
    );
  });
}
