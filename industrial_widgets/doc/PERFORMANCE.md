# Performance measurement

Measured 2026-10-27 using the included Factory Monitor, not an isolated painter
microbenchmark. Raw data: [profile-results.json](profile-results.json).

| Setting | Value |
| --- | --- |
| Host | Apple M3 Pro, arm64, macOS 27.0.1 |
| Browser | Google Chrome 156.0.8078.48, headless |
| SDK | Flutter 3.35.6 / Dart 3.9.2 |
| Build | `flutter build web --profile --dart-define=BENCHMARK=true`, CanvasKit |
| Viewport | 1440 × 1280, device pixel ratio 1 |
| Instruments | 8: two gauges, one tank, two cards, one chart, two alarms |
| Chart data | Two series, 2,000 retained points each; approximately 2,402 visible points total |
| Update rate | 10 batches/sec, 20 chart samples/sec; instruments also update |
| Motion | Gauge/tank transitions and tank ripple enabled |
| Sample | Three-second warmup, then 20 seconds; 1,201 browser frame intervals |

Observed browser requestAnimationFrame intervals: **median 16.7 ms, p95 16.8 ms,
maximum 16.8 ms; zero intervals over 33 ms**. CDP reported 4.390 seconds of
main-thread task time during the sample, and 38,894,480 bytes of JS heap in use
at the endpoint. No browser page errors occurred.

These are browser scheduling observations, not Flutter build/raster frame
statistics or an FPS guarantee. The heap value excludes native CanvasKit/GPU
memory and is not a leak assessment. Headless desktop performance does not
predict phones, embedded panels or other renderers. Browser accessibility was
enabled after the timed interval. The example rebuilds its small dashboard
on each batch; larger applications should isolate telemetry listeners by panel.
A final accessibility wording change and simulation waveform adjustment followed
this measurement; rendering and sampling algorithms were unchanged.

## Reproduce from a repository checkout

```sh
cd example
flutter build web --profile --dart-define=BENCHMARK=true
cd ..
python3 -m http.server 8765 --directory example/build/web
```

In another terminal, from the package root:

```sh
npm install --prefix /tmp/industrial-browser playwright
NODE_PATH=/tmp/industrial-browser/node_modules node tool/browser_check.cjs
```

The script uses an installed Chrome, reports platform/browser details, saves the
JSON, activates accessibility, exercises pause/theme, and captures desktop/light/
mobile PNGs. Keep the browser foreground if repeating in headed mode; don't
compare background-throttled runs to these results. For device acceptance, also
measure Flutter frame timings in DevTools, input latency, sustained memory and
CPU under the real telemetry workload, including disconnection and gap-heavy
streams. Do not interpret this one sample as a maximum supported load.

## Bounds and rendering strategy

Per-series retention is capped at 2,000 by default and also pruned by event time.
Ingestion is O(log n) lookup plus O(n) list insertion/pruning for out-of-order
points; sequential streams append efficiently but notifications and pruning still
have work. Batch packets where possible. Input batches and stream queues remain
application-owned and can allocate more than retained history.

Chart rendering scans the visible bounded history, then keeps first/min/max/last
per pixel bucket within each uninterrupted valid run. This protects spikes and
gaps; it is not statistical aggregation. Alternating gaps can defeat compression.
Sampling is performed outside paint. Repaint boundaries separate instrument
painting from surrounding panels; the tank's ripple repaints without rebuilding
layout. Disable optional liquid motion on dense dashboards and choose transition
durations appropriate to your update rate.
