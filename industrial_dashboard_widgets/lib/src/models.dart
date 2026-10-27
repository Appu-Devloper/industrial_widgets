import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Confidence in the measurement, independent of transport and age.
enum MeasurementQuality {
  /// Reliable measurement.
  good,

  /// Usable with caution.
  uncertain,

  /// Unreliable measurement.
  bad,
}

/// Age classification supplied by the application; widgets own no age timers.
enum ReadingFreshness {
  /// Within the application's acceptable age.
  fresh,

  /// Older than the application's acceptable age.
  stale,
}

/// Transport status, independent of measurement quality.
enum ConnectionStatus {
  /// Transport is available.
  connected,

  /// Transport is attempting recovery.
  reconnecting,

  /// Transport is unavailable.
  disconnected,
}

/// Formats a finite engineering value. Invalid values never reach this callback.
typedef ValueFormatter = String Function(double value);

/// Formats timestamps. Widgets preserve the original DateTime zone.
typedef TimestampFormatter = String Function(DateTime timestamp);

/// Presentation availability, separate from measurement confidence and transport.
enum DataAvailability {
  /// A response is available, possibly with a missing measurement.
  ready,
  /// Waiting for the application's initial data.
  loading,
  /// Data cannot currently be obtained.
  unavailable,
  /// Application reported a data error.
  error,
}

/// Immutable measurement. Null and non-finite values are missing, never zero.
@immutable
class IndustrialReading {
  /// Creates an externally controlled reading.
  const IndustrialReading(
    this.value, {
    this.timestamp,
    this.availability = DataAvailability.ready,
    this.message,
    this.quality = MeasurementQuality.good,
    this.freshness = ReadingFreshness.fresh,
    this.connection = ConnectionStatus.connected,
  });

  /// Availability of the presentation data.
  final DataAvailability availability;
  /// Optional application-localized loading/error explanation.
  final String? message;

  /// Actual engineering value, preserved even outside a visual range.
  final double? value;

  /// Acquisition time. No timezone conversion or automatic aging is performed.
  final DateTime? timestamp;

  /// Measurement confidence.
  final MeasurementQuality quality;

  /// Application-owned age classification.
  final ReadingFreshness freshness;

  /// Transport status.
  final ConnectionStatus connection;

  /// Whether a finite measurement is present.
  bool get hasValue => availability == DataAvailability.ready && value != null && value!.isFinite;

  /// Human-readable, non-color status description.
  String get status => [
    if (availability != DataAvailability.ready) availability.name,
    if (message != null) message!,
    if (!hasValue && availability == DataAvailability.ready) 'No data',
    if (quality != MeasurementQuality.good) '${quality.name} quality',
    if (freshness == ReadingFreshness.stale) 'Stale',
    if (connection != ConnectionStatus.connected) connection.name,
  ].join(' · ');

  /// Formats the actual value, or an em dash when missing.
  String format([ValueFormatter? formatter]) =>
      hasValue ? (formatter?.call(value!) ?? value!.toStringAsFixed(1)) : '—';
}

/// Validated finite measurement range shared by gauges, tanks and charts.
@immutable
class IndustrialRange {
  /// Throws ArgumentError unless min and max are finite and min < max.
  IndustrialRange(this.min, this.max) {
    if (!min.isFinite || !max.isFinite || min >= max || !(max - min).isFinite) {
      throw ArgumentError('Range requires finite min < max and finite span.');
    }
  }

  /// Lower engineering bound.
  final double min;

  /// Upper engineering bound.
  final double max;

  /// Maps a finite value to a clamped visual fraction.
  double fraction(double value) =>
      ((value - min) / (max - min)).clamp(0.0, 1.0);

  /// Whether a reading falls outside these bounds.
  bool contains(double value) => value.isFinite && value >= min && value <= max;
}

/// Colored operating band in engineering units.
@immutable
class IndustrialBand {
  /// Creates a band; bounds are validated by IndustrialRange.
  const IndustrialBand({
    required this.range,
    required this.color,
    this.label = '',
  });

  /// Inclusive engineering bounds.
  final IndustrialRange range;

  /// Band color.
  final Color color;

  /// Accessible description, such as "High pressure".
  final String label;
}

/// Shared transition settings. Reduced motion always takes priority.
@immutable
class IndustrialMotion {
  /// Creates a transition. Negative duration is rejected by the widgets.
  const IndustrialMotion({
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeOutCubic,
  });

  /// Time to reach a new reading; frequent updates retarget from current position.
  final Duration duration;

  /// Interpolation curve.
  final Curve curve;
}
