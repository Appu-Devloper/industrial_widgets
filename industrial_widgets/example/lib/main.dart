import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:industrial_widgets/industrial_widgets.dart';

void main() => runApp(const FactoryMonitor());

/// Responsive deterministic showcase, also used by visual tests.
class FactoryMonitor extends StatefulWidget {
  /// Set autoStart false for a reproducible still image.
  const FactoryMonitor({super.key, this.autoStart = true});

  /// Whether telemetry starts on mount.
  final bool autoStart;
  @override
  State<FactoryMonitor> createState() => _FactoryMonitorState();
}

class _FactoryMonitorState extends State<FactoryMonitor> {
  final _random = math.Random(42);
  late final IndustrialTrendController _trends;
  final _epoch = DateTime.utc(2026, 10, 27, 8);
  Timer? _timer;
  int _tick = 120, _interval = 500, _demoStep = 0;
  double _seconds = 120;
  bool _dark = true,
      _paused = false,
      _disconnected = false,
      _stale = false,
      _reduced = false,
      _gallery = false;
  AlarmState _alarmState = AlarmState.active;
  double _rpm = 1482, _pressure = 6.4, _level = 68, _temperature = 63.8;
  static const _demo = bool.fromEnvironment('DEMO');
  static const _benchmark = bool.fromEnvironment('BENCHMARK');
  late DateTime _readingTime;
  @override
  void initState() {
    super.initState();
    _readingTime = _epoch.add(const Duration(seconds: 120));
    if (_demo) _alarmState = AlarmState.cleared;
    if (_benchmark) {
      _interval = 100;
      _seconds = 199.9;
    }
    _trends = IndustrialTrendController(
      series: const [
        TrendSeries(
          id: 'temperature',
          name: 'Temperature',
          unit: '°C',
          color: Color(0xFF4EDBC5),
        ),
        TrendSeries(
          id: 'pressure',
          name: 'Pressure',
          unit: 'bar',
          color: Color(0xFFF4AF58),
        ),
      ],
    );
    _trends.addAll([
      for (var i = 0; i < (_benchmark ? 2000 : 121); i++) ...[
        TrendUpdate(
          'temperature',
          TrendPoint(
            _epoch.add(Duration(milliseconds: i * (_benchmark ? 100 : 1000))),
            60 +
                5 * math.sin(i * (_benchmark ? .1 : 1) / 14) +
                _random.nextDouble(),
          ),
        ),
        TrendUpdate(
          'pressure',
          TrendPoint(
            _epoch.add(Duration(milliseconds: i * (_benchmark ? 100 : 1000))),
            6 + math.sin(i * (_benchmark ? .1 : 1) / 19),
          ),
        ),
      ],
    ]);
    if (widget.autoStart) _start();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: _interval),
      (_) => _advance(),
    );
  }

  void _advance() {
    if (_paused) return;
    setState(() {
      _tick++;
      _seconds += _interval / 1000;
      if (_demo) {
        _demoStep++;
        if (_demoStep == 8) _alarmState = AlarmState.active;
        if (_demoStep == 16) _alarmState = AlarmState.acknowledged;
        if (_demoStep == 24) _dark = false;
        if (_demoStep == 34) _paused = true;
      }
      if (!_disconnected && !_stale) {
        _readingTime = _epoch.add(
          Duration(milliseconds: (_seconds * 1000).round()),
        );
        _rpm = 1480 + 100 * math.sin(_seconds / 4) + _random.nextDouble() * 8;
        _pressure = 6.4 + math.sin(_seconds / 9) * .7;
        _level = 62 + 18 * math.sin(_seconds / 10);
        _temperature = 60 + 5 * math.sin(_seconds / 14) + _random.nextDouble();
      }
      if (!_stale) {
        final time = _epoch.add(
          Duration(milliseconds: (_seconds * 1000).round()),
        );
        _trends.addAll([
          TrendUpdate(
            'temperature',
            TrendPoint(time, _disconnected ? null : _temperature),
          ),
          TrendUpdate(
            'pressure',
            TrendPoint(time, _disconnected ? null : _pressure),
          ),
        ]);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _trends.dispose();
    super.dispose();
  }

  IndustrialReading _reading(double value) => IndustrialReading(
    value,
    timestamp: _readingTime,
    freshness: _stale ? ReadingFreshness.stale : ReadingFreshness.fresh,
    connection: _disconnected
        ? ConnectionStatus.disconnected
        : ConnectionStatus.connected,
  );
  @override
  Widget build(BuildContext context) {
    final tokens = _dark ? IndustrialTheme.dark : IndustrialTheme.light;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Factory Monitor',
      theme: ThemeData(
        useMaterial3: true,
        brightness: _dark ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: tokens.accent,
          brightness: _dark ? Brightness.dark : Brightness.light,
        ),
        scaffoldBackgroundColor: _dark
            ? const Color(0xFF0B151D)
            : const Color(0xFFF0F5F7),
        extensions: [tokens],
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations:
              _reduced || MediaQuery.disableAnimationsOf(context),
        ),
        child: child!,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1250),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 16,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NORTH / PROCESS SYSTEMS',
                                style: TextStyle(
                                  color: tokens.accent,
                                  fontSize: 11,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Factory Monitor',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Plant 04   /   Water treatment line',
                                style: TextStyle(color: tokens.muted),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              Chip(
                                avatar: Icon(
                                  _disconnected
                                      ? Icons.cloud_off
                                      : Icons.sensors,
                                  size: 18,
                                ),
                                label: Text(
                                  _disconnected
                                      ? 'Disconnected'
                                      : 'System connected',
                                ),
                              ),
                              IconButton(
                                tooltip: 'Switch theme',
                                onPressed: () => setState(() => _dark = !_dark),
                                icon: Icon(
                                  _dark
                                      ? Icons.light_mode_outlined
                                      : Icons.dark_mode_outlined,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Widget gallery',
                                onPressed: () =>
                                    setState(() => _gallery = !_gallery),
                                icon: const Icon(Icons.code),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: () => setState(() => _paused = !_paused),
                            icon: Icon(
                              _paused ? Icons.play_arrow : Icons.pause,
                            ),
                            label: Text(_paused ? 'Resume' : 'Pause'),
                          ),
                          DropdownButton<int>(
                            value: _interval,
                            items: const [
                              DropdownMenuItem(
                                value: 1000,
                                child: Text('1 Hz'),
                              ),
                              DropdownMenuItem(value: 500, child: Text('2 Hz')),
                              DropdownMenuItem(
                                value: 100,
                                child: Text('10 Hz'),
                              ),
                            ],
                            onChanged: (v) {
                              setState(() => _interval = v!);
                              _start();
                            },
                          ),
                          FilterChip(
                            label: const Text('Disconnect'),
                            selected: _disconnected,
                            onSelected: (v) =>
                                setState(() => _disconnected = v),
                          ),
                          FilterChip(
                            label: const Text('Stale readings'),
                            selected: _stale,
                            onSelected: (v) => setState(() => _stale = v),
                          ),
                          FilterChip(
                            label: const Text('Reduced motion'),
                            selected: _reduced,
                            onSelected: (v) => setState(() => _reduced = v),
                          ),
                          ActionChip(
                            label: const Text('Trigger warning'),
                            onPressed: () =>
                                setState(() => _alarmState = AlarmState.active),
                          ),
                          ActionChip(
                            label: const Text('Clear alarm'),
                            onPressed: () => setState(
                              () => _alarmState = AlarmState.cleared,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'PROCESS OVERVIEW',
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            _paused
                                ? 'PAUSED'
                                : _stale
                                ? 'STALE'
                                : 'LIVE •',
                            style: TextStyle(
                              color: tokens.accent,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, c) {
                          final scale = MediaQuery.textScalerOf(
                            context,
                          ).scale(1);
                          final count = c.maxWidth >= 1000 && scale < 1.5
                              ? 4
                              : c.maxWidth >= 600 && scale < 1.8
                              ? 2
                              : 1;
                          final width = (c.maxWidth - (count - 1) * 16) / count;
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              SizedBox(
                                width: width,
                                child: IndustrialGauge(
                                  label: 'MOTOR / M-201',
                                  reading: _reading(_rpm),
                                  range: IndustrialRange(0, 2000),
                                  unit: 'rpm',
                                  formatter: (v) => v.toStringAsFixed(0),
                                  target: 1500,
                                  bands: [
                                    IndustrialBand(
                                      range: IndustrialRange(1700, 2000),
                                      color: tokens.warning,
                                      label: 'High speed',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: IndustrialGauge(
                                  label: 'DISCHARGE PRESSURE',
                                  reading: _reading(_pressure),
                                  range: IndustrialRange(0, 10),
                                  unit: 'bar',
                                  target: 7.5,
                                  style: const GaugeStyle(
                                    presentation: GaugePresentation.arc,
                                  ),
                                  bands: [
                                    IndustrialBand(
                                      range: IndustrialRange(8, 10),
                                      color: tokens.critical,
                                      label: 'High pressure',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: IndustrialTank(
                                  label: 'RESERVOIR / T-04',
                                  reading: _reading(_level),
                                  range: IndustrialRange(0, 100),
                                  target: 80,
                                  style: const TankStyle(animateLiquid: true),
                                  bands: [
                                    IndustrialBand(
                                      range: IndustrialRange(0, 20),
                                      color: tokens.warning,
                                      label: 'Low',
                                    ),
                                    IndustrialBand(
                                      range: IndustrialRange(20, 85),
                                      color: tokens.accent,
                                      label: 'Normal',
                                    ),
                                    IndustrialBand(
                                      range: IndustrialRange(85, 100),
                                      color: tokens.critical,
                                      label: 'High',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    IndustrialValueCard(
                                      label: 'ACTIVE POWER',
                                      reading: _reading(
                                        24.8 + math.sin(_tick / 20),
                                      ),
                                      unit: 'kW',
                                      icon: Icons.bolt,
                                      secondaryText: '↓ 4.2% from prior shift',
                                    ),
                                    const SizedBox(height: 16),
                                    IndustrialValueCard(
                                      label: 'SHIFT ENERGY',
                                      reading: _reading(
                                        186.4 + (_tick - 120) * .01,
                                      ),
                                      unit: 'kWh',
                                      icon: Icons.electric_meter_outlined,
                                      secondaryText: 'Target 220 kWh',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      IndustrialTrendChart(
                        controller: _trends,
                        label: 'PROCESS HISTORY   /   Last 2 minutes',
                        theme: tokens,
                        style: TrendChartStyle(
                          seriesColors: _dark
                              ? const {}
                              : const {
                                  'temperature': Color(0xFF007E70),
                                  'pressure': Color(0xFF925500),
                                },
                          bounds: IndustrialRange(0, 80),
                          plotHeight: 175,
                          thresholds: [
                            TrendThreshold(
                              value: 70,
                              label: 'Temperature warning (°C)',
                              color: tokens.warning,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      IndustrialAlarmBanner(
                        alarm: IndustrialAlarm(
                          title: 'Filter differential pressure rising',
                          message:
                              'Inspect filter F-02 during the next maintenance window.',
                          timestamp: _epoch.add(const Duration(minutes: 2)),
                          source: 'LINE 04 / F-02',
                          state: _alarmState,
                        ),
                        timestampFormatter: (t) => '08:02 UTC',
                        onAcknowledge: () => setState(
                          () => _alarmState = AlarmState.acknowledged,
                        ),
                      ),
                      const SizedBox(height: 12),
                      IndustrialAlarmBanner(
                        alarm: IndustrialAlarm(
                          title: 'Pump inspection scheduled',
                          message:
                              'Acknowledged by the shift operator. Process condition remains active.',
                          timestamp: _epoch,
                          severity: AlarmSeverity.information,
                          state: AlarmState.acknowledged,
                          source: 'P-101',
                        ),
                        timestampFormatter: (t) => '08:00 UTC',
                      ),
                      if (_gallery) ...[
                        const SizedBox(height: 24),
                        const _Gallery(),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'DETERMINISTIC SIMULATION  •  Seed 42  •  Presentation only',
                        style: TextStyle(color: tokens.muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery();
  static const examples = {
    'Gauge':
        "IndustrialGauge(label: 'Speed', reading: const IndustrialReading(1480), range: IndustrialRange(0, 2000), unit: 'rpm')",
    'Tank':
        "IndustrialTank(label: 'Water', reading: const IndustrialReading(68), range: IndustrialRange(0, 100))",
    'Value card':
        "IndustrialValueCard(label: 'Power', reading: const IndustrialReading(24.8), unit: 'kW')",
    'Alarm':
        "IndustrialAlarmBanner(alarm: IndustrialAlarm(title: 'High pressure', message: 'Inspect filter', timestamp: DateTime.now()), onAcknowledge: () { /* update app-owned state */ })",
    'Trend':
        "// Own and dispose this controller in State.\nfinal trends = IndustrialTrendController(series: const [TrendSeries(id: 't', name: 'Temperature', unit: '°C', color: Colors.teal)]);\n// In build:\nIndustrialTrendChart(controller: trends)",
  };
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Widget gallery',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      ),
      for (final entry in examples.entries)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(entry.key)),
                    IconButton(
                      tooltip: 'Copy ${entry.key} example',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: entry.value));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied example')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                    ),
                  ],
                ),
                SelectableText(
                  entry.value,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
