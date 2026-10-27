# 0.2.0 completion checklist

- [x] Refine and inspect RadialGauge, Thermometer, CylindricalTank, ThreePhaseReadout and ValveIndicator.
- [x] Implement 33 instruments with shared geometry; remove chart APIs.
- [x] Editable, unit-explicit parameter presets without inferred safe ranges.
- [x] Measurement catalog with range, unit, value, color and animation controls.
- [x] Tests for geometry, data, semantics, resizing and animation lifecycle.
- [x] Review actual renders at compact/large sizes, light/dark and enlarged text.
- [x] Update API examples, sizing/customization/migration guides and recording instructions.
- [x] Formatting, analysis, tests, web build and publishing dry-run.

The owner explicitly authorized publication of this update after reviewing the example location.

Implemented: RadialGauge, ArcMeter, LinearScale, SegmentedMeter, DigitalReadout, DeviationIndicator, RangeIndicator, Thermometer, TemperatureProbe, PressureDial, DifferentialPressureIndicator, VacuumGauge, LiquidTank, CylindricalTank, HorizontalTank, SiloIndicator, LevelTube, FlowIndicator, PipeFlow, RotationIndicator, PositionIndicator, AngleIndicator, BatteryIndicator, ThreePhaseReadout, CenterZeroMeter, FrequencyMeter, PumpIndicator, MotorIndicator, ValveIndicator, FanIndicator, ConveyorIndicator, StateLight, ContactIndicator.

Presets: 50 explicit unit presets plus caller-configured vacuum and power-factor conventions.

See VALIDATION.md for performed checks and explicit limitations.
