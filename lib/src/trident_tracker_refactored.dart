import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'abstractions/map_provider.dart';
import 'abstractions/location_service_interface.dart';
import 'providers/flutter_map_provider.dart';
import 'providers/google_map_provider.dart';
import 'providers/osm_map_provider.dart';
import 'location_service.dart';
import 'trident_location_marker.dart';
import 'trident_route_animation.dart';

/// Refactored TridentTracker following SOLID principles
class TridentTrackerRefactored extends StatefulWidget {
  final MapType mapType;
  final String? googleMapsApiKey;
  final double initialZoom;
  final LatLng? initialCenter;
  final bool showCurrentLocation;
  final TridentLocationMarker? locationMarker;
  final TridentRouteAnimation? routeAnimation;
  final VoidCallback? onLocationPermissionDenied;
  final VoidCallback? onGoogleMapsApiKeyError;

  const TridentTrackerRefactored({
    super.key,
    required this.mapType,
    this.googleMapsApiKey,
    this.initialZoom = 15.0,
    this.initialCenter,
    this.showCurrentLocation = true,
    this.locationMarker,
    this.routeAnimation,
    this.onLocationPermissionDenied,
    this.onGoogleMapsApiKeyError,
  }) : assert(
         mapType != MapType.googleMaps || 
         (googleMapsApiKey != null && googleMapsApiKey != ''),
         'Google Maps API key is required when mapType is MapType.googleMaps.',
       );

  @override
  State<TridentTrackerRefactored> createState() => _TridentTrackerRefactoredState();
}

class _TridentTrackerRefactoredState extends State<TridentTrackerRefactored> 
    with TickerProviderStateMixin 
    implements ILocationUpdateHandler {
  
  // Dependencies (Dependency Inversion Principle)
  late final MapProvider _mapProvider;
  late final LocationServiceCoordinator _locationCoordinator;
  late final ILocationService _locationService;
  
  // State
  LatLng? _currentLocation;
  bool _isLoading = true;
  String? _errorMessage;
  TridentRouteAnimationController? _routeAnimationController;

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
    _initializeServices();
  }

  /// Initialize dependencies using Dependency Injection
  void _initializeDependencies() {
    // Create map provider using factory (Open/Closed Principle)
    _mapProvider = MapProviderFactory.create(
      widget.mapType,
      apiKey: widget.googleMapsApiKey,
    );
    
    // Create location service (Dependency Inversion)
    _locationService = LocationServiceImpl();
    _locationCoordinator = LocationServiceCoordinator(_locationService, this);
  }

  /// Initialize services (Single Responsibility)
  Future<void> _initializeServices() async {
    await _mapProvider.initialize();
    
    if (widget.showCurrentLocation) {
      await _locationCoordinator.startLocationTracking();
    } else {
      setState(() => _isLoading = false);
    }
    
    _initializeRouteAnimation();
  }

  void _initializeRouteAnimation() {
    if (widget.routeAnimation != null) {
      _routeAnimationController = TridentRouteAnimationController(
        config: _createRouteAnimationWithCallbacks(),
        vsync: this,
      );
    }
  }

  TridentRouteAnimation _createRouteAnimationWithCallbacks() {
    return TridentRouteAnimation(
      startPoint: widget.routeAnimation!.startPoint,
      endPoint: widget.routeAnimation!.endPoint,
      waypoints: widget.routeAnimation!.waypoints,
      animatedMarker: widget.routeAnimation!.animatedMarker,
      duration: widget.routeAnimation!.duration,
      autoStart: widget.routeAnimation!.autoStart,
      showPolyline: widget.routeAnimation!.showPolyline,
      polylineColor: widget.routeAnimation!.polylineColor,
      polylineWidth: widget.routeAnimation!.polylineWidth,
      curve: widget.routeAnimation!.curve,
      useRealRoads: widget.routeAnimation!.useRealRoads, // Fix: Copy useRealRoads
      routeService: widget.routeAnimation!.routeService, // Fix: Copy routeService
      onRouteStart: widget.routeAnimation!.onRouteStart,
      onRouteComplete: widget.routeAnimation!.onRouteComplete,
      onProgress: widget.routeAnimation!.onProgress,
      onPositionChanged: (position) {
        // Update route animation on map provider
        _mapProvider.updateRouteAnimation(_routeAnimationController);
        widget.routeAnimation!.onPositionChanged?.call(position);
      },
    );
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
            Text('Initializing map...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    return _mapProvider.buildMap(
      initialCenter: widget.initialCenter,
      initialZoom: widget.initialZoom,
      currentLocation: _currentLocation,
      locationMarker: widget.locationMarker,
      routeAnimation: widget.routeAnimation,
      routeController: _routeAnimationController,
    );
  }

  Widget _buildErrorWidget() {
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
            onPressed: _retryInitialization,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _retryInitialization() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _initializeServices();
  }

  // ILocationUpdateHandler implementation
  @override
  void onLocationChanged(LatLng location) {
    if (!mounted) return;
    
    setState(() {
      _currentLocation = location;
      _isLoading = false;
    });
    
    _mapProvider.updateLocationMarker(location, widget.locationMarker);
    _mapProvider.moveToLocation(location);
  }

  @override
  void onLocationError(String error) {
    if (!mounted) return;
    
    setState(() {
      _errorMessage = _getErrorMessage(error);
      _isLoading = false;
    });
  }

  @override
  void onPermissionDenied() {
    if (!mounted) return;
    
    setState(() {
      _errorMessage = 'Location permission denied. Please enable location access.';
      _isLoading = false;
    });
    
    widget.onLocationPermissionDenied?.call();
  }

  String _getErrorMessage(String error) {
    if (error.contains('permission')) {
      return 'Location permission denied. Please enable location access.';
    } else if (error.contains('service')) {
      return 'Location services are disabled. Please enable location services.';
    } else if (error.contains('network')) {
      return 'Network error occurred. Please check your internet connection.';
    } else {
      return 'An error occurred while getting your location. Please try again.';
    }
  }

  @override
  void dispose() {
    _routeAnimationController?.dispose();
    _mapProvider.dispose();
    super.dispose();
  }
}

/// Implementation of ILocationService using existing LocationService
class LocationServiceImpl implements ILocationService {
  @override
  Future<bool> requestLocationPermission() async {
    return await LocationService.requestLocationPermission();
  }

  @override
  Future<Position?> getCurrentLocation() async {
    return await LocationService.getCurrentLocation();
  }

  @override
  Stream<Position> getLocationStream() {
    return LocationService.getLocationStream();
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}