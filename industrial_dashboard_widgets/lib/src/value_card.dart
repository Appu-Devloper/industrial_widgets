import 'package:flutter/material.dart';
import 'common.dart';
import 'models.dart';
import 'theme.dart';

/// Compact controlled measurement card with explicit data status.
class IndustrialValueCard extends StatelessWidget {
  /// Creates a card. Targets must be finite.
  IndustrialValueCard({
    super.key,
    required this.label,
    required this.reading,
    this.unit = '',
    this.icon,
    this.formatter,
    this.target,
    this.range,
    this.secondaryText,
    this.theme,
  }) {
    if (target != null && !target!.isFinite) {
      throw ArgumentError('Target must be finite.');
    }
  }

  /// Measurement name.
  final String label;

  /// Current value and quality.
  final IndustrialReading reading;

  /// Engineering unit.
  final String unit;

  /// Optional decorative icon.
  final IconData? icon;

  /// Formats finite values.
  final ValueFormatter? formatter;

  /// Application-supplied target.
  final double? target;

  /// Optional operating range.
  final IndustrialRange? range;

  /// Application-supplied trend or context; no trend is inferred.
  final String? secondaryText;

  /// Local token override.
  final IndustrialTheme? theme;
  @override
  Widget build(BuildContext context) {
    final t = theme ?? IndustrialTheme.of(context);
    return InstrumentPanel(
      theme: t,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (icon != null) Icon(icon, size: 19, color: t.accent),
              Text(label, style: t.labelStyle.copyWith(color: t.muted)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${reading.format(formatter)} $unit',
            style: t.valueStyle.copyWith(color: t.foreground),
          ),
          if (target != null)
            Text('Target ${formatter?.call(target!) ?? target} $unit'),
          if (range != null) Text('Range ${range!.min}–${range!.max} $unit'),
          if (secondaryText != null)
            Text(secondaryText!, style: TextStyle(color: t.muted)),
          ReadingStatus(reading: reading, theme: t, range: range),
        ],
      ),
    );
  }
}
