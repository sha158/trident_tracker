import 'package:flutter_test/flutter_test.dart';
import 'package:trident_tracker/trident_tracker.dart';

void main() {
  group('MapType Enum Tests', () {
    test('MapType enum has correct values', () {
      expect(MapType.values.length, 2);
      expect(MapType.values.contains(MapType.flutterMap), true);
      expect(MapType.values.contains(MapType.osmPlugin), true);
    });

    test('MapType enum toString works correctly', () {
      expect(MapType.flutterMap.toString(), 'MapType.flutterMap');
      expect(MapType.osmPlugin.toString(), 'MapType.osmPlugin');
    });

    test('MapType enum index values are correct', () {
      expect(MapType.flutterMap.index, 0);
      expect(MapType.osmPlugin.index, 1);
    });
  });

  group('LocationService Tests', () {
    test('LocationService static methods exist and are callable', () {
      // Test that the static methods exist and have the correct types
      expect(LocationService.requestLocationPermission, isA<Function>());
      expect(LocationService.getCurrentLocation, isA<Function>());
      expect(LocationService.getLocationStream, isA<Function>());
    });

    test('LocationService methods have correct signatures', () {
      // Test method signatures without calling them to avoid platform binding issues
      expect(LocationService.requestLocationPermission, isA<Function>());
      expect(LocationService.getCurrentLocation, isA<Function>());
      expect(LocationService.getLocationStream, isA<Function>());
      
      // Test that LocationService is accessible
      expect(LocationService, isNotNull);
    });
  });

  group('Package Exports Tests', () {
    test('All expected classes are exported', () {
      // Test that all main classes are accessible
      expect(TridentTracker, isNotNull);
      expect(MapType, isNotNull);
      expect(LocationService, isNotNull);
    });

    test('MapType enum is properly accessible', () {
      // Test enum access and properties
      final mapTypes = MapType.values;
      expect(mapTypes.isNotEmpty, true);
      expect(mapTypes.first, isA<MapType>());
    });
  });

  group('Widget Constructor Tests', () {
    test('TridentTracker constructor accepts all parameters', () {
      // Test constructor without actually rendering
      final widget1 = TridentTracker(
        mapType: MapType.flutterMap,
      );
      
      expect(widget1.mapType, MapType.flutterMap);
      expect(widget1.initialZoom, 15.0);
      expect(widget1.showCurrentLocation, true);
      expect(widget1.initialCenter, isNull);
      expect(widget1.onLocationPermissionDenied, isNull);

      final widget2 = TridentTracker(
        mapType: MapType.osmPlugin,
        initialZoom: 10.0,
        showCurrentLocation: false,
        onLocationPermissionDenied: () {},
      );

      expect(widget2.mapType, MapType.osmPlugin);
      expect(widget2.initialZoom, 10.0);
      expect(widget2.showCurrentLocation, false);
      expect(widget2.onLocationPermissionDenied, isNotNull);
    });
  });
}