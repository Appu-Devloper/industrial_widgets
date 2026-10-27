import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:industrial_instruments/industrial_instruments.dart';
import 'package:industrial_instruments/src/rendering.dart';
import 'instruments_test.dart' show host;

void main() {
  testWidgets('liquid is clipped inside the vessel and missing does not fill', (
    t,
  ) async {
    const boundary = ValueKey('pixels');
    Widget fixture(double? value) => host(
      RepaintBoundary(
        key: boundary,
        child: ColoredBox(
          color: Colors.white,
          child: LiquidTank(
            value: value,
            width: 240,
            height: 200,
            style: const LevelStyle(
              accent: Colors.red,
              foreground: Colors.black,
              showMarks: false,
            ),
          ),
        ),
      ),
    );
    Future<List<int>> pixel(int x, int y) async {
      final image =
          await (t.renderObject(find.byKey(boundary)) as RenderRepaintBoundary)
              .toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final offset = (y * image.width + x) * 4;
      final result = bytes!.buffer.asUint8List().sublist(offset, offset + 4);
      image.dispose();
      return result;
    }

    await t.pumpWidget(fixture(50));
    await t.pump();
    expect(await t.runAsync(() => pixel(15, 150)), [255, 255, 255, 255]);
    expect(await t.runAsync(() => pixel(120, 40)), [255, 255, 255, 255]);
    final filled = await t.runAsync(() => pixel(120, 150));
    expect(filled![0], greaterThan(filled[1]));
    await t.pumpWidget(fixture(null));
    await t.pump();
    expect(await t.runAsync(() => pixel(120, 150)), [255, 255, 255, 255]);
  });
  testWidgets(
    'all running equipment and liquid dispose without active tickers',
    (t) async {
      await t.pumpWidget(
        host(
          Column(
            children: [
              const PumpIndicator(state: EquipmentState.running, animate: true),
              const MotorIndicator(
                state: EquipmentState.running,
                animate: true,
              ),
              const FanIndicator(state: EquipmentState.running, animate: true),
              const ConveyorIndicator(
                state: EquipmentState.running,
                animate: true,
              ),
              PipeFlow(
                path: const [Offset(0, 0), Offset(1, 1)],
                state: EquipmentState.running,
                animate: true,
              ),
              const FlowIndicator(
                value: 40,
                state: EquipmentState.running,
                animate: true,
              ),
              const RotationIndicator(
                value: 1200,
                state: EquipmentState.running,
                animate: true,
              ),
              const BatteryIndicator(
                value: 50,
                activity: BatteryActivity.charging,
                animate: true,
              ),
              const LiquidTank(
                value: 50,
                animate: true,
                style: LevelStyle(waves: true),
              ),
            ],
          ),
        ),
      );
      await t.pump(const Duration(milliseconds: 500));
      expect(t.binding.transientCallbackCount, greaterThanOrEqualTo(9));
      for (final paint
          in t
              .widgetList<CustomPaint>(find.byType(CustomPaint))
              .map((w) => w.painter)
              .whereType<InstrumentPainter>()) {
        expect(paint.phase.value, inExclusiveRange(0, 1));
      }
      await t.pumpWidget(const SizedBox());
      await t.pump();
      expect(t.binding.transientCallbackCount, 0);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'horizontal tank clips curved ends and distinguishes empty/full',
    (t) async {
      const key = ValueKey('horizontal-pixels');
      Widget fixture(double v) => host(
        RepaintBoundary(
          key: key,
          child: ColoredBox(
            color: Colors.white,
            child: HorizontalTank(
              value: v,
              width: 240,
              height: 140,
              style: const LevelStyle(
                accent: Colors.red,
                foreground: Colors.black,
                showMarks: false,
              ),
            ),
          ),
        ),
      );
      Future<List<int>> pixel(int x, int y) async {
        final image =
            await (t.renderObject(find.byKey(key)) as RenderRepaintBoundary)
                .toImage(pixelRatio: 1);
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        final result = bytes!.buffer.asUint8List().sublist(
          (y * image.width + x) * 4,
          (y * image.width + x) * 4 + 4,
        );
        image.dispose();
        return result;
      }

      await t.pumpWidget(fixture(100));
      await t.pump();
      expect(await t.runAsync(() => pixel(15, 20)), [255, 255, 255, 255]);
      final full = await t.runAsync(() => pixel(120, 25));
      expect(full![0], greaterThan(full[1]));
      await t.pumpWidget(fixture(0));
      await t.pump();
      expect(await t.runAsync(() => pixel(120, 100)), [255, 255, 255, 255]);
    },
  );
}
