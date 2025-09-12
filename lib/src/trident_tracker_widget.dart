import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osm;
import 'package:latlong2/latlong.dart';

import 'map_type.dart';
import 'location_service.dart';

class TridentTracker extends StatefulWidget {
  final MapType mapType;
  final double? initialZoom;
  final LatLng? initialCenter;
  final bool showCurrentLocation;
  final VoidCallback? onLocationPermissionDenied;

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
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        

        if (widget.mapType == MapType.osmPlugin) {
          await _osmController.moveTo(
            osm.GeoPoint(
              latitude: position.latitude,
              longitude: position.longitude,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Unable to get current location';
          _isLoading = false;
        });
        widget.onLocationPermissionDenied?.call();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
        _isLoading = false;
      });
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