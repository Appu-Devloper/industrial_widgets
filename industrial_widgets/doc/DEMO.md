# Showcase and recording

Generated and reviewed: `assets/factory-monitor-showcase.webm` (18 seconds,
1440 × 1280). It begins with the populated dashboard and includes the warning,
acknowledgement and one theme switch. [Opening still](assets/demo-start.png) ·
[Ending still](assets/demo-end.png). The WebM is included in the repository checkout.

Factory Monitor has a deterministic, prepopulated 17-second demo at seed 42.
At the normal 2 Hz update rate:

| Elapsed simulation time | Action |
| --- | --- |
| 0 seconds | Populated graphite dashboard, historical chart, cleared warning |
| 0–4 seconds | Gauges, tank and live chart update |
| 4 seconds | Warning becomes active and unacknowledged |
| 8 seconds | Warning becomes acknowledged, still active |
| 12 seconds | Switch to light theme once |
| 17 seconds | Pause telemetry for an ending still |

No flashing effects are used. The demo honors the operating system's reduced
motion preference. Its sequence is based on fixed simulation ticks, not wall
clock rendering speed. Use 1440 × 1280 at 100% browser zoom to fit the entire
dashboard. Keep defaults at 2 Hz; do not combine DEMO and BENCHMARK flags.

## Generate the recording from a checkout

```sh
cd example
flutter build web --profile --dart-define=DEMO=true
cd ..
python3 -m http.server 8765 --directory example/build/web
```

In another terminal, from the package root:

```sh
npm install --prefix /tmp/industrial-browser playwright
/tmp/industrial-browser/node_modules/.bin/playwright install ffmpeg
NODE_PATH=/tmp/industrial-browser/node_modules node tool/record_demo.cjs
```

The script records installed Chrome at 1440 × 1280 to
`doc/assets/factory-monitor-showcase.webm` and captures start/end PNGs. The webm
is a repository asset, excluded from the pub.dev archive to keep downloads small.
For manual recording, run `flutter run -d chrome --dart-define=DEMO=true`, start
screen recording and reload once. Record through the ending paused state; trim
initial load frames. Use the same viewport and leave all controls untouched.

The delivered video trims the first two loading seconds. To reproduce that trim
with FFmpeg after recording (use your installed FFmpeg executable):

```sh
mv doc/assets/factory-monitor-showcase.webm /tmp/factory-monitor-raw.webm
ffmpeg -ss 2 -i /tmp/factory-monitor-raw.webm -t 18 \
  -c:v libvpx-vp9 -crf 30 -b:v 0 -an doc/assets/factory-monitor-showcase.webm
```

Playwright's macOS FFmpeg executable is normally located at
`~/Library/Caches/ms-playwright/ffmpeg-1013/ffmpeg-mac`; substitute that path for
`ffmpeg` if it is not on PATH. Inspect the opening frame if loading speed differs.
