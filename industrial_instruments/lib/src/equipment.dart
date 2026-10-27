import 'package:flutter/material.dart';
import 'models.dart';
import 'styles.dart';
import 'rendering.dart';

/// Recognizable pump with application-supplied observed state.
class PumpIndicator extends StatelessWidget {
  /// Creates a static pump by default. Running never implies a machine command.
  const PumpIndicator({
    super.key,
    this.state = EquipmentState.stopped,
    this.label = '',
    this.direction = FlowDirection.forward,
    this.style = const EquipmentStyle(),
    this.width,
    this.height,
    this.animate = false,
  });

  /// Actual observed operating state.
  final EquipmentState state;

  /// Accessible name and optional visible label.
  final String label;

  /// Physical rotation direction.
  final FlowDirection direction;

  /// Local silhouette and motion styling.
  final EquipmentStyle style;

  /// Optional width; defaults to 240 when unbounded.
  final double? width;

  /// Optional plot height; defaults to 140.
  final double? height;

  /// Runs restrained motion only while running and motion is permitted.
  final bool animate;
  @override
  Widget build(BuildContext context) => InstrumentBody(
    shape: Shape.pump,
    style: style,
    state: state,
    label: label,
    direction: direction,
    width: width,
    height: height,
    animate: animate,
    showValue: false,
    caption: style.showState ? null : '',
  );
}

/// Motor silhouette with application-supplied observed state.
class MotorIndicator extends StatelessWidget {
  /// Creates a static symbol by default. Running never implies a machine command.
  const MotorIndicator({
    super.key,
    this.value,
    this.unit = 'rpm',
    this.showSpeed = false,
    this.state = EquipmentState.stopped,
    this.label = '',
    this.direction = FlowDirection.forward,
    this.style = const EquipmentStyle(),
    this.width,
    this.height,
    this.animate = false,
  });

  /// Optional observed shaft speed; not used to infer operating state.
  final double? value;

  /// Engineering speed unit, without conversion.
  final String unit;

  /// Show speed even when missing, alongside the observed-state caption.
  final bool showSpeed;

  /// Actual observed operating state.
  final EquipmentState state;

  /// Accessible name and optional visible label.
  final String label;

  /// Physical rotation direction.
  final FlowDirection direction;

  /// Local silhouette and motion styling.
  final EquipmentStyle style;

  /// Optional width; defaults to 240 when unbounded.
  final double? width;

  /// Optional plot height; defaults to 140.
  final double? height;

  /// Runs restrained motion only while running and motion is permitted.
  final bool animate;
  @override
  Widget build(BuildContext context) => InstrumentBody(
    shape: Shape.motor,
    value: value,
    unit: unit,
    max: double.maxFinite,
    style: style,
    state: state,
    label: label,
    direction: direction,
    width: width,
    height: height,
    animate: animate,
    showValue: showSpeed,
    caption: style.showState ? '${state.name} · ${direction.name}' : '',
  );
}

/// Fan silhouette with application-supplied observed state.
class FanIndicator extends StatelessWidget {
  /// Creates a static symbol by default. Running never implies a machine command.
  const FanIndicator({
    super.key,
    this.state = EquipmentState.stopped,
    this.label = '',
    this.direction = FlowDirection.forward,
    this.style = const EquipmentStyle(),
    this.width,
    this.height,
    this.animate = false,
  });

  /// Actual observed operating state.
  final EquipmentState state;

  /// Accessible name and optional visible label.
  final String label;

  /// Physical rotation direction.
  final FlowDirection direction;

  /// Local silhouette and motion styling.
  final EquipmentStyle style;

  /// Optional width; defaults to 240 when unbounded.
  final double? width;

  /// Optional plot height; defaults to 140.
  final double? height;

  /// Runs restrained motion only while running and motion is permitted.
  final bool animate;
  @override
  Widget build(BuildContext context) => InstrumentBody(
    shape: Shape.fan,
    style: style,
    state: state,
    label: label,
    direction: direction,
    width: width,
    height: height,
    animate: animate,
    showValue: false,
    caption: style.showState ? null : '',
  );
}

/// Conveyor silhouette with application-supplied observed state.
class ConveyorIndicator extends StatelessWidget {
  /// Creates a static symbol by default. Running never implies a machine command.
  const ConveyorIndicator({
    super.key,
    this.state = EquipmentState.stopped,
    this.label = '',
    this.direction = FlowDirection.forward,
    this.style = const EquipmentStyle(),
    this.width,
    this.height,
    this.animate = false,
  });

