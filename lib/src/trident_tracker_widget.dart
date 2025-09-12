import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osm;
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:latlong2/latlong.dart';

import 'map_type.dart';
import 'location_service.dart';
import 'trident_location_marker.dart';
import 'marker_widgets.dart';
import 'trident_route_animation.dart';

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
  /// Choose between [MapType.flutterMap] for OpenStreetMap integration,
  /// [MapType.osmPlugin] for OSM plugin implementation, or
  /// [MapType.googleMaps] for Google Maps integration.
  final MapType mapType;
  
  /// Google Maps API key.
  /// 
  /// Required when [mapType] is [MapType.googleMaps].
  /// Not required for other map types.
  final String? googleMapsApiKey;
  
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
  
  /// Custom marker configuration for the current location.
  /// 
  /// Allows customization of how the current location is displayed
  /// with custom images, widgets, or default styled markers.
  /// If null, a default marker will be used.
  final TridentLocationMarker? locationMarker;
  
  /// Callback function called when location permission is denied.
  /// 
  /// This allows the parent widget to handle permission denial
  /// gracefully, such as showing a user-friendly message.
  final VoidCallback? onLocationPermissionDenied;
  
  /// Callback function called when Google Maps API key is invalid or missing.
  /// 
  /// This allows the parent widget to handle API key errors
  /// gracefully, such as showing setup instructions.
  final VoidCallback? onGoogleMapsApiKeyError;
  
  /// Optional route animation configuration.
  /// 
  /// When provided, the widget will display an animated route with
  /// a marker moving from start to end point along the specified path.
  final TridentRouteAnimation? routeAnimation;

  /// Creates a [TridentTracker] widget.
  /// 
  /// The [mapType] parameter is required and determines which map
  /// implementation to use.
  /// 
  /// When using [MapType.googleMaps], the [googleMapsApiKey] parameter
  /// is required.
  /// 
  /// Other parameters are optional and allow customization of the
  /// map's initial state and behavior.
  const TridentTracker({
    super.key,
    required this.mapType,
    this.googleMapsApiKey,
    this.initialZoom = 15.0,
    this.initialCenter,
    this.showCurrentLocation = true,
    this.locationMarker,
    this.onLocationPermissionDenied,
    this.onGoogleMapsApiKeyError,
    this.routeAnimation,
  }) : assert(
         mapType != MapType.googleMaps || (googleMapsApiKey != null && googleMapsApiKey != ''),
         'Google Maps API key is required when mapType is MapType.googleMaps. '
         'Usage: TridentTracker(mapType: MapType.googleMaps, googleMapsApiKey: "your-key")',
       );

  @override
  State<TridentTracker> createState() => _TridentTrackerState();
}

