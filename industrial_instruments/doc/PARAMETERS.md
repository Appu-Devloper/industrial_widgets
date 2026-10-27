# Parameter coverage

All values are supplied by the host application. Editing a preset changes labels and formatting only. It never converts units, calculates physical quantities, defines safe bands, or chooses installation limits.

| Preset | Parameter | Unit | Decimal places |
|---|---|---|---:|
| `temperatureC` | Temperature | °C | 1 |
| `temperatureF` | Temperature | °F | 1 |
| `temperatureK` | Temperature | K | 1 |
| `pressureBar` | Pressure | bar | 2 |
| `pressurePsi` | Pressure | psi | 1 |
| `pressureKpa` | Pressure | kPa | 1 |
| `differentialPressure` | Differential pressure | Pa | 1 |
| `flowLitres` | Flow | L/min | 1 |
| `flowCubicMetres` | Flow | m³/h | 2 |
| `massFlow` | Mass flow | kg/h | 1 |
| `levelPercent` | Liquid height | % | 1 |
| `levelMillimetres` | Liquid height | mm | 1 |
| `levelMetres` | Liquid height | m | 2 |
| `volumeLitres` | Volume | L | 1 |
| `volumeCubicMetres` | Volume | m³ | 2 |
| `massGrams` | Mass | g | 1 |
| `massKilograms` | Mass | kg | 1 |
| `massTonnes` | Mass | t | 2 |
| `force` | Load | N | 1 |
| `speedRpm` | Speed | rpm | 0 |
| `speedMetresMinute` | Speed | m/min | 1 |
| `speedMetresSecond` | Speed | m/s | 2 |
| `torque` | Torque | N·m | 1 |
| `positionMillimetres` | Position | mm | 1 |
| `positionCentimetres` | Position | cm | 2 |
| `positionMetres` | Position | m | 3 |
| `angle` | Angle | ° | 1 |
| `voltage` | Voltage | V | 1 |
| `voltageKv` | Voltage | kV | 2 |
| `currentMa` | Current | mA | 2 |
| `current` | Current | A | 2 |
| `powerWatts` | Power | W | 1 |
| `powerKw` | Power | kW | 2 |
| `powerMw` | Power | MW | 3 |
| `reactivePower` | Reactive power | kvar | 2 |
| `apparentPower` | Apparent power | kVA | 2 |
| `energyWh` | Energy | Wh | 1 |
| `energyKwh` | Energy | kWh | 2 |
| `frequency` | Frequency | Hz | 2 |
| `humidity` | Humidity | %RH | 1 |
| `ph` | pH | dimensionless | 2 |
| `conductivityMicro` | Conductivity | µS/cm | 1 |
| `conductivityMilli` | Conductivity | mS/cm | 2 |
| `dissolvedOxygen` | Dissolved oxygen | mg/L | 2 |
| `turbidity` | Turbidity | NTU | 1 |
| `gasPpm` | Gas concentration | ppm | 1 |
| `gasVolume` | Gas concentration | %vol | 2 |
| `gasLel` | Gas concentration | %LEL | 1 |
| `vibrationVelocity` | Vibration velocity | mm/s | 2 |
| `vibrationAcceleration` | Vibration acceleration | m/s² | 2 |

Vacuum uses `ParameterPresets.vacuum(unit: 'kPa', convention: 'Gauge pressure, relative to atmosphere')`. The specialized VacuumGauge additionally requires a PressureConvention enum and explicit min/max.

Power factor uses `ParameterPresets.powerFactor(convention: 'Positive = import; lagging')`. The sign and leading/lagging convention must come from the application; neither is inferred from the numeric value.

For digital open/closed signals use ContactIndicator(closed: observedContact). For on/off signals use StateLight(active: observedState). Null means unknown.

Use generic RadialGauge, LinearScale or DigitalReadout for mass, load, torque, voltage, current, power, energy, humidity, pH, conductivity, oxygen, turbidity, gas and vibration. Use specialized silhouettes only when they add meaning: Thermometer/TemperatureProbe, pressure instruments, vessels for height, and equipment for observed machine state. No new illustration is invented solely to represent a unit.
