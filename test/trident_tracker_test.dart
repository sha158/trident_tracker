import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trident_tracker/trident_tracker.dart';

void main() {
  group('MapType Enum Tests', () {
    test('MapType enum has correct values', () {
      expect(MapType.values.length, 3);
      expect(MapType.values.contains(MapType.flutterMap), true);
      expect(MapType.values.contains(MapType.osmPlugin), true);
      expect(MapType.values.contains(MapType.googleMaps), true);
    });

    test('MapType enum toString works correctly', () {
      expect(MapType.flutterMap.toString(), 'MapType.flutterMap');
      expect(MapType.osmPlugin.toString(), 'MapType.osmPlugin');
      expect(MapType.googleMaps.toString(), 'MapType.googleMaps');
    });

    test('MapType enum index values are correct', () {
      expect(MapType.flutterMap.index, 0);
      expect(MapType.osmPlugin.index, 1);
      expect(MapType.googleMaps.index, 2);
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
    test('TridentTracker constructor accepts all parameters for non-Google maps', () {
      // Test constructor without actually rendering
      final widget1 = TridentTracker(
        mapType: MapType.flutterMap,
      );
      
      expect(widget1.mapType, MapType.flutterMap);
      expect(widget1.initialZoom, 15.0);
      expect(widget1.showCurrentLocation, true);
      expect(widget1.initialCenter, isNull);
      expect(widget1.locationMarker, isNull);
      expect(widget1.onLocationPermissionDenied, isNull);
      expect(widget1.googleMapsApiKey, isNull);

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
      expect(widget2.googleMapsApiKey, isNull);
      expect(widget2.locationMarker, isNull);
    });

    test('TridentTracker constructor accepts Google Maps with API key', () {
      final widget = TridentTracker(
        mapType: MapType.googleMaps,
        googleMapsApiKey: "test-api-key",
        initialZoom: 12.0,
      );

      expect(widget.mapType, MapType.googleMaps);
      expect(widget.googleMapsApiKey, "test-api-key");
      expect(widget.initialZoom, 12.0);
    });

    test('TridentTracker throws assertion error for Google Maps without API key', () {
      expect(
        () => TridentTracker(
          mapType: MapType.googleMaps,
          // Missing googleMapsApiKey
        ),
        throwsAssertionError,
      );
    });

    test('TridentTracker throws assertion error for Google Maps with empty API key', () {
      expect(
        () => TridentTracker(
          mapType: MapType.googleMaps,
          googleMapsApiKey: "", // Empty API key
        ),
        throwsAssertionError,
      );
    });

    test('TridentTracker accepts custom location marker', () {
      final customMarker = TridentLocationMarker.defaultRed(
        size: const Size(50, 50),
        title: 'Custom Marker',
      );

      final widget = TridentTracker(
        mapType: MapType.flutterMap,
        locationMarker: customMarker,
      );

      expect(widget.locationMarker, isNotNull);
      expect(widget.locationMarker!.type, TridentLocationMarkerType.defaultIcon);
      expect(widget.locationMarker!.color, Colors.red);
      expect(widget.locationMarker!.size, const Size(50, 50));
      expect(widget.locationMarker!.title, 'Custom Marker');
    });
  });

  group('TridentLocationMarker Tests', () {
    test('TridentLocationMarker.defaultBlue creates correct marker', () {
      final marker = TridentLocationMarker.defaultBlue(
        title: 'Blue Marker',
        description: 'Test description',
      );

      expect(marker.type, TridentLocationMarkerType.defaultIcon);
      expect(marker.color, Colors.blue);
      expect(marker.title, 'Blue Marker');
      expect(marker.description, 'Test description');
      expect(marker.size, const Size(40, 40));
    });

    test('TridentLocationMarker.fromAsset creates correct marker', () {
      final marker = TridentLocationMarker.fromAsset(
        'assets/marker.png',
        size: const Size(60, 60),
      );

      expect(marker.type, TridentLocationMarkerType.asset);
      expect(marker.assetPath, 'assets/marker.png');
      expect(marker.size, const Size(60, 60));
    });

    test('TridentLocationMarker.fromWidget creates correct marker', () {
      const testWidget = Icon(Icons.location_on);
      final marker = TridentLocationMarker.fromWidget(
        testWidget,
        title: 'Widget Marker',
      );

      expect(marker.type, TridentLocationMarkerType.widget);
      expect(marker.widget, testWidget);
      expect(marker.title, 'Widget Marker');
    });

    test('TridentLocationMarker.pulsing creates correct marker', () {
      final marker = TridentLocationMarker.pulsing(
        color: Colors.green,
        size: const Size(45, 45),
      );

      expect(marker.type, TridentLocationMarkerType.pulsing);
      expect(marker.color, Colors.green);
      expect(marker.size, const Size(45, 45));
    });
  });

  group('TridentRouteAnimation Tests', () {
    test('TridentRouteAnimation constructor accepts all parameters', () {
      const startPoint = LatLng(37.7749, -122.4194);
      const endPoint = LatLng(37.7849, -122.4094);
      const waypoints = [LatLng(37.7799, -122.4144)];
      const duration = Duration(seconds: 15);
      
      final routeAnimation = TridentRouteAnimation(
        startPoint: startPoint,
        endPoint: endPoint,
        waypoints: waypoints,
        duration: duration,
        autoStart: true,
        showPolyline: true,
        polylineColor: Colors.blue,
        polylineWidth: 3.0,
      );

      expect(routeAnimation.startPoint, startPoint);
      expect(routeAnimation.endPoint, endPoint);
      expect(routeAnimation.waypoints, waypoints);
      expect(routeAnimation.duration, duration);
      expect(routeAnimation.autoStart, true);
      expect(routeAnimation.showPolyline, true);
      expect(routeAnimation.polylineColor, Colors.blue);
      expect(routeAnimation.polylineWidth, 3.0);
    });

    test('TridentRouteAnimation.vehicle creates correct configuration', () {
      const startPoint = LatLng(37.7749, -122.4194);
      const endPoint = LatLng(37.7849, -122.4094);
      
      final routeAnimation = TridentRouteAnimation.vehicle(
        startPoint: startPoint,
        endPoint: endPoint,
        duration: const Duration(seconds: 10),
      );

      expect(routeAnimation.startPoint, startPoint);
      expect(routeAnimation.endPoint, endPoint);
      expect(routeAnimation.duration, const Duration(seconds: 10));
      expect(routeAnimation.autoStart, true);
      expect(routeAnimation.showPolyline, true);
      expect(routeAnimation.polylineColor, Colors.blue);
      expect(routeAnimation.animatedMarker, isNotNull);
    });

    test('TridentRouteAnimation.delivery creates correct configuration', () {
      const startPoint = LatLng(37.7749, -122.4194);
      const endPoint = LatLng(37.7849, -122.4094);
      
      final routeAnimation = TridentRouteAnimation.delivery(
        startPoint: startPoint,
        endPoint: endPoint,
      );

      expect(routeAnimation.startPoint, startPoint);
      expect(routeAnimation.endPoint, endPoint);
      expect(routeAnimation.duration, const Duration(seconds: 12));
      expect(routeAnimation.autoStart, true);
      expect(routeAnimation.showPolyline, true);
      expect(routeAnimation.polylineColor, Colors.green);
      expect(routeAnimation.polylineWidth, 4.0);
      expect(routeAnimation.animatedMarker, isNotNull);
    });

    test('TridentRouteAnimation.walking creates correct configuration', () {
      const startPoint = LatLng(37.7749, -122.4194);
      const endPoint = LatLng(37.7849, -122.4094);
      
      final routeAnimation = TridentRouteAnimation.walking(
        startPoint: startPoint,
        endPoint: endPoint,
      );

      expect(routeAnimation.startPoint, startPoint);
      expect(routeAnimation.endPoint, endPoint);
      expect(routeAnimation.duration, const Duration(seconds: 20));
      expect(routeAnimation.autoStart, true);
      expect(routeAnimation.showPolyline, true);
      expect(routeAnimation.polylineColor, Colors.orange);
      expect(routeAnimation.polylineWidth, 2.0);
      expect(routeAnimation.curve, TridentAnimationCurve.linear);
      expect(routeAnimation.animatedMarker, isNotNull);
      expect(routeAnimation.animatedMarker!.type, TridentLocationMarkerType.pulsing);
    });

    test('TridentAnimationCurve enum has correct values', () {
      expect(TridentAnimationCurve.values.length, 6);
      expect(TridentAnimationCurve.values.contains(TridentAnimationCurve.linear), true);
      expect(TridentAnimationCurve.values.contains(TridentAnimationCurve.easeIn), true);
      expect(TridentAnimationCurve.values.contains(TridentAnimationCurve.easeOut), true);
      expect(TridentAnimationCurve.values.contains(TridentAnimationCurve.easeInOut), true);
      expect(TridentAnimationCurve.values.contains(TridentAnimationCurve.bounceIn), true);
      expect(TridentAnimationCurve.values.contains(TridentAnimationCurve.bounceOut), true);
    });
  });

  group('TridentTracker with Route Animation Tests', () {
    test('TridentTracker accepts routeAnimation parameter', () {
      final routeAnimation = TridentRouteAnimation.vehicle(
        startPoint: const LatLng(37.7749, -122.4194),
        endPoint: const LatLng(37.7849, -122.4094),
      );

      final widget = TridentTracker(
        mapType: MapType.flutterMap,
        routeAnimation: routeAnimation,
      );

      expect(widget.routeAnimation, isNotNull);
      expect(widget.routeAnimation!.startPoint, const LatLng(37.7749, -122.4194));
      expect(widget.routeAnimation!.endPoint, const LatLng(37.7849, -122.4094));
      expect(widget.routeAnimation!.autoStart, true);
    });

    test('TridentTracker works with route animation and location marker together', () {
      final locationMarker = TridentLocationMarker.defaultBlue();
      final routeAnimation = TridentRouteAnimation.delivery(
        startPoint: const LatLng(40.7589, -73.9851),
        endPoint: const LatLng(40.7489, -73.9851),
      );

      final widget = TridentTracker(
        mapType: MapType.flutterMap,
        locationMarker: locationMarker,
        routeAnimation: routeAnimation,
        showCurrentLocation: true,
      );

      expect(widget.locationMarker, isNotNull);
      expect(widget.routeAnimation, isNotNull);
      expect(widget.showCurrentLocation, true);
      expect(widget.routeAnimation!.polylineColor, Colors.green);
    });

    test('TridentTracker route animation works with Google Maps', () {
      final routeAnimation = TridentRouteAnimation.walking(
        startPoint: const LatLng(37.7749, -122.4194),
        endPoint: const LatLng(37.7849, -122.4094),
      );

      final widget = TridentTracker(
        mapType: MapType.googleMaps,
        googleMapsApiKey: "test-api-key",
        routeAnimation: routeAnimation,
      );

      expect(widget.mapType, MapType.googleMaps);
      expect(widget.googleMapsApiKey, "test-api-key");
      expect(widget.routeAnimation, isNotNull);
      expect(widget.routeAnimation!.curve, TridentAnimationCurve.linear);
    });
  });
}