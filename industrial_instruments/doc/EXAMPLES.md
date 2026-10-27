# Minimal examples

Widget expressions for use inside a Flutter build method.

```dart
import 'package:flutter/material.dart';
import 'package:industrial_instruments/industrial_instruments.dart';
```

These are explicit demo ranges, not safety recommendations. Edit range, unit and formatting for your application.

## RadialGauge

```dart
RadialGauge(
  value: 6.40,
  min: 0.0, max: 10.0,
  unit: 'bar',
  animate: false,
  style: GaugeStyle(accent: Color(0xff13796e)),
)
```

## ArcMeter

```dart
ArcMeter(
  value: 68.00,
  min: 0.0, max: 100.0,
  unit: '%',
  animate: false,
  style: GaugeStyle(accent: Color(0xff13796e)),
)
```

## LinearScale

```dart
LinearScale(
  value: 320.00,
  min: 0.0, max: 500.0,
  unit: 'mm',
  orientation: Axis.horizontal,
  animate: false,
  style: GaugeStyle(accent: Color(0xff13796e)),
)
```

## SegmentedMeter

```dart
SegmentedMeter(
  value: 68.00,
  min: 0.0, max: 100.0,
  unit: '%',
  orientation: Axis.horizontal,
  animate: false,
  style: GaugeStyle(accent: Color(0xff13796e)),
)
```

## DigitalReadout

```dart
DigitalReadout(
  value: 7.20, unit: 'pH', precision: 2,
  style: InstrumentStyle(accent: Color(0xff13796e)),
)
```

## DeviationIndicator

```dart
DeviationIndicator(
  value: 2.40,
  min: -10.0, max: 10.0,
  unit: 'mm',
  animate: false,
  style: GaugeStyle(accent: Color(0xff13796e)),
)
```

## RangeIndicator

```dart
RangeIndicator(
  value: 680.00,
  min: 0.0, max: 1000.0,
  unit: 'kg',
  orientation: Axis.horizontal,
  animate: false,
  style: GaugeStyle(accent: Color(0xff13796e)),
)
```

## Thermometer

```dart
Thermometer(
  value: 72.00,
  min: -20.0, max: 120.0,
  unit: '°C',
  animate: false,
  style: GaugeStyle(accent: Color(0xff13796e)),
)
```

## TemperatureProbe

```dart
TemperatureProbe(
  value: 72.00,
  min: -20.0, max: 120.0,
  unit: '°C',
  animate: false,
  style: GaugeStyle(accent: Color(0xff13796e)),
)
```

## PressureDial

```dart
PressureDial(
  value: 6.40,
  min: 0.0, max: 10.0,
  unit: 'bar',
  animate: false,
  style: GaugeStyle(accent: Color(0xff13796e)),
)
```

## DifferentialPressureIndicator

```dart
DifferentialPressureIndicator(
  value: 24.00,
  min: -100.0, max: 100.0,
  unit: 'Pa',
  animate: false,
  style: GaugeStyle(accent: Color(0xff13796e)),
)
```

## VacuumGauge

```dart
VacuumGauge(
  value: -65.00,
  min: -100.0, max: 0.0,
  unit: 'kPa',
  convention: PressureConvention.gauge,
  animate: false,
  style: GaugeStyle(accent: Color(0xff13796e)),
)
```

## LiquidTank

```dart
LiquidTank(
  value: 68.00,
  min: 0.0, max: 100.0,
  unit: '%',
  animate: false,
  style: LevelStyle(accent: Color(0xff13796e)),
)
```

## CylindricalTank

```dart
CylindricalTank(
  value: 68.00,
  min: 0.0, max: 100.0,
  unit: '%',
  animate: false,
  style: LevelStyle(accent: Color(0xff13796e)),
)
```

## HorizontalTank

```dart
HorizontalTank(
  value: 68.00,
  min: 0.0, max: 100.0,
  unit: '%',
  animate: false,
  style: LevelStyle(accent: Color(0xff13796e)),
)
```

## SiloIndicator

```dart
SiloIndicator(
  value: 68.00,
  min: 0.0, max: 100.0,
  unit: '%',
  animate: false,
  style: LevelStyle(accent: Color(0xff13796e)),
)
```

## LevelTube

