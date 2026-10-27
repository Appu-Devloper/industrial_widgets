import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: avoid_relative_lib_imports
import '../example/lib/catalog.dart';

void main() {
  test('generate the catalog integration examples', () {
    Directory('test/support').createSync(recursive: true);
    final catalog = File('example/lib/catalog.dart').readAsStringSync();
    File('test/support/catalog.dart').writeAsStringSync(
      '// Public-API rendering fixtures generated from the example catalog.\n${catalog.substring(0, catalog.indexOf('String integrationCode('))}',
    );
    final snippets = [
      for (var i = 0; i < 33; i++)
        integrationCode(
          i,
          value: readings[i],
          min: minima[i],
          max: maxima[i],
          unit: units[i],
          accent: const Color(0xff13796e),
        ),
    ];
    final docs = StringBuffer(
      '# Minimal examples\n\nWidget expressions for use inside a Flutter build method.\n\n```dart\nimport \'package:flutter/material.dart\';\nimport \'package:industrial_instruments/industrial_instruments.dart\';\n```\n\nThese are explicit demo ranges, not safety recommendations. Edit range, unit and formatting for your application.\n\n',
    );
    for (var i = 0; i < 33; i++) {
      docs.writeln('## ${names[i]}\n\n```dart\n${snippets[i]}\n```\n');
    }
    File('doc/EXAMPLES.md').writeAsStringSync(docs.toString());
    File('test/generated_examples_test.dart').writeAsStringSync(
      '''// Generated from the gallery's actual Copy code function; regenerate with tool/generate_examples_test.dart.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:industrial_instruments/industrial_instruments.dart';
import 'instruments_test.dart' show host;

void main() {
  testWidgets('all 33 copied integration examples compile and render', (tester) async {
    final examples = <Widget>[
${snippets.join(',\n')},
    ];
    await tester.pumpWidget(host(Column(children: examples)));
    expect(tester.takeException(), isNull);
  });
}
''',
    );
  });
}
