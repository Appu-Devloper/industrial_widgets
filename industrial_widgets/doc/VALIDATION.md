# Validation record

Date: 2026-10-27. Flutter 3.35.6 stable, Dart 3.9.2. Host: Apple M3 Pro,
macOS 27.0.1. Browser: Chrome 156.0.8078.48.

| Check | Result |
| --- | --- |
| Dependency resolution | Passed for package and example |
| Dart formatter | Passed for lib, test, example/lib and example/test |
| `dart analyze` | Passed, no issues; public API documentation lint enabled |
| Core `flutter test --platform chrome --reporter expanded` | 13 passed |
| Example `flutter test --platform chrome --reporter expanded` | 2 passed |
| `flutter build web --profile` and `--release` | Passed, including Wasm compilation dry run |
| Profile benchmark | Completed; see PERFORMANCE.md and raw JSON |
| Deterministic showcase | Generated WebM and reviewed warning/acknowledgement/theme frames |
| Chrome visual review | Dark/light desktop at 1440 × 1280; mobile at 390 × 844 |
| Narrow/text scale tests | Instruments at 200 px / 200%; dashboard at 320 px / 200% |
| `dart pub publish --dry-run` | Passed with zero warnings; no upload performed |

Tests cover invalid bounds and settings; null, NaN, infinity, negative and
out-of-range values; duplicate instants and out-of-order ingestion; event-time
retention and caps; atomic batch validation; disposal and stream cancellation;
alarm acknowledgement, clearing and opt-in dismissal; reduced motion; semantic
labels; keyboard inspection; empty/single/gapped charts; controller replacement;
dense spike/gap-preserving sampling; narrow layouts, both themes and text scaling;
example controls and timer cleanup.

Native `flutter test` was attempted but could not start because this local SDK
has no `darwin-x64/flutter_tester` binary. `flutter precache --macos` did not
restore it. `flutter analyze` was attempted and failed because the SDK tool
expects `analysis_server.dart.snapshot` while its cache contains the AOT server
snapshot. `dart analyze` successfully analyzed the same source tree. No global
SDK upgrade or replacement was performed.

Web builds emit a font-tree-shaker notice about CupertinoIcons referenced by
Flutter's framework defaults. The example uses only Material icons and they
rendered correctly. The Wasm dry run checks compilation only; Wasm runtime has
not been tested. CI configuration is included but has not run on GitHub.

Android, iOS, macOS desktop, Windows and Linux have not been run. Physical
screen-reader tests, device memory profiling and mobile/embedded profile
measurements remain release validation tasks. Browser screenshots are reviewed
artifacts, not pixel-golden assertions. No unsupported certification, precision,
or broad platform/performance claim is made.
