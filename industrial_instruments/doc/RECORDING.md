# Reproducible showcase recording

The PNGs in `doc/assets/v020/` are actual Flutter renders, not design mockups. A GIF is not included; reproduce a short showcase as follows.

1. Run `flutter run -d chrome --web-port=8767 --release` from `example/`. Stop an existing server on that port or choose another port.
2. Use a 1280 × 900 browser viewport, 100% zoom. Start your operating system's screen recorder on the browser content area.
3. Open `http://localhost:8767/?widget=0&animate=true` and record 5 seconds of the radial dial.
4. Open `/?widget=13&theme=dark&animate=true` and record 5 seconds of the cylinder level.
5. Open `/?widget=19&theme=dark&animate=true` and record 5 seconds of the rotation indicator.
6. Open `/?widget=23&theme=dark`, record the three phase values, then toggle Missing reading.
7. Open `/?widget=32`, move the slider to switch the contact, then stop recording.

The demo uses `min + (max − min) × (0.55 + 0.25 × sin(tick / 16))` at 150 ms intervals, with tick reset on reload. Decorative cycles are independent of displayed speed. Export at 12–15 fps as GIF or use WebM/MP4. Preserve real labels so the demonstration reflects the package.

For PNG reproduction, build `example` with `flutter build web --release` and serve `example/build/web` at localhost:8767. Install Playwright in a tooling directory and set NODE_PATH to its node_modules. Run:

```sh
node tool/reference020.cjs
node tool/gallery020.cjs
node tool/interact020.cjs
```

The scripts use installed Chrome and are excluded from the package archive. Flutter canvas scrolling is internal: browser fullPage screenshots do not capture the entire scrolled catalog. Screenshot queries support widget=0…32, theme=dark, width=180, scale=2, missing=true, orientation=vertical and animate=true. `reference=1` opens the initial five-instrument studies.
