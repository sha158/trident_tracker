import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trident_tracker/trident_tracker.dart';

void main() {
  group('TridentTracker Widget Tests', () {
    testWidgets('TridentTracker widget should build with flutter_map', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TridentTracker(
              mapType: MapType.flutterMap,
              showCurrentLocation: false,
            ),
          ),
        ),
      );

      expect(find.byType(TridentTracker), findsOneWidget);
    });

    testWidgets('TridentTracker widget should build with osm_plugin', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TridentTracker(
              mapType: MapType.osmPlugin,
              showCurrentLocation: false,
            ),
          ),
        ),
      );

      expect(find.byType(TridentTracker), findsOneWidget);
    });

    testWidgets('TridentTracker shows loading indicator when getting location', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TridentTracker(
              mapType: MapType.flutterMap,
              showCurrentLocation: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Getting your location...'), findsOneWidget);
    });
  });

  group('MapType Enum Tests', () {
    test('MapType enum has correct values', () {
      expect(MapType.values.length, 2);
      expect(MapType.values.contains(MapType.flutterMap), true);
      expect(MapType.values.contains(MapType.osmPlugin), true);
    });
  });
}