class _TridentTrackerState extends State<TridentTracker> with TickerProviderStateMixin {
  LatLng? _currentLocation;
  flutter_map.MapController? _mapController;
  late osm.MapController _osmController;
  google_maps.GoogleMapController? _googleMapController;
  bool _isLoading = true;
  String? _errorMessage;
  Set<google_maps.Marker> _googleMarkers = {};
  Set<google_maps.Polyline> _googlePolylines = {};
  TridentRouteAnimationController? _routeAnimationController;

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
    _initializeRouteAnimation();
  }

  @override
  void dispose() {
    _osmController.dispose();
    _routeAnimationController?.dispose();
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

        // Move map to current location based on map type
        if (mounted) {
          try {
            if (widget.mapType == MapType.osmPlugin) {
              await _osmController.moveTo(
                osm.GeoPoint(
                  latitude: position.latitude,
                  longitude: position.longitude,
                ),
              );
            } else if (widget.mapType == MapType.googleMaps && _googleMapController != null) {
              await _googleMapController!.animateCamera(
                google_maps.CameraUpdate.newLatLng(
                  google_maps.LatLng(position.latitude, position.longitude),
                ),
              );
              // Update Google Maps marker
              _updateGoogleMapsMarker(position.latitude, position.longitude);
            }
          } catch (mapError) {
            // Map controller error is non-critical, log but don't fail
            debugPrint('Map controller error: $mapError');
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
  
  void _initializeRouteAnimation() {
    if (widget.routeAnimation != null) {
      // Create a new route animation config with our custom callbacks
      final customConfig = TridentRouteAnimation(
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
        onRouteStart: widget.routeAnimation!.onRouteStart,
        onRouteComplete: widget.routeAnimation!.onRouteComplete,
        onProgress: widget.routeAnimation!.onProgress,
        onPositionChanged: (position) {
          // Update markers based on map type
          if (widget.mapType == MapType.googleMaps) {
            _updateGoogleMapsRouteMarker();
          }
          // Call the original callback if provided
          widget.routeAnimation!.onPositionChanged?.call(position);
        },
      );
      
      _routeAnimationController = TridentRouteAnimationController(
        config: customConfig,
        vsync: this,
      );
      
      // Add route polyline for Google Maps
      if (widget.mapType == MapType.googleMaps && widget.routeAnimation!.showPolyline) {
        _updateGoogleMapsPolyline();
      }
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
  
  void _updateGoogleMapsMarker(double latitude, double longitude) {
    if (!mounted) return;
    
    _createGoogleMapsMarkerIcon().then((icon) {
      if (!mounted) return;
      
      setState(() {
        _googleMarkers = {
          google_maps.Marker(
            markerId: const google_maps.MarkerId('current_location'),
            position: google_maps.LatLng(latitude, longitude),
            infoWindow: google_maps.InfoWindow(
              title: widget.locationMarker?.title ?? 'Your Location',
              snippet: widget.locationMarker?.description,
            ),
            icon: icon,
          ),
        };
      });
    }).catchError((error) {
      // Fallback to default marker if custom marker fails
      if (!mounted) return;
      
      setState(() {
        _googleMarkers = {
          google_maps.Marker(
            markerId: const google_maps.MarkerId('current_location'),
            position: google_maps.LatLng(latitude, longitude),
            infoWindow: const google_maps.InfoWindow(
              title: 'Your Location',
            ),
            icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(
              google_maps.BitmapDescriptor.hueBlue,
            ),
          ),
        };
      });
    });
  }
  
  Future<google_maps.BitmapDescriptor> _createGoogleMapsMarkerIcon() async {
    final marker = widget.locationMarker;
    
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
        
      case TridentLocationMarkerType.widget:
        // For widgets, we'll use fromBytes after converting to image
        // This is more complex and would require additional implementation
        return google_maps.BitmapDescriptor.defaultMarkerWithHue(
          google_maps.BitmapDescriptor.hueBlue,
        );
        
      case TridentLocationMarkerType.defaultIcon:
        final color = marker.color ?? Colors.blue;
        if (color == Colors.blue) {
          return google_maps.BitmapDescriptor.defaultMarkerWithHue(
            google_maps.BitmapDescriptor.hueBlue,
          );
        } else if (color == Colors.red) {
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
        
      case TridentLocationMarkerType.pulsing:
        // Pulsing animation not supported in Google Maps markers
        // Fall back to colored marker
        final color = marker.color ?? Colors.blue;
        if (color == Colors.blue) {
          return google_maps.BitmapDescriptor.defaultMarkerWithHue(
            google_maps.BitmapDescriptor.hueBlue,
          );
        } else if (color == Colors.red) {
          return google_maps.BitmapDescriptor.defaultMarkerWithHue(
            google_maps.BitmapDescriptor.hueRed,
          );
        } else {
          return google_maps.BitmapDescriptor.defaultMarkerWithHue(
            google_maps.BitmapDescriptor.hueBlue,
          );
        }
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

    switch (widget.mapType) {
      case MapType.flutterMap:
        return _buildFlutterMap();
      case MapType.osmPlugin:
        return _buildOsmMap();
      case MapType.googleMaps:
        return _buildGoogleMap();
    }
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
        if (_currentLocation != null || _routeAnimationController != null)
          flutter_map.MarkerLayer(
            markers: [
              // Current location marker
              if (_currentLocation != null)
                flutter_map.Marker(
                  point: _currentLocation!,
                  width: widget.locationMarker?.size.width ?? 80.0,
                  height: widget.locationMarker?.size.height ?? 80.0,
                  child: TridentMarkerWidgets.buildMarkerWidget(widget.locationMarker),
                ),
              // Route animation marker
              if (_routeAnimationController != null)
                flutter_map.Marker(
                  point: _routeAnimationController!.getCurrentPosition(),
                  width: widget.routeAnimation!.animatedMarker?.size.width ?? 80.0,
                  height: widget.routeAnimation!.animatedMarker?.size.height ?? 80.0,
                  child: TridentMarkerWidgets.buildMarkerWidget(widget.routeAnimation!.animatedMarker),
                ),
            ],
          ),
        // Route polyline
        if (_routeAnimationController != null && widget.routeAnimation!.showPolyline)
          flutter_map.PolylineLayer(
            polylines: [
              flutter_map.Polyline(
                points: _routeAnimationController!.getRoutePoints(),
                strokeWidth: widget.routeAnimation!.polylineWidth,
                color: widget.routeAnimation!.polylineColor,
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
        userLocationMarker: _buildOSMUserLocationMarker(),
        roadConfiguration: const osm.RoadOption(
          roadColor: Colors.yellowAccent,
        ),
      ),
    );
  }
  
  Widget _buildGoogleMap() {
    final center = _currentLocation != null
        ? google_maps.LatLng(_currentLocation!.latitude, _currentLocation!.longitude)
        : widget.initialCenter != null
            ? google_maps.LatLng(widget.initialCenter!.latitude, widget.initialCenter!.longitude)
            : const google_maps.LatLng(37.7749, -122.4194);

    return google_maps.GoogleMap(
      onMapCreated: (google_maps.GoogleMapController controller) {
        _googleMapController = controller;
        
        // Update marker if we have current location
        if (_currentLocation != null) {
          _updateGoogleMapsMarker(_currentLocation!.latitude, _currentLocation!.longitude);
        }
      },
      initialCameraPosition: google_maps.CameraPosition(
        target: center,
        zoom: widget.initialZoom ?? 15.0,
      ),
      markers: _googleMarkers,
      polylines: _googlePolylines,
      myLocationEnabled: widget.showCurrentLocation,
      myLocationButtonEnabled: widget.showCurrentLocation,
      mapType: google_maps.MapType.normal,
      compassEnabled: true,
      tiltGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      rotateGesturesEnabled: true,
    );
  }
  
  osm.UserLocationMaker _buildOSMUserLocationMarker() {
    final marker = widget.locationMarker;
    
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
    
    // OSM plugin has limited customization options
    // We can mainly change the icon and color
    IconData iconData;
    Color iconColor;
    double iconSize;
    
    switch (marker.type) {
      case TridentLocationMarkerType.asset:
        // OSM plugin doesn't support asset images directly
        // Fall back to default icon with custom color
        iconData = Icons.my_location;
        iconColor = marker.color ?? Colors.blue;
        iconSize = marker.size.width.clamp(24.0, 72.0);
        break;
        
      case TridentLocationMarkerType.widget:
        // OSM plugin doesn't support custom widgets
        // Fall back to default icon
        iconData = Icons.my_location;
        iconColor = Colors.blue;
        iconSize = 48.0;
        break;
        
      case TridentLocationMarkerType.defaultIcon:
        iconData = Icons.my_location;
        iconColor = marker.color ?? Colors.blue;
        iconSize = marker.size.width.clamp(24.0, 72.0);
        break;
        
      case TridentLocationMarkerType.pulsing:
        // OSM plugin doesn't support animations
        // Use the color but no pulsing effect
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
  
  void _setupGoogleMapsRouteAnimation() {
    // This method will be implemented differently since we can't access private _animation
    // Instead, we'll update the route marker in the position change callback
    // This is handled in the route animation configuration
  }
  
  void _updateGoogleMapsRouteMarker() {
    if (_routeAnimationController == null || !mounted) return;
    
    final currentPosition = _routeAnimationController!.getCurrentPosition();
    final marker = widget.routeAnimation!.animatedMarker;
    
    _createGoogleMapsRouteMarkerIcon().then((icon) {
      if (!mounted) return;
      
      setState(() {
        // Remove existing route marker and add new one
        _googleMarkers.removeWhere((m) => m.markerId.value == 'route_marker');
        _googleMarkers.add(
          google_maps.Marker(
            markerId: const google_maps.MarkerId('route_marker'),
            position: google_maps.LatLng(currentPosition.latitude, currentPosition.longitude),
            infoWindow: google_maps.InfoWindow(
              title: marker?.title ?? 'Route Progress',
              snippet: marker?.description,
            ),
            icon: icon,
          ),
        );
      });
    });
  }
  
  void _updateGoogleMapsPolyline() {
    if (_routeAnimationController == null || !mounted) return;
    
    final routePoints = _routeAnimationController!.getRoutePoints();
    
    setState(() {
      _googlePolylines = {
        google_maps.Polyline(
          polylineId: const google_maps.PolylineId('route'),
          points: routePoints.map((point) => 
            google_maps.LatLng(point.latitude, point.longitude)).toList(),
          color: widget.routeAnimation!.polylineColor,
          width: widget.routeAnimation!.polylineWidth.round(),
        ),
      };
    });
  }
  
  Future<google_maps.BitmapDescriptor> _createGoogleMapsRouteMarkerIcon() async {
    final marker = widget.routeAnimation!.animatedMarker;
    
    if (marker == null) {
      return google_maps.BitmapDescriptor.defaultMarkerWithHue(
        google_maps.BitmapDescriptor.hueBlue,
      );
    }
    
    // Reuse the existing marker creation logic but for route marker
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
        
      case TridentLocationMarkerType.widget:
        return google_maps.BitmapDescriptor.defaultMarkerWithHue(
          google_maps.BitmapDescriptor.hueBlue,
        );
        
      case TridentLocationMarkerType.defaultIcon:
        final color = marker.color ?? Colors.blue;
        if (color == Colors.blue) {
          return google_maps.BitmapDescriptor.defaultMarkerWithHue(
            google_maps.BitmapDescriptor.hueBlue,
          );
        } else if (color == Colors.red) {
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
        
      case TridentLocationMarkerType.pulsing:
        final color = marker.color ?? Colors.blue;
        if (color == Colors.blue) {
          return google_maps.BitmapDescriptor.defaultMarkerWithHue(
            google_maps.BitmapDescriptor.hueBlue,
          );
        } else if (color == Colors.red) {
          return google_maps.BitmapDescriptor.defaultMarkerWithHue(
            google_maps.BitmapDescriptor.hueRed,
          );
        } else {
          return google_maps.BitmapDescriptor.defaultMarkerWithHue(
            google_maps.BitmapDescriptor.hueBlue,
          );
        }
    }
  }
}