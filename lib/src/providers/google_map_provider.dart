import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:latlong2/latlong.dart';

import '../abstractions/map_provider.dart';
import '../trident_location_marker.dart';
import '../trident_route_animation.dart';

/// Google Maps implementation following Single Responsibility Principle
class GoogleMapProvider implements MapProvider {
  final String _apiKey;
  google_maps.GoogleMapController? _mapController;
  Set<google_maps.Marker> _markers = {};
  Set<google_maps.Polyline> _polylines = {};
  
  GoogleMapProvider(this._apiKey);
  
  @override
  Future<void> initialize() async {
    // Google Maps initialization is handled in onMapCreated
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
    final center = currentLocation != null
        ? google_maps.LatLng(currentLocation.latitude, currentLocation.longitude)
        : initialCenter != null
            ? google_maps.LatLng(initialCenter.latitude, initialCenter.longitude)
            : const google_maps.LatLng(37.7749, -122.4194);

    return google_maps.GoogleMap(
      onMapCreated: (google_maps.GoogleMapController controller) {
        _mapController = controller;
        
        // Initialize markers and polylines if needed
        if (currentLocation != null) {
          _updateLocationMarker(currentLocation, locationMarker);
        }
        
        if (routeController != null && routeAnimation != null) {
          _updateRoutePolyline(routeController, routeAnimation);
        }
      },
      initialCameraPosition: google_maps.CameraPosition(
        target: center,
        zoom: initialZoom,
      ),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: false, // We handle location markers manually
      myLocationButtonEnabled: false,
      mapType: google_maps.MapType.normal,
      compassEnabled: true,
      tiltGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      rotateGesturesEnabled: true,
    );
  }
  
  @override
  Future<void> moveToLocation(LatLng location) async {
    await _mapController?.animateCamera(
      google_maps.CameraUpdate.newLatLng(
        google_maps.LatLng(location.latitude, location.longitude),
      ),
    );
  }
  
  @override
  void updateLocationMarker(LatLng location, TridentLocationMarker? marker) {
    _updateLocationMarker(location, marker);
  }
  
  @override
  void updateRouteAnimation(TridentRouteAnimationController? controller) {
    if (controller != null) {
      final currentPosition = controller.getCurrentPosition();
      _updateRouteMarker(currentPosition);
    }
  }
  
  void _updateLocationMarker(LatLng location, TridentLocationMarker? marker) {
    _createMarkerIcon(marker).then((icon) {
      _markers.removeWhere((m) => m.markerId.value == 'current_location');
      _markers.add(
        google_maps.Marker(
          markerId: const google_maps.MarkerId('current_location'),
          position: google_maps.LatLng(location.latitude, location.longitude),
          infoWindow: google_maps.InfoWindow(
            title: marker?.title ?? 'Your Location',
            snippet: marker?.description,
          ),
          icon: icon,
        ),
      );
    });
  }
  
  void _updateRouteMarker(LatLng position) {
    _markers.removeWhere((m) => m.markerId.value == 'route_marker');
    _markers.add(
      google_maps.Marker(
        markerId: const google_maps.MarkerId('route_marker'),
        position: google_maps.LatLng(position.latitude, position.longitude),
        icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(
          google_maps.BitmapDescriptor.hueBlue,
        ),
      ),
    );
  }
  
  void _updateRoutePolyline(
    TridentRouteAnimationController controller,
    TridentRouteAnimation animation,
  ) {
    if (!animation.showPolyline) return;
    
    final routePoints = controller.getRoutePoints();
    _polylines = {
      google_maps.Polyline(
        polylineId: const google_maps.PolylineId('route'),
        points: routePoints.map((point) => 
          google_maps.LatLng(point.latitude, point.longitude)).toList(),
        color: animation.polylineColor,
        width: animation.polylineWidth.round(),
      ),
    };
  }
  
  Future<google_maps.BitmapDescriptor> _createMarkerIcon(
    TridentLocationMarker? marker,
  ) async {
    if (marker == null) {
      return google_maps.BitmapDescriptor.defaultMarkerWithHue(
        google_maps.BitmapDescriptor.hueBlue,
      );
    }
    
    switch (marker.type) {
      case TridentLocationMarkerType.asset:
        try {
          return await google_maps.BitmapDescriptor.asset(
            const ImageConfiguration(size: Size(48, 48)),
            marker.assetPath!,
          );
        } catch (e) {
          return google_maps.BitmapDescriptor.defaultMarkerWithHue(
            google_maps.BitmapDescriptor.hueBlue,
          );
        }
        
      case TridentLocationMarkerType.defaultIcon:
      case TridentLocationMarkerType.pulsing:
        final color = marker.color ?? Colors.blue;
        if (color == Colors.red) {
          return google_maps.BitmapDescriptor.defaultMarkerWithHue(
            google_maps.BitmapDescriptor.hueRed,
          );
        } else if (color == Colors.green) {
          return google_maps.BitmapDescriptor.defaultMarkerWithHue(
            google_maps.BitmapDescriptor.hueGreen,
          );
        } else {
          return google_maps.BitmapDescriptor.defaultMarkerWithHue(
            google_maps.BitmapDescriptor.hueBlue,
          );
        }
        
      default:
        return google_maps.BitmapDescriptor.defaultMarkerWithHue(
          google_maps.BitmapDescriptor.hueBlue,
        );
    }
  }
  
  @override
  void dispose() {
    _mapController?.dispose();
  }
  
  @override
  bool get supportsCustomMarkers => true;
  
  @override
  bool get supportsRouteAnimation => true;
  
  @override
  bool get supportsPolylines => true;
}