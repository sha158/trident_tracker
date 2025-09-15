import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osm;
import 'package:latlong2/latlong.dart';

import '../abstractions/map_provider.dart';
import '../trident_location_marker.dart';
import '../trident_route_animation.dart';

/// OSM Plugin implementation following Single Responsibility Principle
class OsmMapProvider implements MapProvider {
  late osm.MapController _osmController;
  
  @override
  Future<void> initialize() async {
    _osmController = osm.MapController(
      initMapWithUserPosition: osm.UserTrackingOption(
        enableTracking: true,
        unFollowUser: false,
      ),
    );
  }
  
  @override
  Widget buildMap({
    required LatLng? initialCenter,
    required double initialZoom,
    LatLng? currentLocation,
    TridentLocationMarker? locationMarker,
    TridentRouteAnimation? routeAnimation,
    TridentRouteAnimationController? routeController,
  }) {
    return osm.OSMFlutter(
      controller: _osmController,
      osmOption: osm.OSMOption(
        userTrackingOption: const osm.UserTrackingOption(
          enableTracking: true,
          unFollowUser: false,
        ),
        zoomOption: osm.ZoomOption(
          initZoom: initialZoom,
          minZoomLevel: 3,
          maxZoomLevel: 19,
          stepZoom: 1.0,
        ),
        userLocationMarker: _buildOSMUserLocationMarker(locationMarker),
        roadConfiguration: const osm.RoadOption(
          roadColor: Colors.yellowAccent,
        ),
      ),
    );
  }
  
  @override
  Future<void> moveToLocation(LatLng location) async {
    try {
      await _osmController.moveTo(
        osm.GeoPoint(
          latitude: location.latitude,
          longitude: location.longitude,
        ),
      );
    } catch (e) {
      // Handle error silently as OSM controller can be temperamental
      debugPrint('OSM move error: $e');
    }
  }
  
  @override
  void updateLocationMarker(LatLng location, TridentLocationMarker? marker) {
    // OSM plugin handles user location marker internally
  }
  
  @override
  void updateRouteAnimation(TridentRouteAnimationController? controller) {
    // OSM plugin has limited route animation support
    // This would require custom implementation with road drawing
  }
  
  osm.UserLocationMaker _buildOSMUserLocationMarker(
    TridentLocationMarker? marker,
  ) {
    if (marker == null) {
      return osm.UserLocationMaker(
        personMarker: const osm.MarkerIcon(
          icon: Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 48,
          ),
        ),
        directionArrowMarker: const osm.MarkerIcon(
          icon: Icon(
            Icons.navigation,
            color: Colors.blue,
            size: 48,
          ),
        ),
      );
    }
    
    IconData iconData;
    Color iconColor;
    double iconSize;
    
    switch (marker.type) {
      case TridentLocationMarkerType.asset:
        // OSM plugin doesn't support asset images directly
        iconData = Icons.my_location;
        iconColor = marker.color ?? Colors.blue;
        iconSize = marker.size.width.clamp(24.0, 72.0);
        break;
        
      case TridentLocationMarkerType.widget:
        // OSM plugin doesn't support custom widgets
        iconData = Icons.my_location;
        iconColor = Colors.blue;
        iconSize = 48.0;
        break;
        
      case TridentLocationMarkerType.defaultIcon:
      case TridentLocationMarkerType.pulsing:
        iconData = Icons.my_location;
        iconColor = marker.color ?? Colors.blue;
        iconSize = marker.size.width.clamp(24.0, 72.0);
        break;
    }
    
    return osm.UserLocationMaker(
      personMarker: osm.MarkerIcon(
        icon: Icon(
          iconData,
          color: iconColor,
          size: iconSize,
        ),
      ),
      directionArrowMarker: osm.MarkerIcon(
        icon: Icon(
          Icons.navigation,
          color: iconColor,
          size: iconSize * 0.8,
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _osmController.dispose();
  }
  
  @override
  bool get supportsCustomMarkers => false; // Limited support
  
  @override
  bool get supportsRouteAnimation => false; // Limited support
  
  @override
  bool get supportsPolylines => true; // Through road drawing API
}