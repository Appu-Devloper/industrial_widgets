# Customization

The default Precision appearance is designed for plain light or dark surfaces. Widget surrounds are transparent. Fonts inherit from the host, and local styles do not impose an app theme.

| Style | Controls |
|---|---|
| InstrumentStyle | accent, foreground, muted, surface, strokeWidth, valueStyle, labelStyle, duration |
| GaugeStyle | scale formatting, divisions, minor ticks, labels; radial startAngle/sweepAngle; arc roundCaps; segmented count |
| LevelStyle | upright vessel width, ruler visibility, optional LiquidTank waves |
| EquipmentStyle | decorative cycle duration and visible state caption |

Shared style fields apply where meaningful. A probe has no ticks; a sight glass has a fixed slim body; a horizontal tank has a capsule silhouette. Only dial geometry uses radial angle settings. Existing Instrument appearance construction remains available for earlier silhouettes, but the catalog and new design work prioritize one default family.

```dart
RadialGauge(
  value: 6.4, min: 0, max: 10, unit: 'bar',
  target: 8,
  formatter: (v) => v.toStringAsFixed(2),
  bands: [InstrumentBand(8, 10, Color(0xFFAA7531), label: 'Application range')],
  style: GaugeStyle(
    startAngle: 150, sweepAngle: 240,
    divisions: 5, minorTicks: 3,
    accent: Color(0xFF356D9D),
    valueStyle: TextStyle(fontSize: 36),
    duration: Duration(milliseconds: 400),
  ),
  animate: true,
)
```

Bands are explicit application configuration, not inferred safety classifications. RadialGauge, ArcMeter, LinearScale, SegmentedMeter and PressureDial accept bands. Keep custom scaleFormatter labels short. The main formatter changes only the actual displayed reading, never geometry. Long main values and units wrap at the host text size.

LinearScale, SegmentedMeter, RangeIndicator, PositionIndicator and BatteryIndicator support Axis.vertical. PipeFlow takes 2–64 normalized offsets, joined with a continuous stroked path. It accepts straight, elbow and multi-elbow paths; it does not route around other widgets.

```dart
PressureDial(
  value: 6.4, min: 0, max: 10, unit: 'bar',
  secondaryScale: SecondaryScale(min: 0, max: 145.04, unit: 'psi'),
)

HorizontalTank(
  value: 500, min: 0, max: 1000, unit: 'L',
  quantity: LevelQuantity.volume,
  heightFraction: 0.62, // Application-calculated, not inferred from 500/1000.
)

MotorIndicator(
  value: 1480, unit: 'rpm', showSpeed: true,
  state: EquipmentState.running,
  direction: FlowDirection.reverse,
  animate: true,
)
```

BatteryActivity distinguishes idle, charging, discharging and unknown; showValue can hide the visible number while retaining an accessible reading. EquipmentState never changes merely because a speed or rate becomes nonzero. The application chooses observed state independently of animate.

InstrumentPreset.copyWith edits label, unit, precision and convention. Its convenience methods create the ordinary generic widgets. Dial, linear and tank preset methods require explicit min/max; no preset declares operating ranges. Editing a unit does not convert values.
