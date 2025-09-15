import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Interface for location services (Interface Segregation Principle)
abstract class ILocationService {
  Future<bool> requestLocationPermission();
  Future<Position?> getCurrentLocation();
  Stream<Position> getLocationStream();
  Future<bool> isLocationServiceEnabled();
}

/// Interface for location updates
abstract class ILocationUpdateHandler {
  void onLocationChanged(LatLng location);
  void onLocationError(String error);
  void onPermissionDenied();
}

/// Location service coordinator (Single Responsibility)
class LocationServiceCoordinator {
  final ILocationService _locationService;
  final ILocationUpdateHandler _updateHandler;
  
  LocationServiceCoordinator(this._locationService, this._updateHandler);
  
  Future<void> startLocationTracking() async {
    try {
      final hasPermission = await _locationService.requestLocationPermission();
      if (!hasPermission) {
        _updateHandler.onPermissionDenied();
        return;
      }
      
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _updateHandler.onLocationChanged(
          LatLng(position.latitude, position.longitude)
        );
      }
    } catch (e) {
      _updateHandler.onLocationError(e.toString());
    }
  }
  
  Stream<LatLng> getLocationUpdates() async* {
    try {
      await for (final position in _locationService.getLocationStream()) {
        yield LatLng(position.latitude, position.longitude);
      }
    } catch (e) {
      _updateHandler.onLocationError(e.toString());
    }
  }
}