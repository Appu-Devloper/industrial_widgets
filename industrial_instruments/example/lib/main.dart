import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:industrial_instruments/industrial_instruments.dart';
import 'catalog.dart';
import 'reference.dart';

void main() => runApp(
  Uri.base.queryParameters.containsKey('reference')
      ? const ReferenceCanvas()
      : const Atelier(),
);

class Atelier extends StatefulWidget {
  const Atelier({super.key});
  @override
  State<Atelier> createState() => _AtelierState();
}

class _AtelierState extends State<Atelier> {
  final query = Uri.base.queryParameters;
  late bool dark = query['theme'] == 'dark',
      missing = query['missing'] == 'true',
      animate = query['animate'] == 'true',
      vertical = query['orientation'] == 'vertical';
  late int? selected = int.tryParse(query['widget'] ?? '');
  int category = 0, color = 0, tick = 0;
  late double value, min, max;
  late String unit;
  String? rangeError;
  Timer? timer;
  final low = TextEditingController(),
      high = TextEditingController(),
      unitInput = TextEditingController();
  EquipmentState state = EquipmentState.running;
  FlowDirection direction = FlowDirection.forward;
  @override
  void initState() {
    super.initState();
    if (selected != null && (selected! < 0 || selected! >= 33)) selected = null;
    configure(selected ?? 0);
    if (query['value'] != null) {
      value = double.tryParse(query['value']!) ?? value;
    }
    syncTimer();
  }

  void configure(int i) {
    min = minima[i];
    max = maxima[i];
    value = readings[i];
    unit = units[i];
    low.text = '$min';
    high.text = '$max';
    unitInput.text = unit;
    rangeError = null;
  }

