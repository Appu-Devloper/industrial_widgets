# Factory Monitor

Run `flutter pub get` then `flutter run -d chrome` from this directory.

- Seed 42, UTC simulation epoch 2026-10-27 08:00, history prefilled.
- Pause/resume, 1/2/10 Hz, light/dark, warning/clear/acknowledge, disconnect,
  stale readings, reduced motion and copyable widget gallery.
- `--dart-define=DEMO=true`: 17-second showcase, automatically paused at end.
- `--dart-define=BENCHMARK=true`: 2,000 points per series and 10 Hz updates.
- Do not combine DEMO and BENCHMARK: demo steps are designed for default 2 Hz.

The checked-in runner targets web. To generate another runner locally, use
`flutter create --platforms=android,ios,macos,windows,linux .` with appropriate
platform tooling, then test that platform. Other platforms were not run here.

`lib/stream_example.dart` demonstrates a separately owned stream subscription.
See the parent README and doc/ for API, lifecycle, recording and measured results.