```dart
LevelTube(
  value: 680.00,
  min: 0.0, max: 1000.0,
  unit: 'mm',
  animate: false,
  style: LevelStyle(accent: Color(0xff13796e)),
)
```

## FlowIndicator

```dart
FlowIndicator(
  value: 64.00,
  min: 0.0, max: 100.0,
  unit: 'L/min',
  state: EquipmentState.running, direction: FlowDirection.forward,
  animate: false,
  style: EquipmentStyle(accent: Color(0xff13796e)),
)
```

## PipeFlow

```dart
PipeFlow(
  state: EquipmentState.running,
  direction: FlowDirection.forward,
  path: const [Offset(0, .7), Offset(.3, .7), Offset(.3, .2), Offset(.75, .2), Offset(.75, .7), Offset(1, .7)],
  animate: false,
  style: EquipmentStyle(accent: Color(0xff13796e)),
)
```

## RotationIndicator

```dart
RotationIndicator(
  value: 1480.00,
  min: 0.0, max: 3000.0,
  unit: 'rpm',
  state: EquipmentState.running, direction: FlowDirection.forward,
  animate: false,
  style: EquipmentStyle(accent: Color(0xff13796e)),
)
```

## PositionIndicator

```dart
PositionIndicator(
  value: 320.00,
  min: 0.0, max: 500.0,
  unit: 'mm',
  orientation: Axis.horizontal,
  animate: false,
  style: GaugeStyle(accent: Color(0xff13796e)),
)
```

## AngleIndicator

```dart
AngleIndicator(
  value: 120.00,
  min: 0.0, max: 360.0,
  unit: '°',
  direction: FlowDirection.forward,
  animate: false,
  style: GaugeStyle(accent: Color(0xff13796e)),
)
```

## BatteryIndicator

```dart
BatteryIndicator(
  value: 68.00,
  min: 0.0, max: 100.0,
  unit: '%',
  orientation: Axis.horizontal,
  activity: BatteryActivity.charging,
  animate: false,
  style: LevelStyle(accent: Color(0xff13796e)),
)
```

## ThreePhaseReadout

```dart
ThreePhaseReadout(
  values: [230.20, 231.40, 229.80],
  unit: 'V',
  style: InstrumentStyle(accent: Color(0xff13796e)),
)
```

## CenterZeroMeter

```dart
CenterZeroMeter(
  value: 24.00, extent: 100.0, unit: 'kW',
  animate: false,
  style: GaugeStyle(accent: Color(0xff13796e)),
)
```

## FrequencyMeter

```dart
FrequencyMeter(
  value: 50.02,
  min: 45.0, max: 55.0,
  unit: 'Hz',
  reference: 50,
  animate: false,
  style: GaugeStyle(accent: Color(0xff13796e)),
)
```

## PumpIndicator

```dart
PumpIndicator(
  state: EquipmentState.running,
  direction: FlowDirection.forward,
  animate: false,
  style: EquipmentStyle(accent: Color(0xff13796e)),
)
```

## MotorIndicator

```dart
MotorIndicator(
  state: EquipmentState.running,
  direction: FlowDirection.forward,
  value: 1480.00, unit: 'rpm', showSpeed: true,
  animate: false,
  style: EquipmentStyle(accent: Color(0xff13796e)),
)
```

## ValveIndicator

```dart
ValveIndicator(
  position: ValvePosition.intermediate,
  openingPercent: 65.0,
  animate: false,
  style: EquipmentStyle(accent: Color(0xff13796e)),
)
```

## FanIndicator

```dart
FanIndicator(
  state: EquipmentState.running,
  direction: FlowDirection.forward,
  animate: false,
  style: EquipmentStyle(accent: Color(0xff13796e)),
)
```

## ConveyorIndicator

```dart
ConveyorIndicator(
  state: EquipmentState.running,
  direction: FlowDirection.forward,
  animate: false,
  style: EquipmentStyle(accent: Color(0xff13796e)),
)
```

## StateLight

```dart
StateLight(
  active: true,
  style: InstrumentStyle(accent: Color(0xff13796e)),
)
```

## ContactIndicator

```dart
ContactIndicator(
  closed: true,
  style: InstrumentStyle(accent: Color(0xff13796e)),
)
```

