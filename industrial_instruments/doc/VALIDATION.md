# 0.2.0 validation record

Checked on 2026-10-27 with Flutter 3.35.6 / Dart 3.9.2 on macOS ARM64 and installed Chrome 156. The owner separately authorized the 0.2.0 release after implementation and review.

## Automated checks

* Formatting: `dart format --output=none --set-exit-if-changed lib test example/lib`.
* Analysis: `flutter analyze`, no issues.
* Native widget tests: 20 passing, including all 33 copied integration examples.
* Chrome widget tests: 20 passing.
* Release web build: successful. Flutter's Wasm compile dry-run succeeds; Wasm runtime was not tested.
* Publishing dry-run: zero warnings; see the local `publish-dry-run.txt` log.

The main rendering matrix covers 33 instruments × two brightnesses × widths 180/360 × text scales 1/2 × seven reading states = 1,848 configurations. The states are missing, minimum, maximum, below range, above range, NaN and infinity. Separate tests cover long signed text, vertical variants, unknown contacts, per-phase semantics, snapshot immutability, explicit pressure conventions, caller-supplied volume height mapping, secondary scales, custom sweep, invalid bounds, preserved actual readings, interrupted interpolation, reduced motion, disabled TickerMode, disposal, and nine active decorative tickers.

Pixel tests verify rectangular and horizontal vessel clipping, curved-corner exclusion, empty/full states and missing data. Example snippets are generated from the gallery's real Copy code function, then compiled and rendered in a separate test. Web fixtures stay within the test directory so they also compile under Flutter's browser test runner.

## Visual inspection and interaction

The first stage rendered RadialGauge, Thermometer, CylindricalTank, ThreePhaseReadout and ValveIndicator before the collection expanded. Screenshots at 180 and 320 logical pixels in light/dark are in `assets/v020/reference-*.png`. Three-phase labels stack at compact sizes, while numeric columns remain right-aligned.

All 33 detail views were captured in both brightnesses. Representative 180px previews were inspected in a 390px mobile viewport with 2× text and missing values. Review tightened unit readability and made level rulers use engineering values; mapped horizontal volume retains explicit height-percent marks. Deviation bounds are now explicitly symmetric about their reference.

The gallery was exercised through browser input: range/unit changes, copying code, invalid range submission while retaining the previous valid configuration, missing-reading switch, animation switch and background change. `range-validation.png` records the visible validation message and unchanged dial range. Initial browser assertions were corrected for Flutter's proxy inputs and JavaScript numeric formatting; actual keyboard entry is used by the reproduction script.

The built-in browser runtime was unavailable. Inspection used installed Chrome through Playwright; no generated mockups substituted for Flutter rendering. Reproduction tools are in `tool/` and are excluded from the pub archive. Browser fullPage cannot capture offscreen content within Flutter's internal scroll surface.

## Remaining limits

* Physical Android/iOS devices, Safari/Firefox, Windows/Linux rendering, device screen readers and physical high-DPI displays were not directly reviewed.
* Semantics are tested programmatically; VoiceOver/TalkBack navigation still needs device testing.
* No production telemetry, long-running endurance, or device-capacity performance benchmark was performed. No universal FPS or supported-widget-count claim is made.
* Unit conversion, calibration, curved-vessel volume mapping, three-phase calculations and sign/leading/lagging conventions remain application responsibilities.
* Custom painted tick labels should remain short; long descriptions belong in the main label. Sizes below the per-instrument minimum are unsupported.
* The release web build emits an optional CupertinoIcons-font tree-shaker notice. The example uses Material icons, and rendered controls were inspected. No runtime dependency was added merely to silence it.
* GitHub source placement remains a separate repository action. The already-published 0.1.0 package remains unchanged.

Release correction: a final screenshot refresh captured a blank light-gallery frame in 0.2.0. The image was recaptured and visually verified for documentation-only patch 0.2.1; widget source is unchanged.
