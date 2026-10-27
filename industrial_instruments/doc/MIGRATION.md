# Migrating from 0.1.0 to 0.2.0

0.1.0 is already published and remains available. 0.2.0 is a breaking update focused on measurement and equipment instruments.

| 0.1.0 API | 0.2.0 action |
|---|---|
| ArcGauge | Rename to ArcMeter |
| LinearMeter | Rename to LinearScale |
| SiloLevel | Rename to SiloIndicator |
| FlowPipe | Rename to PipeFlow |
| BatteryIndicator(charging: true) | Use activity: BatteryActivity.charging |
| Sparkline, TrendChart | Removed; use a separate chart package if your application needs historical data |
| ChartPoint, ChartSeries, ChartStyle, normalizeChartPoints | Removed with the chart API |
| BulletGraph | Removed; RangeIndicator displays a current position and target, but is not a drop-in qualitative bullet graph |

The default appearance remains Precision, with transparent surroundings and host typography. Existing Instrument appearance settings remain available for existing silhouettes; no new appearance variants were introduced. The catalog focuses on the default appearance in light and dark backgrounds.

Level rulers now show configured engineering values. A HorizontalTank using explicit volume mapping instead labels its ruler with height percentages. Do not label a height-based instrument with volume units unless the application supplies the corresponding mapping.

Additional APIs include the parameter presets, three-phase readout, pressure conventions, caller-supplied secondary dial scale, configurable radial sweep, centered deviation and zero meters, horizontal vessel, sight glass, probe, flow/speed/position/angle instruments, frequency readout and contact symbol.

No telemetry, networking, calculations or equipment-control commands have moved into the package. Keep those responsibilities in the host application.
