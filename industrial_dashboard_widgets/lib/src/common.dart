// Internal shared widgets, deliberately not exported.
// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';
import 'models.dart';
import 'theme.dart';

class InstrumentPanel extends StatelessWidget {
  const InstrumentPanel({super.key, required this.theme, required this.child});
  final IndustrialTheme theme;
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: theme.surface,
      borderRadius: BorderRadius.circular(theme.radius),
      border: Border.all(color: theme.border, width: theme.borderWidth),
    ),
    child: Padding(
      padding: EdgeInsets.all(theme.padding),
      child: DefaultTextStyle(
        style: theme.labelStyle.copyWith(color: theme.foreground),
        child: child,
      ),
    ),
  );
}

class ReadingStatus extends StatelessWidget {
  const ReadingStatus({
    super.key,
    required this.reading,
    required this.theme,
    this.range,
  });
  final IndustrialReading reading;
  final IndustrialTheme theme;
  final IndustrialRange? range;
  @override
  Widget build(BuildContext context) {
    final text = [
      reading.status,
      if (reading.hasValue && range != null && !range!.contains(reading.value!))
        'Out of range',
    ].where((e) => e.isNotEmpty).join(' · ');
    return text.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              theme.text('ⓘ $text'),
              style: theme.labelStyle.copyWith(color: theme.warning),
            ),
          );
  }
}

Duration motionDuration(BuildContext context, IndustrialMotion motion) {
  if (motion.duration.isNegative) {
    throw ArgumentError('Animation duration cannot be negative.');
  }
  return MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : motion.duration;
}

String readingSemantics(
  String label,
  IndustrialReading reading,
  String unit,
  ValueFormatter? formatter,
  IndustrialRange? range,
) => [
  '$label: ${reading.format(formatter)} $unit'.trim(),
  if (reading.status.isNotEmpty) reading.status,
  if (reading.hasValue && range != null && !range.contains(reading.value!))
    'Out of range',
].join('. ');
