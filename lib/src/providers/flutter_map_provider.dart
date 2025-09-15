import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart';

import '../abstractions/map_provider.dart';
import '../trident_location_marker.dart';
import '../trident_route_animation.dart';
import '../marker_widgets.dart';

/// Flutter Map implementation following Single Responsibility Principle
class FlutterMapProvider implements MapProvider {
  flutter_map.MapController? _mapController;
  
  @override
  Future<void> initialize() async {
    _mapController = flutter_map.MapController();
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
    final center = currentLocation ?? 
        initialCenter ?? 
        const LatLng(37.7749, -122.4194);

    return flutter_map.FlutterMap(
      mapController: _mapController,
      options: flutter_map.MapOptions(
        initialCenter: center,
        initialZoom: initialZoom,
      ),
      children: [
        flutter_map.TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.trident_tracker',
        ),
        
        // Location marker layer
        if (currentLocation != null)
          flutter_map.MarkerLayer(
            markers: [
              flutter_map.Marker(
                point: currentLocation,
                width: locationMarker?.size.width ?? 80.0,
                height: locationMarker?.size.height ?? 80.0,
                child: TridentMarkerWidgets.buildMarkerWidget(locationMarker),
              ),
            ],
          ),
          
        // Route animation layer
        if (routeController != null) ...[
          flutter_map.MarkerLayer(
            markers: [
              flutter_map.Marker(
                point: routeController.getCurrentPosition(),
                width: routeAnimation?.animatedMarker?.size.width ?? 80.0,
                height: routeAnimation?.animatedMarker?.size.height ?? 80.0,
                child: TridentMarkerWidgets.buildMarkerWidget(
                  routeAnimation?.animatedMarker
                ),
              ),
            ],
          ),
          
          if (routeAnimation?.showPolyline == true)
            flutter_map.PolylineLayer(
              polylines: [
                flutter_map.Polyline(
                  points: routeController.getRoutePoints(),
                  strokeWidth: routeAnimation!.polylineWidth,
                  color: routeAnimation.polylineColor,
                ),
              ],
            ),
        ],
      ],
    );
  }
  
  @override
  Future<void> moveToLocation(LatLng location) async {
    _mapController?.move(location, _mapController?.camera.zoom ?? 15.0);
  }
  
  @override
  void updateLocationMarker(LatLng location, TridentLocationMarker? marker) {
    // Flutter Map automatically updates through widget rebuilds
  }
  
  @override
  void updateRouteAnimation(TridentRouteAnimationController? controller) {
    // Flutter Map automatically updates through widget rebuilds
  }
  
  @override
  void dispose() {
    // Flutter Map controller is automatically disposed
  }
  
  @override
  bool get supportsCustomMarkers => true;
  
  @override
  bool get supportsRouteAnimation => true;
  
  @override
  bool get supportsPolylines => true;
}