  void select(int i) => setState(() {
    selected = i;
    configure(i);
  });
  void syncTimer() {
    timer?.cancel();
    if (animate) {
      timer = Timer.periodic(const Duration(milliseconds: 150), (_) {
        if (mounted) {
          setState(() {
            tick++;
            value = min + (max - min) * (.55 + .25 * math.sin(tick / 16));
          });
        }
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    low.dispose();
    high.dispose();
    unitInput.dispose();
    super.dispose();
  }

  Color get accent => [
    dark ? const Color(0xff65d5c2) : const Color(0xff13796e),
    dark ? const Color(0xffefc37e) : const Color(0xff98651b),
    dark ? const Color(0xff9fc9f0) : const Color(0xff356d9d),
  ][color];
  Widget instrument(int i, {bool detail = false}) => buildInstrument(
    i,
    value: detail ? (missing ? null : value) : readings[i],
    min: detail ? min : null,
    max: detail ? max : null,
    unit: detail ? unit : null,
    accent: accent,
    animate: detail && animate,
    vertical: detail && vertical,
    state: state,
    direction: direction,
  );
  String code(int i) => integrationCode(
    i,
    value: missing ? null : value,
    min: min,
    max: max,
    unit: unit,
    accent: accent,
    animate: animate,
    vertical: vertical,
    state: state,
    direction: direction,
  );
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      colorSchemeSeed: accent,
      scaffoldBackgroundColor: dark
          ? const Color(0xff132320)
          : const Color(0xfff8f9f5),
    ),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
          double.tryParse(query['scale'] ?? '') ?? 1,
        ),
      ),
      child: child!,
    ),
    home: Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            padding: EdgeInsets.all(c.maxWidth < 600 ? 20 : 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => selected = null),
                          child: Text(
                            'FIELD / INSTRUMENT CATALOG',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 2,
                              color: accent,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Switch background',
                          onPressed: () => setState(() => dark = !dark),
                          icon: Icon(
                            dark
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    if (selected == null)
                      ...overview(c.maxWidth)
                    else
                      ...detail(selected!, c.maxWidth),
                    const SizedBox(height: 48),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      '33 instruments · Explicit units · Application-supplied state',
                      style: TextStyle(fontSize: 12),
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
  List<Widget> overview(double width) => [
    Text(
      'Read the process.',
      style: TextStyle(
        fontSize: width < 600 ? 38 : 60,
        height: 1.1,
        letterSpacing: -2,
      ),
    ),
    const SizedBox(height: 16),
    const Text(
      'Find the right form for your measurement.\nPrecise scales. Clear signals. Nothing in the way.',
      style: TextStyle(fontSize: 17, height: 1.6),
    ),
    const SizedBox(height: 28),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < categories.length; i++)
          ChoiceChip(
            label: Text(categories[i]),
            selected: category == i,
            onSelected: (_) => setState(() => category = i),
          ),
      ],
    ),
    const SizedBox(height: 36),
    if (category == 0) ...[
      LayoutBuilder(
        builder: (context, c) => Wrap(
          spacing: 48,
          runSpacing: 40,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            preview(9, math.min(c.maxWidth, 340)),
            preview(23, math.min(c.maxWidth, 300)),
            preview(13, math.min(c.maxWidth, 270)),
          ],
        ),
      ),
      const SizedBox(height: 36),
      const Divider(),
      const SizedBox(height: 24),
      const Text('Explore the collection', style: TextStyle(fontSize: 28)),
      const SizedBox(height: 20),
    ],
    LayoutBuilder(
      builder: (context, c) => Wrap(
        spacing: 40,
        runSpacing: 44,
        children: [
          for (var i = 0; i < 33; i++)
            if ((category == 0 && ![9, 23, 13].contains(i)) ||
                groups[i] == category)
              preview(i, math.min(c.maxWidth, 250)),
        ],
      ),
    ),
    if (category == 7) ...[
      const SizedBox(height: 32),
      const Text(
        'One readout, many parameters',
        style: TextStyle(fontSize: 24),
      ),
      const SizedBox(height: 12),
      const Text(
        'Presets supply labels and formatting. They never infer operating limits.',
      ),
      const SizedBox(height: 20),
      LayoutBuilder(
        builder: (context, c) => Wrap(
          spacing: 32,
          runSpacing: 32,
          children: [
            for (final p in [
              ParameterPresets.humidity,
              ParameterPresets.ph,
              ParameterPresets.conductivityMicro,
              ParameterPresets.dissolvedOxygen,
              ParameterPresets.turbidity,
              ParameterPresets.gasPpm,
              ParameterPresets.vibrationVelocity,
            ])
              SizedBox(
                width: math.min(c.maxWidth, 240),
                child: p.readout(
                  value: p == ParameterPresets.ph ? 7.2 : 12.4,
                  style: InstrumentStyle(accent: accent),
                ),
              ),
          ],
        ),
      ),
    ],
  ];
  Widget preview(int i, double width) => SizedBox(
    width: width,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '${(i + 1).toString().padLeft(2, '0')} / ',
              style: TextStyle(fontSize: 11, color: accent),
            ),
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                ),
                onPressed: () => select(i),
                child: Text(displayName(i)),
              ),
            ),
            const Icon(Icons.north_east, size: 14),
          ],
        ),
        const SizedBox(height: 16),
        instrument(i),
      ],
    ),
  );
  List<Widget> detail(int i, double width) => [
    Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => setState(() => selected = null),
        icon: const Icon(Icons.arrow_back, size: 16),
        label: const Text('Collection'),
      ),
    ),
    const SizedBox(height: 12),
    Text(
      displayName(i),
      style: TextStyle(fontSize: width < 600 ? 32 : 48, letterSpacing: -1),
    ),
    const SizedBox(height: 12),
    Text(
      '${categories[groups[i]]} / ${names[i]}',
      style: TextStyle(color: accent, fontSize: 13),
    ),
    const SizedBox(height: 36),
    LayoutBuilder(
      builder: (context, c) => Wrap(
        spacing: 72,
        runSpacing: 36,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: math.min(
              c.maxWidth,
              double.tryParse(query['width'] ?? '') ?? 380,
            ),
            child: instrument(i, detail: true),
          ),
          SizedBox(width: math.min(c.maxWidth, 320), child: controls(i)),
        ],
      ),
    ),
    const SizedBox(height: 32),
    const Divider(),
    const SizedBox(height: 12),
    Row(
      children: [
        const Expanded(
          child: Text(
            'MINIMAL INTEGRATION',
            style: TextStyle(fontSize: 11, letterSpacing: 1.5),
          ),
        ),
        Builder(
          builder: (context) => TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code(i)));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Integration code copied')),
                );
              }
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy code'),
          ),
        ),
      ],
    ),
    SelectableText(
      code(i),
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        height: 1.7,
      ),
    ),
  ];
  Widget controls(int i) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'MAKE IT YOURS',
        style: TextStyle(fontSize: 11, letterSpacing: 2, color: accent),
      ),
      const SizedBox(height: 16),
      Text('Reading  ${missing ? '—' : value.toStringAsFixed(2)}'),
      Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        onChanged: (v) => setState(() => value = v),
      ),
      if (![18, 26, 28, 29, 30, 31, 32].contains(i)) ...[
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: low,
                enabled: i != 24,
                decoration: const InputDecoration(labelText: 'Minimum'),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: high,
                decoration: InputDecoration(
                  labelText: i == 24 ? 'Extent' : 'Maximum',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: unitInput,
          decoration: const InputDecoration(labelText: 'Engineering unit'),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => applyRange(i),
            child: const Text('Apply range & unit'),
          ),
        ),
        if (rangeError != null)
          Semantics(
            liveRegion: true,
            label: rangeError!,
            child: ExcludeSemantics(
              child: Text(
                rangeError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
      ],
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Missing reading'),
        value: missing,
        onChanged: (v) => setState(() => missing = v),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Animate demo'),
        value: animate,
        onChanged: (v) => setState(() {
          animate = v;
          syncTimer();
        }),
      ),
      if ([2, 3, 6, 20, 22].contains(i))
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Vertical'),
          value: vertical,
          onChanged: (v) => setState(() => vertical = v),
        ),
      if ([17, 18, 19, 21, 26, 27, 29, 30].contains(i)) ...[
        DropdownButton<EquipmentState>(
          isExpanded: true,
          value: state,
          items: [
            for (final s in EquipmentState.values)
              DropdownMenuItem(value: s, child: Text(s.name)),
          ],
          onChanged: (v) => setState(() => state = v!),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Reverse direction'),
          value: direction == FlowDirection.reverse,
          onChanged: (v) => setState(
            () => direction = v ? FlowDirection.reverse : FlowDirection.forward,
          ),
        ),
      ],
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var c = 0; c < 3; c++)
            ChoiceChip(
              label: Text(['Teal', 'Amber', 'Blue'][c]),
              selected: color == c,
              onSelected: (_) => setState(() => color = c),
            ),
        ],
      ),
    ],
  );
  void applyRange(int i) {
    final hi = double.tryParse(high.text),
        lo = i == 24 && hi != null ? -hi : double.tryParse(low.text);
    if (lo == null ||
        hi == null ||
        !lo.isFinite ||
        !hi.isFinite ||
        lo >= hi ||
        !(hi - lo).isFinite ||
        ([5, 10, 24].contains(i) && (lo > 0 || hi < 0))) {
      setState(
        () => rangeError =
            'Use finite ordered bounds; signed instruments must include zero.',
      );
      return;
    }
    if (i == 5 && (lo + hi).abs() > (hi - lo) * 1e-10) {
      setState(
        () => rangeError = 'Deviation bounds must be symmetric about zero.',
      );
      return;
    }
    setState(() {
      min = lo;
      max = hi;
      unit = unitInput.text;
      value = value.clamp(min, max);
      low.text = '$min';
      rangeError = null;
    });
  }
}
