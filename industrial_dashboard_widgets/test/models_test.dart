import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:industrial_dashboard_widgets/industrial_dashboard_widgets.dart';

void main() {
  test(
    'range validates configuration at runtime and preserves negative values',
    () {
      for (final pair in [
        [0.0, 0.0],
        [1.0, -1.0],
        [double.nan, 2.0],
        [0.0, double.infinity],
        [-1e308, 1e308],
      ]) {
        expect(() => IndustrialRange(pair[0], pair[1]), throwsArgumentError);
      }
      final range = IndustrialRange(-10, 10);
      expect(range.fraction(-20), 0);
      expect(range.fraction(0), .5);
      expect(range.fraction(20), 1);
      expect(range.contains(-10), isTrue);
      expect(range.contains(10), isTrue);
      expect(const IndustrialReading(-20).format(), '-20.0');
    },
  );
  test('missing and nonfinite data never format as healthy zero', () {
    for (final value in [
      null,
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      final r = IndustrialReading(value);
      expect(r.hasValue, isFalse);
      expect(r.format((_) => throw StateError('must not format')), '—');
      expect(r.status, contains('No data'));
    }
    expect(const IndustrialReading(0).hasValue, isTrue);
    const r = IndustrialReading(
      2,
      quality: MeasurementQuality.uncertain,
      freshness: ReadingFreshness.stale,
      connection: ConnectionStatus.disconnected,
    );
    expect(r.status, contains('uncertain'));
    expect(r.status, contains('Stale'));
    expect(r.status, contains('disconnected'));
  });
  const series = [
    TrendSeries(id: 'a', name: 'A', color: Colors.teal),
    TrendSeries(id: 'b', name: 'B', color: Colors.amber),
  ];
  final epoch = DateTime.utc(2026);
  TrendPoint point(int seconds, double? value) =>
      TrendPoint(epoch.add(Duration(seconds: seconds)), value);
  test(
    'ordering, duplicate instants, immutable snapshots and atomic validation',
    () {
      final c = IndustrialTrendController(series: series);
      addTearDown(c.dispose);
      var notifications = 0;
      c.addListener(() => notifications++);
      c.addAll([
        TrendUpdate('a', point(3, 3)),
        TrendUpdate('a', point(1, 1)),
        TrendUpdate('a', point(2, 2)),
      ]);
      expect(notifications, 1);
      expect(c.points('a').map((e) => e.value), [1, 2, 3]);
      c.add('a', TrendPoint(point(2, 0).timestamp.toLocal(), 9));
      expect(c.points('a').map((e) => e.value), [1, 9, 3]);
      expect(() => c.points('a').clear(), throwsUnsupportedError);
      expect(
        () => c.addAll([
          TrendUpdate('a', point(4, 4)),
          TrendUpdate('unknown', point(5, 5)),
        ]),
        throwsArgumentError,
      );
      expect(c.points('a').length, 3);
    },
  );
  test(
    'global event-time retention, hard capacity, late samples and clear',
    () {
      final c = IndustrialTrendController(
        series: series,
        retention: const Duration(seconds: 10),
        maxPointsPerSeries: 3,
      );
      addTearDown(c.dispose);
      for (var i = 0; i < 8; i++) {
        c.add('a', point(i, i.toDouble()));
      }
      expect(c.points('a').map((e) => e.value), [5, 6, 7]);
      c.add('b', point(17, null));
      expect(c.points('a').single.value, 7);
      c.add('a', point(1, 99));
      expect(c.points('a').length, 1);
      c.add('b', point(18, double.nan));
      expect(c.points('a'), isEmpty);
      c.clear();
      expect(c.latestTimestamp, isNull);
      expect(c.points('b'), isEmpty);
    },
  );
  test(
    'controller rejects invalid config and cancels stream on disposal',
    () async {
      expect(() => IndustrialTrendController(series: []), throwsArgumentError);
      expect(
        () => IndustrialTrendController(series: [series.first, series.first]),
        throwsArgumentError,
      );
      expect(
        () =>
            IndustrialTrendController(series: series, retention: Duration.zero),
        throwsArgumentError,
      );
      expect(
        () => IndustrialTrendController(series: series, maxPointsPerSeries: 1),
        throwsArgumentError,
      );
      var canceled = false;
      final stream = StreamController<TrendUpdate>(
        onCancel: () => canceled = true,
      );
      final c = IndustrialTrendController(series: series);
      c.bind(stream.stream);
      stream.add(TrendUpdate('a', point(0, 4)));
      await Future<void>.delayed(Duration.zero);
      expect(c.points('a').single.value, 4);
      c.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(canceled, isTrue);
      expect(c.isDisposed, isTrue);
      expect(() => c.add('a', point(1, 2)), throwsStateError);
      await stream.close();
    },
  );
}