  /// Actual observed operating state.
  final EquipmentState state;

  /// Accessible name and optional visible label.
  final String label;

  /// Physical rotation direction.
  final FlowDirection direction;

  /// Local silhouette and motion styling.
  final EquipmentStyle style;

  /// Optional width; defaults to 240 when unbounded.
  final double? width;

  /// Optional plot height; defaults to 140.
  final double? height;

  /// Runs restrained motion only while running and motion is permitted.
  final bool animate;
  @override
  Widget build(BuildContext context) => InstrumentBody(
    shape: Shape.conveyor,
    style: style,
    state: state,
    label: label,
    direction: direction,
    width: width,
    height: height,
    animate: animate,
    showValue: false,
    caption: style.showState ? null : '',
  );
}

/// Presentational valve with observed state only. It emits no machine commands.
class ValveIndicator extends StatelessWidget {
  /// Opening percentage is used only for an intermediate observed position.
  const ValveIndicator({
    super.key,
    required this.position,
    this.openingPercent = 50,
    this.label = '',
    this.style = const EquipmentStyle(),
    this.width,
    this.height,
    this.animate = false,
  });

  /// Confirmed physical position, never a command intent.
  final ValvePosition position;

  /// Observed opening for intermediate state, finite and in [0,100].
  final double openingPercent;

  /// Optional equipment name.
  final String label;

  /// Local visual styling.
  final EquipmentStyle style;

  /// Optional logical width; unbounded default is 240.
  final double? width;

  /// Optional plot height; default 140.
  final double? height;

  /// Smooths intermediate position changes, respecting reduced motion.
  final bool animate;
  @override
  Widget build(BuildContext context) {
    if (!openingPercent.isFinite ||
        openingPercent < 0 ||
        openingPercent > 100) {
      throw ArgumentError('Opening must be 0–100 percent.');
    }
    return InstrumentBody(
      shape: Shape.valve,
      style: style,
      value: position == ValvePosition.unknown
          ? null
          : position == ValvePosition.open
          ? 100
          : position == ValvePosition.closed
          ? 0
          : openingPercent,
      position: position,
      state: position == ValvePosition.unknown
          ? EquipmentState.unknown
          : EquipmentState.stopped,
      label: label,
      width: width,
      height: height,
      animate: animate,
      showValue: false,
      caption: style.showState
          ? '${position.name}${position == ValvePosition.intermediate ? ' · ${openingPercent.toStringAsFixed(0)}% open' : ''}'
          : '',
    );
  }
}

/// Normalized polyline pipe with round joins and directional flow.
class PipeFlow extends StatelessWidget {
  /// Copies and validates 2–64 normalized points. Straight and elbow paths work.
  PipeFlow({
    super.key,
    List<Offset> path = const [Offset(0, .5), Offset(1, .5)],
    this.state = EquipmentState.stopped,
    this.direction = FlowDirection.forward,
    this.label = '',
    this.style = const EquipmentStyle(),
    this.width,
    this.height = 100,
    this.animate = false,
  }) : path = List.unmodifiable(path) {
    if (path.length < 2 ||
        path.length > 64 ||
        path.any(
          (p) =>
              !p.dx.isFinite ||
              !p.dy.isFinite ||
              p.dx < 0 ||
              p.dx > 1 ||
              p.dy < 0 ||
              p.dy > 1,
        ) ||
        path.every((p) => p == path.first)) {
      throw ArgumentError(
        'Pipe requires 2–64 normalized points and a nonzero path.',
      );
    }
  }

  /// Local normalized path. Adjacent segments share one painted join.
  final List<Offset> path;

  /// Observed flow operating state, independent of network connectivity.
  final EquipmentState state;

  /// Direction along or against the supplied path.
  final FlowDirection direction;

  /// Optional pipe name.
  final String label;

  /// Stroke and animation styling.
  final EquipmentStyle style;

  /// Optional logical width; unbounded default 240.
  final double? width;

  /// Plot height; default 100.
  final double height;

  /// Moves arrows only while running and motion is allowed.
  final bool animate;
  @override
  Widget build(BuildContext context) => InstrumentBody(
    shape: Shape.pipe,
    style: style,
    state: state,
    label: label,
    path: path,
    direction: direction,
    width: width,
    height: height,
    animate: animate,
    showValue: false,
    caption: style.showState ? '${state.name} · ${direction.name}' : '',
  );
}
