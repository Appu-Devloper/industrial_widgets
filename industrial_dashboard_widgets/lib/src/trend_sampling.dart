// Internal algorithm, not part of the supported package API.
// ignore_for_file: public_member_api_docs
import 'trend_controller.dart';

// Keep extrema and ordering per pixel bucket, without bridging missing data.
List<TrendPoint> sampleTrend(
  List<TrendPoint> points,
  int width,
  double Function(TrendPoint) x,
) {
  if (points.length <= width * 2) return points;
  final result = <TrendPoint>[], bucket = <TrendPoint>[];
  int? column;
  void flush() {
    if (bucket.isEmpty) return;
    var low = bucket.first, high = bucket.first;
    for (final p in bucket) {
      if (p.value! < low.value!) low = p;
      if (p.value! > high.value!) high = p;
    }
    final chosen = {bucket.first, low, high, bucket.last}.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    result.addAll(chosen);
    bucket.clear();
  }

  for (final p in points) {
    if (!p.hasValue) {
      flush();
      column = null;
      result.add(p);
      continue;
    }
    final next = x(p).floor();
    if (column != next) {
      flush();
      column = next;
    }
    bucket.add(p);
  }
  flush();
  return result;
}
