# Instrument Catalog

Run `flutter pub get` and `flutter run -d chrome` in this directory. Choose a measurement category or any instrument to open its detail view.

Detail controls include value, explicit range/unit, accent color, background, missing data and deterministic animation. Relevant instruments expose orientation, direction and observed state. Invalid range edits show a message and retain the prior valid configuration. CenterZeroMeter edits a positive extent; its negative bound mirrors that extent. The example does not convert units.

Reproducible URL options: `widget=0` through `32`, `theme=dark`, `value=68`, `missing=true`, `animate=true`, `orientation=vertical`, `width=180`, and `scale=2`. Use `reference=1` for the first five visual studies. The left title or Collection button returns to the catalog.

No charts, histories, networking or machine-control commands are included. The optional timer simulates values only in the example and is disposed with the application state.
