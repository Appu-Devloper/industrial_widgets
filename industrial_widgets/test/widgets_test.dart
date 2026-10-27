import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:industrial_widgets/industrial_widgets.dart';

Widget host(
  Widget child, {
  bool dark = true,
  bool reduced = true,
  double scale = 1,
  double width = 300,
}) => MaterialApp(
  theme: ThemeData(
    brightness: dark ? Brightness.dark : Brightness.light,
    extensions: [dark ? IndustrialTheme.dark : IndustrialTheme.light],
  ),
  home: MediaQuery(
    data: MediaQueryData(
      disableAnimations: reduced,
      textScaler: TextScaler.linear(scale),
    ),
    child: Scaffold(
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets(
    'gauge distinguishes missing, negative, out of range and semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();

      for (final value in [
        null,
        double.nan,
        double.infinity,
        -5.0,
        0.0,
        150.0,
      ]) {
        await tester.pumpWidget(
          host(
            IndustrialGauge(
              label: 'Pressure',
              unit: 'bar',
              reading: IndustrialReading(value),
              range: IndustrialRange(-10, 100),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        if (value == null || !value.isFinite) {
          expect(find.text('— bar'), findsOneWidget);
          expect(find.bySemanticsLabel(RegExp('Pressure: —')), findsOneWidget);
        }
        if (value == 150) {
          expect(find.text('150.0 bar'), findsOneWidget);
          expect(find.textContaining('Out of range'), findsOneWidget);
        }
      }
      semantics.dispose();
    },
  );
  testWidgets(
    'all instruments fit narrow widths and large text in both themes',
    (tester) async {
      for (final dark in [false, true]) {
        await tester.pumpWidget(
          host(
            Column(
              children: [
                IndustrialGauge(
                  label: 'Motor speed',
                  reading: const IndustrialReading(100),
                  range: IndustrialRange(0, 200),
                  unit: 'rpm',
                ),
                IndustrialTank(
                  label: 'Water',
                  reading: const IndustrialReading(
                    null,
                    freshness: ReadingFreshness.stale,
                  ),
                  range: IndustrialRange(0, 100),
                ),
                IndustrialTank(
                  label: 'Horizontal',
                  reading: const IndustrialReading(100),
                  range: IndustrialRange(0, 100),
                  style: const TankStyle(orientation: Axis.horizontal),
                ),
                IndustrialValueCard(
                  label: 'Power',
                  unit: 'kW',
                  reading: const IndustrialReading(
                    -4,
                    quality: MeasurementQuality.bad,
                    connection: ConnectionStatus.reconnecting,
                  ),
                  secondaryText: 'External trend context',
                ),
                IndustrialAlarmBanner(
                  alarm: IndustrialAlarm(
                    title: 'High pressure',
                    message: 'Inspect filter',
                    timestamp: DateTime.utc(2026),
                  ),
                  onAcknowledge: () {},
                ),
              ],
            ),
            dark: dark,
            width: 200,
            scale: 2,
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    },
  );
  testWidgets('acknowledgement requests do not clear or mutate alarms', (
    tester,
  ) async {
    var acknowledgements = 0, dismissals = 0;
    Widget banner(AlarmState state, {bool allow = false}) => host(
      IndustrialAlarmBanner(
        alarm: IndustrialAlarm(
          title: 'Filter',
          message: 'Inspect',
          timestamp: DateTime.utc(2026),
          state: state,
          severity: AlarmSeverity.critical,
        ),
        onAcknowledge: () => acknowledgements++,
        allowDismiss: allow,
        onDismiss: () => dismissals++,
      ),
    );
    await tester.pumpWidget(banner(AlarmState.active));
    await tester.tap(find.text('Acknowledge'));
    await tester.pump();
    expect(acknowledgements, 1);
    expect(find.text('Active · Unacknowledged'), findsOneWidget);
    expect(find.text('Dismiss'), findsNothing);
    await tester.pumpWidget(banner(AlarmState.acknowledged));
    expect(find.text('Active · Acknowledged'), findsOneWidget);
    expect(find.text('Acknowledge'), findsNothing);
    await tester.pumpWidget(banner(AlarmState.cleared, allow: true));
    expect(find.text('Cleared'), findsOneWidget);
    await tester.tap(find.text('Dismiss'));
    expect(dismissals, 1);
  });
  testWidgets('liquid motion stops with reduced motion and when disabled', (
    tester,
  ) async {
    Widget tank(bool reduced, bool animated) => host(
      IndustrialTank(
        label: 'Tank',
        reading: const IndustrialReading(50),
        range: IndustrialRange(0, 100),
        style: TankStyle(animateLiquid: animated),
      ),
      reduced: reduced,
    );
    await tester.pumpWidget(tank(false, true));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    await tester.pumpWidget(tank(true, true));
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpWidget(tank(false, false));
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'chart handles empty, single point, gaps, keyboard and controller replacement',
    (tester) async {
      final c = IndustrialTrendController(
        series: const [
          TrendSeries(
            id: 't',
            name: 'Temperature',
            unit: '°C',
            color: Colors.teal,
          ),
        ],
      );
      final epoch = DateTime.utc(2026);
      await tester.pumpWidget(
        host(IndustrialTrendChart(controller: c), width: 220, scale: 2),
      );
      expect(find.text('No data'), findsOneWidget);
      c.add('t', TrendPoint(epoch, 10));
      await tester.pump();
      expect(find.text('No data'), findsNothing);
      c.addAll([
        TrendUpdate(
          't',
          TrendPoint(epoch.add(const Duration(seconds: 1)), null),
        ),
        TrendUpdate('t', TrendPoint(epoch.add(const Duration(seconds: 2)), 20)),
      ]);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(find.textContaining('Temperature:'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final other = IndustrialTrendController(
        series: const [TrendSeries(id: 'b', name: 'B', color: Colors.red)],
      );
      await tester.pumpWidget(host(IndustrialTrendChart(controller: other)));
      c.dispose();
      other.add('b', TrendPoint(epoch, 0));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      expect(other.isDisposed, isFalse);
      other.dispose();
    },
  );
  test('invalid widget configurations fail clearly', () {
    expect(
      () => IndustrialGauge(
        label: 'x',
        reading: const IndustrialReading(1),
        range: IndustrialRange(0, 10),
        target: double.nan,
      ),
      throwsArgumentError,
    );
    expect(
      () => IndustrialGauge(
        label: 'x',
        reading: const IndustrialReading(1),
        range: IndustrialRange(0, 10),
        style: const GaugeStyle(majorTicks: 0),
      ),
      throwsArgumentError,
    );
    expect(() => TrendChartStyle(window: Duration.zero), throwsArgumentError);
    expect(() => TrendChartStyle(plotHeight: double.nan), throwsArgumentError);
    expect(
      () =>
          TrendThreshold(value: double.infinity, label: 'x', color: Colors.red),
      throwsArgumentError,
    );
  });
}
