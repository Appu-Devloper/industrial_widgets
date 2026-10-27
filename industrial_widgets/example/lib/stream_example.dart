import 'package:flutter/material.dart';
import 'package:industrial_widgets/industrial_widgets.dart';

/// Minimal mountable example with an automatically canceled simulated stream.
class StreamTrendExample extends StatefulWidget {
  /// Creates the example.
  const StreamTrendExample({super.key});
  @override
  State<StreamTrendExample> createState() => _StreamTrendExampleState();
}

class _StreamTrendExampleState extends State<StreamTrendExample> {
  late final IndustrialTrendController _trends;
  String? _error;
  @override
  void initState() {
    super.initState();
    _trends = IndustrialTrendController(
      series: const [
        TrendSeries(
          id: 'temperature',
          name: 'Temperature',
          unit: '°C',
          color: Colors.teal,
        ),
      ],
    );
    final start = DateTime.now().toUtc();
    _trends.bind(
      Stream<TrendUpdate>.periodic(
        const Duration(milliseconds: 500),
        (i) => TrendUpdate(
          'temperature',
          TrendPoint(
            start.add(Duration(milliseconds: 500 * i)),
            60 + (i % 10) / 10,
          ),
        ),
      ),
      onError: (error, stack) {
        if (mounted) setState(() => _error = error.toString());
      },
    );
  }

  @override
  void dispose() {
    _trends.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (_error != null) Text('Stream error: $_error'),
      IndustrialTrendChart(controller: _trends),
    ],
  );
}
