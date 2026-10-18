import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:next_gen_yield/src/app.dart';
import 'package:next_gen_yield/src/store.dart';

void main() {
  for (final size in [const Size(1440, 1100), const Size(390, 844)]) {
    testWidgets('Capture ${size.width}', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final fonts = FontLoader('Roboto')
        ..addFont(rootBundle.load('assets/fonts/roboto-regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/roboto-medium.ttf'))
        ..addFont(rootBundle.load('assets/fonts/roboto-bold.ttf'));
      await fonts.load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = FarmStore();
      await store.load();
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: YieldApp(store: store),
        ),
      );
      await tester.pumpAndSettle();
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          'docs/${size.width > 1000 ? 'desktop' : 'mobile'}-preview.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      expect(tester.takeException(), isNull);
    });
  }
}
