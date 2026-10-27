# Contributing

Use Flutter 3.35+ and Dart 3.9+. Keep runtime dependencies limited to Flutter unless a concrete need justifies an addition. Keep equipment presentational and avoid dashboard workflows in the package.

Run formatting, `flutter analyze`, and `flutter test` from this package directory. Run the example on Chrome and inspect light and dark backgrounds after geometry changes. Run `flutter test tool/generate_examples_test.dart` after changing gallery integration code, then format the generated test fixtures. Check compact width, 2× text, missing data, min/max, and reduced motion. New tests should cover behavior or geometry rather than reproduce implementation details.

Use the repository supplied by the owner: https://github.com/Appu-Devloper/industrial_widgets. The maintained package lives in the repository subdirectory `industrial_instruments/`; run package commands there. The repository-root workflow validates that package and its example. Do not publish from an automated contribution step.
