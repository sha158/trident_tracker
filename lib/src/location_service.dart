import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// A service class that handles location-related operations.
/// 
/// The [LocationService] provides static methods for requesting
/// location permissions and retrieving the user's current location.
class LocationService {
  /// Requests location permission from the user.
  /// 
  /// Returns `true` if permission is granted, `false` otherwise.
  /// This method specifically requests "when in use" location permission.
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  /// Gets the user's current location.
  /// 
  /// Returns a [Position] object containing latitude and longitude
  /// if successful, or `null` if location services are disabled
  /// or permission is denied.
  /// 
  /// This method automatically handles permission requests and
  /// service availability checks.
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Creates a stream of location updates.
  /// 
  /// Returns a [Stream<Position>] that emits location updates
  /// when the user's position changes by at least 10 meters.
  /// 
  /// The stream uses high accuracy location settings and
  /// a distance filter to reduce battery consumption.
  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}