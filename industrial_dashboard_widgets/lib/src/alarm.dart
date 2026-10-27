import 'package:flutter/material.dart';
import 'common.dart';
import 'models.dart';
import 'theme.dart';

/// Process-alarm severity, always presented with text and an icon.
enum AlarmSeverity {
  /// Operational information.
  information,

  /// Requires attention.
  warning,

  /// Requires urgent attention.
  critical,
}

/// Alarm lifecycle. Acknowledged alarms remain active until externally cleared.
enum AlarmState {
  /// Active and not yet acknowledged.
  active,

  /// Active but acknowledged by an operator.
  acknowledged,

  /// Cleared by the application's process logic.
  cleared,
}

/// Immutable process-alarm presentation model.
@immutable
class IndustrialAlarm {
  /// Creates an alarm; state is owned by the application.
  const IndustrialAlarm({
    required this.title,
    required this.message,
    required this.timestamp,
    this.severity = AlarmSeverity.warning,
    this.state = AlarmState.active,
    this.source,
  });

  /// Concise description.
  final String title;

  /// Operator context.
  final String message;

  /// Alarm occurrence time, preserved in its original timezone.
  final DateTime timestamp;

  /// Severity independent of acknowledgement.
  final AlarmSeverity severity;

  /// Lifecycle state.
  final AlarmState state;

  /// Device or subsystem name.
  final String? source;
}

/// Controlled alarm banner. Callbacks request actions; they never mutate alarms.
class IndustrialAlarmBanner extends StatelessWidget {
  /// Creates a banner. Dismissal requires both allowDismiss and onDismiss.
  const IndustrialAlarmBanner({
    super.key,
    required this.alarm,
    this.onAcknowledge,
    this.allowDismiss = false,
    this.onDismiss,
    this.timestampFormatter,
    this.theme,
  });

  /// Alarm to display.
  final IndustrialAlarm alarm;

  /// Invoked only for an active, unacknowledged alarm. Does not clear it.
  final VoidCallback? onAcknowledge;

  /// Explicit opt-in to presentation dismissal; does not clear process state.
  final bool allowDismiss;

  /// Called when the user requests dismissal.
  final VoidCallback? onDismiss;

  /// Formats occurrence time. Defaults to ISO-8601 (including UTC Z if present).
  final TimestampFormatter? timestampFormatter;

  /// Local design tokens.
  final IndustrialTheme? theme;
  @override
  Widget build(BuildContext context) {
    final t = theme ?? IndustrialTheme.of(context);
    final color = switch (alarm.severity) {
      AlarmSeverity.information => t.accent,
      AlarmSeverity.warning => t.warning,
      AlarmSeverity.critical => t.critical,
    };
    final icon = switch (alarm.severity) {
      AlarmSeverity.information => Icons.info_outline,
      AlarmSeverity.warning => Icons.warning_amber_rounded,
      AlarmSeverity.critical => Icons.error_outline,
    };
    final state = switch (alarm.state) {
      AlarmState.active => 'Active · Unacknowledged',
      AlarmState.acknowledged => 'Active · Acknowledged',
      AlarmState.cleared => 'Cleared',
    };
    return InstrumentPanel(
      theme: t.copyWith(border: color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(icon, color: color),
              Text(
                alarm.severity.name.toUpperCase(),
                style: TextStyle(color: color),
              ),
              Text(state),
            ],
          ),
          const SizedBox(height: 8),
          Text(alarm.title, style: t.labelStyle.copyWith(fontSize: 17)),
          const SizedBox(height: 4),
          Text(alarm.message),
          const SizedBox(height: 8),
          Text(
            [
              if (alarm.source != null) alarm.source!,
              timestampFormatter?.call(alarm.timestamp) ??
                  alarm.timestamp.toIso8601String(),
            ].join(' · '),
            style: TextStyle(color: t.muted, fontSize: 12),
          ),
          if ((alarm.state == AlarmState.active && onAcknowledge != null) ||
              (allowDismiss && onDismiss != null))
            Wrap(
              spacing: 8,
              children: [
                if (alarm.state == AlarmState.active && onAcknowledge != null)
                  TextButton.icon(
                    onPressed: onAcknowledge,
                    icon: const Icon(Icons.check),
                    label: const Text('Acknowledge'),
                  ),
                if (allowDismiss && onDismiss != null)
                  TextButton(
                    onPressed: onDismiss,
                    child: const Text('Dismiss'),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
