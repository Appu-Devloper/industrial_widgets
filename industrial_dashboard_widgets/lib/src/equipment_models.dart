import 'package:flutter/material.dart';

/// Observed equipment condition, independent of connection and commands.
enum EquipmentState {
  /// Confirmed operation.
  running,
  /// Available but not producing.
  idle,
  /// Confirmed stopped.
  stopped,
  /// Observed fault.
  fault,
  /// No reliable observation.
  unavailable,
}

/// Physical motion direction. Does not automatically reverse in RTL layouts.
enum FlowDirection {
  /// Along the configured path, or clockwise.
  forward,
  /// Against the configured path, or counterclockwise.
  reverse,
}

/// Observed or requested valve position; these are separate widget inputs.
enum ValvePosition {
  /// Fully open.
  open,
  /// Fully closed.
  closed,
  /// Between endpoints.
  intermediate,
  /// Not known.
  unknown,
  /// Position fault.
  fault,
}

/// Application-owned command lifecycle; never inferred by a widget.
enum CommandStatus {
  /// No current request.
  none,
  /// Awaiting confirmation.
  pending,
  /// Request refused or failed.
  rejected,
  /// Application confirmed the request. Observation is still a separate input.
  confirmed,
}

/// Named custom state used by indicators and state timelines.
@immutable
class IndustrialState {
  /// Creates a stable state identity with explicit text and color.
  const IndustrialState({required this.id, required this.label, required this.color, this.icon = Icons.circle});
  /// Stable identity, not a translated label.
  final String id;
  /// Application-localized name.
  final String label;
  /// State color.
  final Color color;
  /// Non-color visual cue.
  final IconData icon;
}

/// Connection ports relative to an equipment drawing, not the surrounding card.
/// Multiply by the drawing size to compose application-owned process layouts.
abstract final class EquipmentAnchors {
  /// Left-center port.
  static const inlet = Offset(0, .5);
  /// Right-center port.
  static const outlet = Offset(1, .5);
  /// Top-center port.
  static const top = Offset(.5, 0);
  /// Bottom-center port.
  static const bottom = Offset(.5, 1);
  /// Converts a normalized anchor to local pixels in a drawing rectangle.
  static Offset resolve(Rect drawing, Offset anchor) => Offset(drawing.left + drawing.width * anchor.dx, drawing.top + drawing.height * anchor.dy);
}
