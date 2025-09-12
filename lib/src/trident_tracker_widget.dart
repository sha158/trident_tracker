import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osm;
import 'package:latlong2/latlong.dart';

import 'map_type.dart';
import 'location_service.dart';

/// A widget that displays a map using either flutter_map or flutter_osm_plugin.
/// 
/// The [TridentTracker] widget provides a unified interface for displaying maps
/// with current location support. Users can choose between two map implementations
/// based on their needs.
/// 
/// Example:
/// ```dart
/// TridentTracker(
///   mapType: MapType.flutterMap,
///   showCurrentLocation: true,
/// )
/// ```
class TridentTracker extends StatefulWidget {
  /// The type of map to display.
  /// 
  /// Choose between [MapType.flutterMap] for OpenStreetMap integration
  /// or [MapType.osmPlugin] for OSM plugin implementation.
  final MapType mapType;
  
  /// The initial zoom level for the map.
  /// 
  /// Defaults to 15.0 if not specified.
  final double? initialZoom;
  
  /// The initial center position for the map.
  /// 
  /// If not specified and [showCurrentLocation] is true, the map will
  /// center on the user's current location. Otherwise, defaults to
  /// San Francisco coordinates.
  final LatLng? initialCenter;
  
  /// Whether to show and track the user's current location.
  /// 
  /// When true, the widget will request location permissions and
  /// display the user's current position on the map.
  final bool showCurrentLocation;
  
  /// Callback function called when location permission is denied.
  /// 
  /// This allows the parent widget to handle permission denial
  /// gracefully, such as showing a user-friendly message.
  final VoidCallback? onLocationPermissionDenied;

  /// Creates a [TridentTracker] widget.
  /// 
  /// The [mapType] parameter is required and determines which map
  /// implementation to use.
  /// 
  /// Other parameters are optional and allow customization of the
  /// map's initial state and behavior.
  const TridentTracker({
    super.key,
    required this.mapType,
    this.initialZoom = 15.0,
    this.initialCenter,
    this.showCurrentLocation = true,
    this.onLocationPermissionDenied,
  });

  @override
  State<TridentTracker> createState() => _TridentTrackerState();
}

class _TridentTrackerState extends State<TridentTracker> {
  LatLng? _currentLocation;
  flutter_map.MapController? _mapController;
  late osm.MapController _osmController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _mapController = flutter_map.MapController();
    _osmController = osm.MapController(
      initMapWithUserPosition: osm.UserTrackingOption(
        enableTracking: true,
        unFollowUser: false,
      ),
    );
    _initializeLocation();
  }

  @override
  void dispose() {
    _osmController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    if (!widget.showCurrentLocation) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        if (!mounted) return;
        
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });

        // Only move OSM map if widget is still mounted
        if (widget.mapType == MapType.osmPlugin && mounted) {
          try {
            await _osmController.moveTo(
              osm.GeoPoint(
                latitude: position.latitude,
                longitude: position.longitude,
              ),
            );
          } catch (osmError) {
            // OSM controller error is non-critical, log but don't fail
            debugPrint('OSM controller error: $osmError');
          }
        }
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Unable to get current location. Please check your location settings and permissions.';
          _isLoading = false;
        });
        widget.onLocationPermissionDenied?.call();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('permission')) {
      return 'Location permission denied. Please enable location access in your device settings.';
    } else if (error.toString().contains('service')) {
      return 'Location services are disabled. Please enable location services in your device settings.';
    } else if (error.toString().contains('network')) {
      return 'Network error occurred while loading the map. Please check your internet connection.';
    } else {
      return 'An error occurred while getting your location. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Getting your location...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _initializeLocation();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return widget.mapType == MapType.flutterMap
        ? _buildFlutterMap()
        : _buildOsmMap();
  }

  Widget _buildFlutterMap() {
    final center = _currentLocation ??
        widget.initialCenter ??
        const LatLng(37.7749, -122.4194);

    return flutter_map.FlutterMap(
      mapController: _mapController,
      options: flutter_map.MapOptions(
        initialCenter: center,
        initialZoom: widget.initialZoom ?? 15.0,
      ),
      children: [
        flutter_map.TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.trident_tracker',
        ),
        if (_currentLocation != null)
          flutter_map.MarkerLayer(
            markers: [
              flutter_map.Marker(
                point: _currentLocation!,
                width: 80.0,
                height: 80.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildOsmMap() {
    return osm.OSMFlutter(
      controller: _osmController,
      osmOption: osm.OSMOption(
        userTrackingOption: const osm.UserTrackingOption(
          enableTracking: true,
          unFollowUser: false,
        ),
        zoomOption: const osm.ZoomOption(
          initZoom: 15,
          minZoomLevel: 3,
          maxZoomLevel: 19,
          stepZoom: 1.0,
        ),
        userLocationMarker: osm.UserLocationMaker(
          personMarker: const osm.MarkerIcon(
            icon: Icon(
              Icons.location_on,
              color: Colors.red,
              size: 48,
            ),
          ),
          directionArrowMarker: const osm.MarkerIcon(
            icon: Icon(
              Icons.double_arrow,
              size: 48,
            ),
          ),
        ),
        roadConfiguration: const osm.RoadOption(
          roadColor: Colors.yellowAccent,
        ),
      ),
    );
  }
}