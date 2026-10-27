# Industrial Instruments

33 Flutter measurement and equipment widgets, editable parameter presets, and a live component catalog.

**Use the widgets:** [Package README](industrial_instruments/README.md) · [pub.dev](https://pub.dev/packages/industrial_instruments) · [Widget examples](industrial_instruments/example/lib/catalog.dart)

**Maintain or create a package:** follow the guide below. It explains the required files, local development, validation, Git, and publication.

## Contents

- [Understand this repository](#understand-this-repository)
- [Run this package's example](#run-this-packages-example)
- [Create a new Flutter package](#create-a-new-flutter-package)
- [Mandatory publishing requirements](#mandatory-publishing-requirements)
- [Prepare documentation and upload files](#prepare-documentation-and-upload-files)
- [Validate a release](#validate-a-release)
- [Push this repository to GitHub](#push-this-repository-to-github)
- [Publish to pub.dev](#publish-to-pubdev)
- [Release updates](#release-updates)
- [Troubleshooting](#troubleshooting)

## Understand this repository

```text
Flutter Packages/                  ← Git repository root; this guide
├── README.md
├── .github/workflows/industrial-instruments.yml
└── industrial_instruments/         ← package root; publish from here
    ├── pubspec.yaml
    ├── LICENSE
    ├── README.md                   ← documentation shown on pub.dev
    ├── CHANGELOG.md
    ├── lib/industrial_instruments.dart
    ├── lib/src/
    ├── test/
    ├── doc/
    └── example/                    ← runnable app; do not publish this app
        ├── pubspec.yaml
        └── lib/
            ├── main.dart          ← run this entry point
            ├── catalog.dart       ← individual widget examples
            └── reference.dart
```

The maintained package is **`industrial_instruments`**. The GitHub repository is named **`industrial_widgets`**; these names do not have to match. The retired `industrial_widgets` and `industrial_dashboard_widgets` folders are not dependencies of this package.

The package uses the **MIT license**. Its current source version is **0.2.1**. Check [pubspec.yaml](industrial_instruments/pubspec.yaml) and the [published versions](https://pub.dev/packages/industrial_instruments/versions) before preparing another release.

## Run this package's example

Start in the repository root:

```sh
cd industrial_instruments/example
flutter pub get
flutter run -d chrome
```

Open [example/lib/main.dart](industrial_instruments/example/lib/main.dart) in your editor. Browse [catalog.dart](industrial_instruments/example/lib/catalog.dart) for individual widget usage.

To use the published package in another Flutter app, run this **inside that app**:

```sh
flutter pub add industrial_instruments
```

Then follow the [package usage examples](industrial_instruments/README.md).

## Create a new Flutter package

This tutorial is for a **separate, new package**. Do not run the scaffold commands over `industrial_instruments`.

### 1. Check your tools

Install Flutter, add its `bin` directory to your PATH, then run:

```sh
flutter --version
dart --version
flutter doctor
```

Flutter includes Dart. Resolve toolchain issues for the platforms you intend to test. This repository has been validated with Flutter 3.35.6 and Dart 3.9.2; these are project-specific versions, not a claim about the latest release.

### 2. Choose a name and package type

Choose a descriptive, available `lower_snake_case` name. Check pub.dev before committing to it. The tutorial name `sample_measurement_widgets` is only an example; availability is not guaranteed. Names must follow Dart's package-name rules. [Official pubspec specification](https://dart.dev/tools/pub/pubspec#name)

For reusable Flutter widgets, create a package. Use a plugin when you need platform-specific implementations such as Kotlin or Swift APIs. [Flutter package guide](https://docs.flutter.dev/packages-and-plugins/developing-packages)

From a directory where you keep projects:

```sh
flutter create --template=package sample_measurement_widgets
cd sample_measurement_widgets
flutter pub get
```

If you choose a different name, replace it consistently in filenames, imports, and YAML throughout this tutorial.

### 3. Implement and export a widget

Create `lib/src/measurement_readout.dart`:

```dart
import 'package:flutter/material.dart';

/// Displays a measurement, or a dash when no finite reading is available.
class MeasurementReadout extends StatelessWidget {
  /// Creates a readout with an optional value and an explicit unit.
  const MeasurementReadout({super.key, this.value, required this.unit});

  /// The current reading; null and non-finite values display as missing.
  final double? value;

  /// Unit displayed alongside the reading, such as bar or °C.
  final String unit;

  @override
  Widget build(BuildContext context) {
    final reading = value;
    final label = reading != null && reading.isFinite
        ? reading.toStringAsFixed(1)
        : '—';
    return Text('$label $unit');
  }
}
```

Replace the generated contents of `lib/sample_measurement_widgets.dart` with:

```dart
/// Small, reusable measurement widgets for Flutter.
library;

export 'src/measurement_readout.dart';
```

Consumers should import the public library:

```dart
import 'package:sample_measurement_widgets/sample_measurement_widgets.dart';
```

Keep implementation details in `lib/src/` and deliberately export the supported API. [Dart package layout](https://dart.dev/tools/pub/package-layout)

### 4. Replace the scaffold test

Replace `test/sample_measurement_widgets_test.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sample_measurement_widgets/sample_measurement_widgets.dart';

void main() {
  testWidgets('shows a reading and handles a missing measurement', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MeasurementReadout(value: 12.5, unit: 'bar')),
    );
    expect(find.text('12.5 bar'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(home: MeasurementReadout(unit: 'bar')),
    );
    expect(find.text('— bar'), findsOneWidget);
  });
}
```

Remove any remaining tests that refer to the deleted scaffold class. Add coverage for your real widget behavior, boundaries, accessibility, and layout as the package grows.

### 5. Create a runnable example

From the new package root:

```sh
flutter create --platforms=web example
```

This creates a web example. Add other platforms when you intend to demonstrate and test them.

In `example/pubspec.yaml`, keep the generated Flutter dependency and add the local package dependency. Ensure the app has `publish_to: none`:

```yaml
publish_to: none

dependencies:
  flutter:
    sdk: flutter
  sample_measurement_widgets:
    path: ../
```

Merge these fields into the file; do not create duplicate `dependencies` sections or replace the entire file with this fragment.

Replace `example/lib/main.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:sample_measurement_widgets/sample_measurement_widgets.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(child: MeasurementReadout(value: 12.5, unit: 'bar')),
      ),
    ),
  );
}
```

Replace the example's generated counter test with a test for this screen, or remove that obsolete scaffold test before analyzing. Then:

```sh
cd example
flutter pub get
flutter run -d chrome
```

Stop the app, then return to the package root with `cd ..`.

### 6. Configure the package metadata

For this tutorial, the following is a starting `pubspec.yaml`. The SDK minimums match this repository's baseline; choose and test constraints appropriate to your own code.

```yaml
name: sample_measurement_widgets
description: Simple Flutter measurement readouts with explicit units and clear handling of missing values for dashboard interfaces.
version: 0.1.0

environment:
  sdk: '>=3.9.0 <4.0.0'
  flutter: '>=3.35.0'

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

Add a real `repository` and `issue_tracker` URL when available. Do not publish placeholder links. The existing package already has the correct GitHub URLs in its pubspec.

Omit `publish_to` in the publishable package to use pub.dev. Keep `publish_to: none` in the example app. Metadata fields and their rules are documented in the [pubspec reference](https://dart.dev/tools/pub/pubspec).

## Mandatory publishing requirements

These are publishing requirements, separate from the quality checks recommended below.

| Requirement | What to check |
| --- | --- |
| Valid metadata | A valid package name, version, description, and SDK environment constraints in the package-root `pubspec.yaml`. |
| Available name or upload permission | A new name must be available; an existing package requires an authorized uploader. |
| Unused release version | A published version cannot be replaced. Select a new version for each upload. |
| License and redistribution rights | Include the full license in the package-root `LICENSE`; you must have permission to distribute all included code and assets. |
| Supported dependencies | Published library dependencies must use the default hosted package server or an SDK. Replace runtime Git/path dependencies before publication. |
| Authentication | For the manual workflow here, sign in with a Google account that can upload the package. |
| Publishable configuration | The library must not have `publish_to: none`; satisfy the publisher's validation and archive limits. |

See the official [publishing requirements](https://dart.dev/tools/pub/publishing), [metadata rules](https://dart.dev/tools/pub/pubspec), and [versioning rules](https://dart.dev/tools/pub/versioning).

The local `path: ../` dependency in the private example app is intentional. It lets the example test the library being developed.

**Recommended for a usable release:** a useful README, a CHANGELOG, documented public APIs, working examples, meaningful tests, clean analysis, accurate platform claims, and repository/support links. Screenshots, a verified publisher, GitHub hosting, and a perfect pub score are not mandatory prerequisites for a manual upload. A verified publisher is useful for publishing under an organization/domain identity. [Publishing guide](https://dart.dev/tools/pub/publishing)

## Prepare documentation and upload files

The root README you are reading is a repository guide. **pub.dev reads the README inside the package being uploaded**: [industrial_instruments/README.md](industrial_instruments/README.md).

For a new package, prepare:

| File | Contents |
| --- | --- |
| `README.md` | Purpose, installation, a working import/usage example, supported features, limitations, and links. |
| `CHANGELOG.md` | A heading for each version and concise user-visible changes. |
| `LICENSE` | Full license text, with correct copyright attribution. This project uses MIT. |
| `example/` | A small app that demonstrates the public API. |
| `test/` | Tests for observable behavior and important edge cases. |

Document public APIs with `///` comments. Open README images at their actual paths to check that they render and contain the intended content.

Review `.gitignore` and `.pubignore`. A `.pubignore` takes precedence over a `.gitignore` in the same directory, so repeat needed exclusions rather than assuming the two files are combined. [Upload-file selection](https://dart.dev/tools/pub/publishing#what-files-are-published)

A starting `.pubignore` for a small package could contain:

```gitignore
.dart_tool/
build/
coverage/
.DS_Store
example/.dart_tool/
example/build/
```

Adapt it to your project. Keep source, license, documentation, required assets, and useful examples. Exclude local credentials and generated output. This repository already has a tailored [package .pubignore](industrial_instruments/.pubignore); review it rather than replacing it with this basic template.

## Validate a release

For this repository, start at the repository root:

```sh
cd industrial_instruments
flutter pub get
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze
flutter test
```

If the formatting check fails, run `dart format lib test example/lib`, inspect the changes, and repeat the check.

Validate the example:

```sh
cd example
flutter pub get
flutter build web --release
cd ..
```

Also run the example interactively and inspect the screens affected by your change. A successful build does not verify visual appearance.

Now inspect the proposed upload from the **package root**:

```sh
flutter pub publish --dry-run
```

Review the file list, version, package name, size, and diagnostics. Resolve errors and investigate warnings. The dry run does not upload anything. [Publish command reference](https://dart.dev/tools/pub/cmd/pub-lish)

Our release checklist:

- [ ] Version and CHANGELOG describe the intended release.
- [ ] License, metadata, URLs, imports, and README examples are correct.
- [ ] Formatting, analysis, and relevant tests pass.
- [ ] Example builds and affected screens have been inspected.
- [ ] Platform claims match actual support and testing.
- [ ] Screenshots are readable and the archive includes their files.
- [ ] Dry run succeeds; upload list contains only intended files.

[GitHub Actions](.github/workflows/industrial-instruments.yml) runs package checks and builds the web example. **It does not publish releases.**

## Push this repository to GitHub

GitHub stores the source history. pub.dev distributes package releases. Pushing to GitHub does not upload a package to pub.dev, and a Git push is not a prerequisite for manual publication.

From the **repository root**, review the changes first:

```sh
git status
git diff
git remote -v
```

The configured remote for this repository is:

```text
https://github.com/Appu-Devloper/industrial_widgets.git
```

When every listed change is intended, stage, commit, and push:

```sh
git add -A
git commit -m "Maintain industrial_instruments and document package publishing"
git push origin main
```

`git add -A` includes new files and deletions, including removal of the retired packages. Inspect `git diff --cached` before committing if you need another review. Do not repeat `git init` or add an already configured `origin` in this repository.

## Publish to pub.dev

### 1. Select the release

Check the package's published versions and local `pubspec.yaml`. **Do not upload 0.2.1 again if it is already published.** For a new package, use your chosen initial version; for an update, follow the next section first.

### 2. Run the upload command

After completing the release checks, run from the package root:

```sh
flutter pub publish
```

For this repository, that directory is `industrial_instruments/`. Review the CLI summary and answer its upload confirmation only when the package and version are correct.

### 3. Authorize the CLI when prompted

Sign in with the Google account that owns or can upload the package. If the browser does not open automatically, copy the **fresh authorization URL printed by the running command** into your browser and complete authorization. Keep the terminal process running and return to it afterward.

Do not reuse an old authorization URL or share account tokens. If the command has exited, rerun it and use the new prompt. Existing CLI authorization may make another browser sign-in unnecessary.

### 4. Confirm the result

Wait for the terminal's successful publication message. Then check:

- [Package page](https://pub.dev/packages/industrial_instruments)
- [Published versions](https://pub.dev/packages/industrial_instruments/versions)

For a different package, substitute its name in these URLs. Search, analysis, and page updates can take a few minutes after a successful upload. [Publish command behavior](https://dart.dev/tools/pub/cmd/pub-lish)

Test installation in a separate Flutter app using `flutter pub add industrial_instruments` and confirm the resolved version in that app's lockfile. A local example using `path: ../` verifies your working tree, not the uploaded archive.

## Release updates

Published versions are immutable. Update the source, increment `version` in the package pubspec, add the matching CHANGELOG entry, repeat validation, and publish the new version. [Dart versioning](https://dart.dev/tools/pub/versioning)

| Change | Example version change |
| --- | --- |
| Compatible fix to this pre-1.0 package | `0.2.1` → `0.2.2` |
| Breaking API change before 1.0 | `0.2.1` → `0.3.0` |
| Compatible fix after 1.0 | `1.0.0` → `1.0.1` |
| Compatible feature after 1.0 | `1.0.0` → `1.1.0` |
| Breaking API change after 1.0 | `1.0.0` → `2.0.0` |

Before 1.0, Dart treats a minor-version increase as potentially breaking. Describe compatibility clearly in the CHANGELOG. Decide the version based on the actual change; the examples above are not instructions to change this repository's version now.

Commit the release source and optionally tag it so the published archive can be traced back to a revision. Use a new tag per release and keep the repository and release documentation aligned.

## Troubleshooting

| Problem | Action |
| --- | --- |
| No `pubspec.yaml` found | Move into `industrial_instruments/`, not the repository root. |
| Publication disabled | Check whether you are inside `example/`. Keep that app's `publish_to: none`; publish the library instead. |
| Name unavailable | Choose another name for a new package, or obtain uploader access for the existing one. |
| Version already exists | Increment the version and update the CHANGELOG. Existing versions cannot be overwritten. |
| Browser did not open | Use the new authorization URL from the active CLI command. |
| Permission denied | Check that the signed-in account has uploader access to this package or its publisher. |
| Unsupported dependency | Replace the published library's Git/path dependency with a hosted or SDK dependency. |
| Scaffold test fails | Replace the generated sample test when replacing its generated class or example screen. |
| README image missing | Check relative path, filename case, and inclusion in the dry-run archive listing. |
| Git has uncommitted changes | Review and commit the intended release source so the uploaded code can be reproduced. |
| pub.dev still shows an older version | Check the terminal result and versions page; allow time for indexing before retrying. |

For widget-specific development, see [CONTRIBUTING](industrial_instruments/CONTRIBUTING.md), [migration notes](industrial_instruments/doc/MIGRATION.md), and the [package documentation](industrial_instruments/README.md).
