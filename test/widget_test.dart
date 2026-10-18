import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:next_gen_yield/src/app.dart';
import 'package:next_gen_yield/src/store.dart';
import 'package:next_gen_yield/src/workflows.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('farm mutations and preferences survive reload', () async {
    final store = FarmStore();
    await store.load();
    store.addField(FarmField(id: 'test', name: 'South Plot', acres: 3.4));
    store.field.sown = DateTime.now();
    store.saveScan(store.field, 2);
    store.toggleTask('moisture', 'Soil moisture checked');
    store.adopt('The balanced approach');
    store.language = 'اردو';
    store.largeText = true;
    await store.save();
    final restored = FarmStore();
    await restored.load();
    expect(restored.field.name, 'South Plot');
    expect(restored.field.stage, 2);
    expect(restored.field.observations.length, 3);
    expect(restored.plans['test'], 'The balanced approach');
    expect(restored.completed, contains('test:moisture'));
    expect(restored.language, 'اردو');
    expect(restored.largeText, isTrue);
    restored.toggleTask('moisture', 'Soil moisture checked');
    expect(restored.field.observations.length, 2);
  });

  test('boundary rejects crossing, repeated and degenerate polygons', () {
    expect(
      isSimplePolygon([
        const Offset(0, 0),
        const Offset(1, 0),
        const Offset(1, 1),
        const Offset(0, 1),
      ]),
      isTrue,
    );
    expect(
      polygonArea([
        const Offset(0, 0),
        const Offset(1, 0),
        const Offset(1, 1),
        const Offset(0, 1),
      ]),
      1,
    );
    expect(
      isSimplePolygon([
        const Offset(0, 0),
        const Offset(1, 1),
        const Offset(1, 0),
        const Offset(0, 1),
      ]),
      isFalse,
    );
    expect(
      isSimplePolygon([
        const Offset(0, 0),
        const Offset(0, 0),
        const Offset(1, 1),
      ]),
      isFalse,
    );
  });

  testWidgets('mobile navigation and demo scan save an observation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = FarmStore();
    await store.load();
    await tester.pumpWidget(YieldApp(store: store));
    await tester.pumpAndSettle();
    expect(find.text('Good things are growing.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Scan').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('analyze-scan')));
    await tester.tap(find.byKey(const Key('analyze-scan')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.ensureVisible(find.byKey(const Key('save-scan')));
    await tester.tap(find.byKey(const Key('save-scan')));
    await tester.pumpAndSettle();
    expect(store.field.observations.length, 4);
    await tester.tap(find.text('Fields').last);
    await tester.pumpAndSettle();
    expect(find.text('Small fields. Big possibilities.'), findsOneWidget);
    await tester.tap(find.text('Discover').last);
    await tester.pumpAndSettle();
    expect(find.text('Better harvests, together.'), findsOneWidget);
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.text('Your farm, your way.'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Good things are growing.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('add field validates name and saves a boundary', (tester) async {
    final store = FarmStore();
    await store.load();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AddFieldDialog(store: store)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('save-field')));
    await tester.tap(find.byKey(const Key('save-field')));
    await tester.pumpAndSettle();
    expect(
      find.text('Give your field a name of at least 2 characters.'),
      findsOneWidget,
    );
    await tester.enterText(find.byKey(const Key('field-name')), 'South Meadow');
    await tester.ensureVisible(find.byKey(const Key('save-field')));
    await tester.tap(find.byKey(const Key('save-field')));
    await tester.pumpAndSettle();
    expect(store.field.name, 'South Meadow');
    expect(store.field.boundary.length, 4);
    expect(store.field.active, isFalse);
  });

  for (final size in [const Size(1440, 1100), const Size(360, 800)]) {
    testWidgets('responsive overview ${size.width}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = FarmStore();
      await store.load();
      await tester.pumpWidget(YieldApp(store: store));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      store.largeText = true;
      await store.save();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
