# Sizing and behavior

## Supported sizes

Widths below the documented minimum are unsupported. Prefer loose vertical constraints: `height` means drawing height and excludes numeric readings, names, units and state captions. Text may wrap and add height. Do not put an entire instrument into a fixed-height container that reserves space only for its drawing.

| Instrument | Minimum width | Minimum plot height / layout |
|---|---:|---|
| RadialGauge | 180 | 140 |
| ArcMeter | 180 | 140 |
| LinearScale | 180 | 64 horizontal / 140 vertical |
| SegmentedMeter | 180 | 64 horizontal / 140 vertical |
| DigitalReadout | 180 | Intrinsic text height |
| DeviationIndicator | 180 | 72 |
| RangeIndicator | 180 | 72 horizontal / 140 vertical |
| Thermometer | 180 | 140 |
| TemperatureProbe | 180 | 140 |
| PressureDial | 180 | 140; use width 260+ for secondary numerals |
| DifferentialPressureIndicator | 180 | 72, plus port labels |
| VacuumGauge | 180 | 140, plus pressure-convention caption |
| LiquidTank | 180 | 140 |
| CylindricalTank | 180 | 140 |
| HorizontalTank | 180 | 120 |
| SiloIndicator | 180 | 140 |
| LevelTube | 180 | 140 |
| FlowIndicator | 180 | 64 |
| PipeFlow | 180 | 64 |
| RotationIndicator | 180 | 140 |
| PositionIndicator | 180 | 72 horizontal / 140 vertical |
| AngleIndicator | 180 | 140 |
| BatteryIndicator | 180 | 100 horizontal / 140 vertical |
| ThreePhaseReadout | 180 | Intrinsic rows, expands for wrapped text |
| CenterZeroMeter | 180 | 72 |
| FrequencyMeter | 180 | Intrinsic readout; 72 plot when scale is configured |
| PumpIndicator | 180 | 100 |
| MotorIndicator | 180 | 100 |
| ValveIndicator | 180 | 100 |
| FanIndicator | 180 | 100 |
| ConveyorIndicator | 180 | 100 |
| StateLight | 12px lamp | Intrinsic wrapped lamp/text; default lamp 18px |
| ContactIndicator | 180 | 64 |

Recommended widths are 240–360. Under unbounded horizontal constraints most widgets choose 240, ThreePhaseReadout chooses 320, and StateLight wraps to its contents. Explicit widths remain subject to parent constraints. Defaults are 72 for horizontal scales, 180 for vertical scales, 140 for equipment, and `min(240, width × .86)` for upright instruments. FlowIndicator and ContactIndicator default to 80, PipeFlow to 100, and HorizontalTank to 140.

Main text follows the host text scaler. Optional painted scale numerals disappear above 1.3×; small dials omit minor ticks. ThreePhaseReadout stacks labels at compact widths or enlarged text. Seven-segment text falls back to ordinary typography for long/custom strings or above 1.3× text scale. No essential value is scaled down to make it fit. Main text uses tabular figures where the host font supports them.

## Data meaning

Null, NaN and either infinity mean missing. Positions clamp to the configured range while original actual values remain visible. Out-of-range and missing states have text and semantics, including when another descriptive caption is present.

Bounds must be finite, ordered, and have a finite positive span. Targets and references must be finite. Invalid configuration throws ArgumentError. DeviationIndicator bounds must be symmetric about its reference. CenterZeroMeter takes a positive extent and uses ±extent. DifferentialPressureIndicator permits symmetric, asymmetric or unidirectional ranges with its reference inside the range.

Vessel fills describe liquid/material **height**. LiquidTank, CylindricalTank, SiloIndicator and LevelTube do not calculate volume. HorizontalTank can display volume only when the application also supplies a finite heightFraction in [0, 1]. The application owns that mapping, including calibration and vessel shape. Missing readings still show an empty/unavailable illustration, even if a height fraction is supplied.

VacuumGauge requires PressureConvention.gauge (relative to atmosphere) or PressureConvention.absolute (relative to vacuum). Absolute scale bounds cannot start below zero. The actual supplied value is never converted or replaced. PressureDial's SecondaryScale supplies separately configured endpoints aligned linearly with the primary scale; no pressure-unit lookup or actual-value conversion occurs. At small sizes the outer numerals are hidden and an explicit secondary-range/unit caption remains.

AngleIndicator takes degrees, a reference direction measured clockwise from the rightward axis, and a direction. It shows the supplied finite value without modulo-wrapping the reading. RotationIndicator and MotorIndicator display supplied speed; decorative rotation is not an RPM simulation. Leading/lagging and import/export conventions belong to the application.

## Motion, semantics and lifecycle

Value transitions interpolate from the current visual position when interrupted. Decorative animation requires animate, a suitable observed state, enabled TickerMode, and no reduced-motion request. Stopped equipment remains static. No timer or subscription is owned by package widgets. Controllers are disposed with their widget. The gallery's optional deterministic simulation timer is separate and is canceled on disposal.

Semantics expose actual readings, units, configured targets, named bands, missing/out-of-range status and observed equipment state. Three phase values have individual semantics. State and contact labels do not depend on color. Painted internals are excluded from redundant descriptions.

Idle instruments do not schedule repaint loops; parent rebuilds may still repaint. No universal frame-rate, widget-capacity or memory claim is made. Applications own telemetry rates, history and buffering; the core package contains no charts or history retention.
