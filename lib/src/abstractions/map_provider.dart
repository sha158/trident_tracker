import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trident_tracker/src/providers/flutter_map_provider.dart';
import 'package:trident_tracker/src/providers/google_map_provider.dart';
import 'package:trident_tracker/src/providers/osm_map_provider.dart';
import '../trident_location_marker.dart';
import '../trident_route_animation.dart';

/// Abstract interface for map providers following Open/Closed Principle
abstract class MapProvider {
  /// Initialize the map provider
  Future<void> initialize();
  
  /// Build the map widget
  Widget buildMap({
    required LatLng? initialCenter,
    required double initialZoom,
    LatLng? currentLocation,
    TridentLocationMarker? locationMarker,
    TridentRouteAnimation? routeAnimation,
    TridentRouteAnimationController? routeController,
  });
  
  /// Move map to specific location
  Future<void> moveToLocation(LatLng location);
  
  /// Update current location marker
  void updateLocationMarker(LatLng location, TridentLocationMarker? marker);
  
  /// Update route animation
  void updateRouteAnimation(TridentRouteAnimationController? controller);
  
  /// Dispose resources
  void dispose();
  
  /// Check if provider supports specific features
  bool get supportsCustomMarkers;
  bool get supportsRouteAnimation;
  bool get supportsPolylines;
}

/// Factory for creating map providers (Factory Pattern)
abstract class MapProviderFactory {
  static MapProvider create(MapType mapType, {String? apiKey}) {
    switch (mapType) {
      case MapType.flutterMap:
        return FlutterMapProvider();
      case MapType.osmPlugin:
        return OsmMapProvider();
      case MapType.googleMaps:
        if (apiKey == null) {
          throw ArgumentError('Google Maps API key is required');
        }
        return GoogleMapProvider(apiKey);
    }
  }
}

/// Map types enum
enum MapType {
  flutterMap,
  osmPlugin,
  googleMaps,
}