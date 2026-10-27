import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Immutable sample. Null and non-finite values break chart lines.
@immutable
class TrendPoint {
  /// Creates a sample, comparing timestamps by instant regardless of zone.
  const TrendPoint(this.timestamp, this.value);

  /// Acquisition timestamp.
  final DateTime timestamp;

  /// Actual engineering value, or a gap.
  final double? value;

  /// Whether this sample can be plotted.
  bool get hasValue => value != null && value!.isFinite;
}

/// Stable identity and presentation of a series.
@immutable
class TrendSeries {
  /// Creates a series. IDs must be unique and nonempty in a controller.
  const TrendSeries({
    required this.id,
    required this.name,
    required this.color,
    this.unit = '',
  });

  /// Ingestion key.
  final String id;

  /// Legend label.
  final String name;

  /// Line color.
  final Color color;

  /// Display unit. No conversion is performed on the shared numeric axis.
  final String unit;
}

/// Stream event addressed to a series.
@immutable
class TrendUpdate {
  /// Creates an event.
  const TrendUpdate(this.seriesId, this.point);

  /// Registered series ID.
  final String seriesId;

  /// Sample to ingest.
  final TrendPoint point;
}

/// Bounded, sorted histories, owned and disposed by the application.
///
/// Last arrival wins for duplicate instants. Late samples are sorted. Retention
/// uses the newest timestamp across all series. No age timers are created.
class IndustrialTrendController extends ChangeNotifier {
  /// Requires series, positive retention and capacity at least two.
  IndustrialTrendController({
    required List<TrendSeries> series,
    this.retention = const Duration(minutes: 10),
    this.maxPointsPerSeries = 2000,
  }) : series = List.unmodifiable(series) {
    if (series.isEmpty ||
        retention <= Duration.zero ||
        maxPointsPerSeries < 2) {
      throw ArgumentError(
        'Provide series, positive retention and capacity >= 2.',
      );
    }
    for (final s in series) {
      if (s.id.isEmpty || _data.containsKey(s.id)) {
        throw ArgumentError('IDs must be nonempty and unique.');
      }
      _data[s.id] = [];
    }
  }

  /// Immutable series definitions.
  final List<TrendSeries> series;

  /// Event-time retention relative to global newest timestamp.
  final Duration retention;

  /// Hard point cap per series, including gaps.
  final int maxPointsPerSeries;
  final Map<String, List<TrendPoint>> _data = {};
  final Set<StreamSubscription<TrendUpdate>> _subscriptions = {};
  DateTime? _latest;
  bool _disposed = false;

  /// Newest observed event time.
  DateTime? get latestTimestamp => _latest;

  /// Whether this controller was disposed.
  bool get isDisposed => _disposed;
  void _check() {
    if (_disposed) throw StateError('Controller disposed.');
  }

  /// Immutable snapshot. Unknown IDs throw ArgumentError.
  List<TrendPoint> points(String id) {
    _check();
    if (!_data.containsKey(id)) throw ArgumentError.value(id, 'id');
    return List.unmodifiable(_data[id]!);
  }

  /// Ingests a sample and notifies listeners.
  void add(String id, TrendPoint point) => addAll([TrendUpdate(id, point)]);

  /// Validates a whole batch before mutation, then notifies once.
  void addAll(Iterable<TrendUpdate> updates) {
    _check();
    final batch = updates.toList();
    for (final e in batch) {
      if (!_data.containsKey(e.seriesId)) {
        throw ArgumentError.value(e.seriesId, 'seriesId');
      }
    }
    if (batch.isEmpty) return;
    for (final e in batch) {
      final p = e.point, list = _data[e.seriesId]!;
      if (_latest == null || p.timestamp.isAfter(_latest!)) {
        _latest = p.timestamp;
      }
      var low = 0, high = list.length;
      while (low < high) {
        final mid = (low + high) >> 1;
        if (list[mid].timestamp.isBefore(p.timestamp)) {
          low = mid + 1;
        } else {
          high = mid;
        }
      }
      if (low < list.length &&
          list[low].timestamp.isAtSameMomentAs(p.timestamp)) {
        list[low] = p;
      } else {
        list.insert(low, p);
      }
    }
    final cutoff = _latest!.subtract(retention);
    for (final list in _data.values) {
      var n = 0;
      while (n < list.length && list[n].timestamp.isBefore(cutoff)) {
        n++;
      }
      if (n > 0) list.removeRange(0, n);
      if (list.length > maxPointsPerSeries) {
        list.removeRange(0, list.length - maxPointsPerSeries);
      }
    }
    notifyListeners();
  }

  /// Binds a stream. Caller can cancel early; disposal cancels all bindings.
  /// Upstream errors follow normal zone behavior unless onError is supplied.
  StreamSubscription<TrendUpdate> bind(
    Stream<TrendUpdate> stream, {
    void Function(Object, StackTrace)? onError,
  }) {
    _check();
    late final StreamSubscription<TrendUpdate> subscription;
    subscription = stream.listen(
      (e) {
        if (!_disposed) add(e.seriesId, e.point);
      },
      onError: onError,
      onDone: () => _subscriptions.remove(subscription),
    );
    _subscriptions.add(subscription);
    return subscription;
  }

  /// Resets histories and event time.
  void clear() {
    _check();
    for (final list in _data.values) {
      list.clear();
    }
    _latest = null;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    _subscriptions.clear();
    _data.clear();
    super.dispose();
  }
}
