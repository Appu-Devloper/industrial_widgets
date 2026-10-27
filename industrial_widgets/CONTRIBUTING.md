# Contributing

Use Flutter stable 3.35 or newer. Keep runtime dependencies small, public APIs
null-safe and documented, and implementation helpers under lib/src. Include a
reproducer for bugs and tests of externally observable behavior. Never conflate
measurement quality, freshness and connection status, and never clear process
alarms from presentation code.

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test example/lib example/test
flutter analyze
flutter test
cd example
flutter test
flutter build web
```

Chrome tests can be run with `flutter test --platform chrome` in both directories.
On this delivery machine `dart analyze` works while `flutter analyze` is blocked
by an SDK artifact mismatch; use the normal Flutter command on a complete SDK.

Before opening a release, run `dart pub publish --dry-run`, inspect its manifest,
verify the license and real repository metadata, and recheck the name on pub.dev.
Do not publish until the owner authorizes publication. Test platform and
performance claims on real targets and record the setup. Do not add fabricated
benchmarks or golden images that were not visually reviewed.
