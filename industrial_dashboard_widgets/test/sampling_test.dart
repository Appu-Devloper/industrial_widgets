import 'package:flutter_test/flutter_test.dart';
import 'package:industrial_dashboard_widgets/industrial_dashboard_widgets.dart';
import 'package:industrial_dashboard_widgets/src/trend_sampling.dart';

void main() {
  final epoch = DateTime.utc(2026);
  test('dense downsampling preserves extrema, order, endpoints and gaps', () {
    final points = [
      for (var i = 0; i < 10000; i++)
        TrendPoint(
          epoch.add(Duration(milliseconds: i)),
          i == 5000
              ? null
              : i == 1001
              ? 999
              : i == 1002
              ? -999
              : (i % 10).toDouble(),
        ),
    ];
    final sampled = sampleTrend(
      points,
      100,
      (p) => p.timestamp.difference(epoch).inMilliseconds / 100,
    );
    expect(sampled.length, lessThanOrEqualTo(410));
    expect(sampled.first, same(points.first));
    expect(sampled.last, same(points.last));
    expect(sampled, contains(points[1001]));
    expect(sampled, contains(points[1002]));
    expect(sampled, contains(points[5000]));
    final gap = sampled.indexOf(points[5000]);
    expect(sampled[gap - 1], same(points[4999]));
    expect(sampled[gap + 1], same(points[5001]));
    for (var i = 1; i < sampled.length; i++) {
      expect(sampled[i].timestamp.isAfter(sampled[i - 1].timestamp), isTrue);
    }
  });
  test('short data remains unchanged, nonfinite samples retain gaps', () {
    final points = [
      TrendPoint(epoch, 1),
      TrendPoint(epoch.add(const Duration(seconds: 1)), double.nan),
    ];
    expect(sampleTrend(points, 100, (_) => 0), same(points));
    final dense = [
      for (var i = 0; i < 20; i++)
        TrendPoint(
          epoch.add(Duration(seconds: i)),
          i == 10 ? double.infinity : 1,
        ),
    ];
    expect(sampleTrend(dense, 1, (_) => 0).where((p) => !p.hasValue).length, 1);
  });
}
