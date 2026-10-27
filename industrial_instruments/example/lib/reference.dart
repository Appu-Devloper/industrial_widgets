import 'package:flutter/material.dart';
import 'package:industrial_instruments/industrial_instruments.dart';

class ReferenceCanvas extends StatelessWidget {
  const ReferenceCanvas({super.key});
  @override
  Widget build(BuildContext context) {
    final dark = Uri.base.queryParameters['theme'] == 'dark';
    final size =
        double.tryParse(Uri.base.queryParameters['width'] ?? '') ?? 280;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: dark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: dark
            ? const Color(0xff132320)
            : const Color(0xfff8f9f5),
      ),
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FIELD / INSTRUMENT STUDIES',
                      style: TextStyle(fontSize: 11, letterSpacing: 2),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Read the process.',
                      style: TextStyle(fontSize: 40, letterSpacing: -1),
                    ),
                    const SizedBox(height: 12),
                    const Text('Five forms. One precise visual language.'),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 40,
                      runSpacing: 40,
                      children: [
                        sample(
                          '01 / PRESSURE',
                          RadialGauge(
                            value: 6.4,
                            min: 0,
                            max: 10,
                            unit: 'bar',
                            target: 8,
                          ),
                          size,
                        ),
                        sample(
                          '02 / TEMPERATURE',
                          Thermometer(value: 72, min: 0, max: 120, unit: '°C'),
                          size,
                        ),
                        sample(
                          '03 / LIQUID HEIGHT',
                          CylindricalTank(value: 68, unit: '%'),
                          size,
                        ),
                        sample(
                          '04 / PHASE VOLTAGE',
                          ThreePhaseReadout(values: [230.2, 231.4, 229.8]),
                          size,
                        ),
                        sample(
                          '05 / ISOLATION VALVE',
                          ValveIndicator(
                            position: ValvePosition.intermediate,
                            openingPercent: 65,
                          ),
                          size,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget sample(String label, Widget child, double width) => SizedBox(
    width: width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, letterSpacing: 1)),
        const SizedBox(height: 22),
        child,
      ],
    ),
  );
}
