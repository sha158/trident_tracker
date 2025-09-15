import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'trident_location_marker.dart';
import 'services/route_service.dart';

/// Defines how a route should be animated on the map.
/// 
/// The [TridentRouteAnimation] provides configuration for animating
/// a marker along a route from start to destination with customizable
/// speed, markers, and callbacks.
class TridentRouteAnimation {
  final LatLng startPoint;
  final LatLng endPoint;
  final List<LatLng>? waypoints;
  final TridentLocationMarker? animatedMarker;
  final Duration duration;
  final bool autoStart;
  final bool showPolyline;
  final Color polylineColor;
  final double polylineWidth;
  final TridentAnimationCurve curve;
  final VoidCallback? onRouteStart;
  final VoidCallback? onRouteComplete;
  final ValueChanged<double>? onProgress;
  final ValueChanged<LatLng>? onPositionChanged;
  final IRouteService? routeService;
  final bool useRealRoads;

  const TridentRouteAnimation({
    required this.startPoint,
    required this.endPoint,
    this.waypoints,
    this.animatedMarker,
    this.duration = const Duration(seconds: 10),
    this.autoStart = false,
    this.showPolyline = true,
    this.polylineColor = Colors.blue,
    this.polylineWidth = 3.0,
    this.curve = TridentAnimationCurve.easeInOut,
    this.onRouteStart,
    this.onRouteComplete,
    this.onProgress,
    this.onPositionChanged,
    this.routeService,
    this.useRealRoads = true,
  });

  /// Creates a route animation for vehicle tracking.
  factory TridentRouteAnimation.vehicle({
    required LatLng startPoint,
    required LatLng endPoint,
    List<LatLng>? waypoints,
    String? vehicleAsset,
    Duration duration = const Duration(seconds: 15),
    VoidCallback? onComplete,
    IRouteService? routeService,
    bool useRealRoads = true,
  }) {
    return TridentRouteAnimation(
      startPoint: startPoint,
      endPoint: endPoint,
      waypoints: waypoints,
      duration: duration,
      animatedMarker: vehicleAsset != null
          ? TridentLocationMarker.fromAsset(
              vehicleAsset,
              size: const Size(40, 40),
            )
          : TridentLocationMarker.fromWidget(
              const Icon(
                Icons.directions_car,
                color: Colors.blue,
                size: 30,
              ),
            ),
      showPolyline: true,
      polylineColor: Colors.blue,
      autoStart: true,
      onRouteComplete: onComplete,
      routeService: routeService ?? RouteServiceFactory.create(),
      useRealRoads: useRealRoads,
    );
  }

  /// Creates a route animation for delivery tracking.
  factory TridentRouteAnimation.delivery({
    required LatLng startPoint,
    required LatLng endPoint,
    List<LatLng>? waypoints,
    Duration duration = const Duration(seconds: 12),
    VoidCallback? onComplete,
    IRouteService? routeService,
    bool useRealRoads = true,
  }) {
    return TridentRouteAnimation(
      startPoint: startPoint,
      endPoint: endPoint,
      waypoints: waypoints,
      duration: duration,
      animatedMarker: TridentLocationMarker.fromWidget(
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(17.5),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(
            Icons.motorcycle,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      showPolyline: true,
      polylineColor: Colors.green,
      polylineWidth: 4.0,
      autoStart: true,
      onRouteComplete: onComplete,
      routeService: routeService ?? RouteServiceFactory.create(),
      useRealRoads: useRealRoads,
    );
  }

  /// Creates a route animation for walking/running tracking.
  factory TridentRouteAnimation.walking({
    required LatLng startPoint,
    required LatLng endPoint,
    List<LatLng>? waypoints,
    Duration duration = const Duration(seconds: 20),
    VoidCallback? onComplete,
    IRouteService? routeService,
    bool useRealRoads = true,
  }) {
    return TridentRouteAnimation(
      startPoint: startPoint,
      endPoint: endPoint,
      waypoints: waypoints,
      duration: duration,
      animatedMarker: TridentLocationMarker.pulsing(
        color: Colors.orange,
        size: const Size(30, 30),
      ),
      showPolyline: true,
      polylineColor: Colors.orange,
      polylineWidth: 2.0,
      curve: TridentAnimationCurve.linear,
      autoStart: true,
      onRouteComplete: onComplete,
      routeService: routeService ?? RouteServiceFactory.create(),
      useRealRoads: useRealRoads,
    );
  }
}

/// Animation curves for route animations.
enum TridentAnimationCurve {
  linear,
  easeIn,
  easeOut,
  easeInOut,
  bounceIn,
  bounceOut,
}

/// Controller for managing route animations.
class TridentRouteAnimationController {
  final TridentRouteAnimation config;
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<LatLng> _routePoints = [];
  bool _isInitialized = false;

  TridentRouteAnimationController({
    required this.config,
    required TickerProvider vsync,
  }) {
    _animationController = AnimationController(
      duration: config.duration,
      vsync: vsync,
    );

    // Create animation with specified curve
    final curve = _getCurve(config.curve);
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: curve,
    ));

    _setupAnimation();
  }

  Curve _getCurve(TridentAnimationCurve curveType) {
    switch (curveType) {
      case TridentAnimationCurve.linear:
        return Curves.linear;
      case TridentAnimationCurve.easeIn:
        return Curves.easeIn;
      case TridentAnimationCurve.easeOut:
        return Curves.easeOut;
      case TridentAnimationCurve.easeInOut:
        return Curves.easeInOut;
      case TridentAnimationCurve.bounceIn:
        return Curves.bounceIn;
      case TridentAnimationCurve.bounceOut:
        return Curves.bounceOut;
    }
  }

  void _setupAnimation() {
    _setupAnimationListeners();
    
    // Generate route points (async if using real roads)
    if (config.useRealRoads && config.routeService != null) {
      print('🔄 Setting up REAL ROADS animation...');
      _generateRealRoutePoints().then((_) {
        print('✅ Real roads route loaded, starting animation');
        if (config.autoStart) {
          start();
        }
      }).catchError((error) {
        print('❌ Real roads failed: $error, using fallback');
        _routePoints = _generateSimpleRoutePoints();
        if (config.autoStart) {
          start();
        }
      });
    } else {
      print('⚠️ Using simple route points (useRealRoads: ${config.useRealRoads}, routeService: ${config.routeService != null})');
      _routePoints = _generateSimpleRoutePoints();
      if (config.autoStart) {
        start();
      }
    }
  }

  void _setupAnimationListeners() {
    _animation.addListener(() {
      final position = getCurrentPosition();
      config.onProgress?.call(_animation.value);
      config.onPositionChanged?.call(position);
    });

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.forward && !_isInitialized) {
        _isInitialized = true;
        config.onRouteStart?.call();
      } else if (status == AnimationStatus.completed) {
        config.onRouteComplete?.call();
      }
    });
  }

  Future<void> _generateRealRoutePoints() async {
    try {
      print('🛣️ Calculating real road route from ${config.startPoint} to ${config.endPoint}');
      final profile = _getRouteProfile();
      final routeResult = await config.routeService!.calculateRoute(
        start: config.startPoint,
        end: config.endPoint,
        waypoints: config.waypoints,
        profile: profile,
      );
      
      _routePoints = routeResult.coordinates;
      print('✅ Real road route calculated with ${_routePoints.length} points');
      print('📏 Distance: ${(routeResult.distance / 1000).toStringAsFixed(2)} km');
      print('⏱️ Duration: ${(routeResult.duration / 60).toStringAsFixed(1)} minutes');
    } catch (e) {
      // Fallback to simple route generation if API fails
      print('❌ Route calculation failed, using fallback: $e');
      _routePoints = _generateSimpleRoutePoints();
      print('⚠️ Using ${_routePoints.length} interpolated points as fallback');
    }
  }

  RouteProfile _getRouteProfile() {
    // Determine route profile based on marker type and polyline color
    if (config.polylineColor == Colors.green) {
      print('🏍️ Using delivery profile (green polyline)');
      return RouteProfile.delivery;
    } else if (config.polylineColor == Colors.orange) {
      print('🚶 Using walking profile (orange polyline)');
      return RouteProfile.walking;
    } else if (config.polylineColor == Colors.blue) {
      print('🚗 Using driving profile (blue polyline)');
      return RouteProfile.driving;
    } else {
      print('🚗 Using default driving profile');
      return RouteProfile.driving;
    }
  }

  List<LatLng> _generateSimpleRoutePoints() {
    final points = <LatLng>[];
    
    // Add start point
    points.add(config.startPoint);
    
    // Add waypoints if provided
    if (config.waypoints != null) {
      points.addAll(config.waypoints!);
    }
    
    // Add end point
    points.add(config.endPoint);
    
    // Generate intermediate points for smooth animation
    return _interpolateRoute(points);
  }

  List<LatLng> _interpolateRoute(List<LatLng> points) {
    final interpolated = <LatLng>[];
    const segmentsPerPoint = 20; // Number of points between each major point

    for (int i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];

      for (int j = 0; j <= segmentsPerPoint; j++) {
        final t = j / segmentsPerPoint;
        final lat = start.latitude + (end.latitude - start.latitude) * t;
        final lng = start.longitude + (end.longitude - start.longitude) * t;
        interpolated.add(LatLng(lat, lng));
      }
    }

    return interpolated;
  }

  /// Get current position along the route based on animation progress.
  LatLng getCurrentPosition() {
    if (_routePoints.isEmpty) return config.startPoint;

    final progress = _animation.value;
    final index = (progress * (_routePoints.length - 1)).floor();
    
    if (index >= _routePoints.length - 1) {
      return _routePoints.last;
    }

    // Interpolate between two points for smooth movement
    final currentPoint = _routePoints[index];
    final nextPoint = _routePoints[index + 1];
    final segmentProgress = (progress * (_routePoints.length - 1)) - index;

    final lat = currentPoint.latitude + 
        (nextPoint.latitude - currentPoint.latitude) * segmentProgress;
    final lng = currentPoint.longitude + 
        (nextPoint.longitude - currentPoint.longitude) * segmentProgress;

    return LatLng(lat, lng);
  }

  /// Get all route points for drawing polyline.
  List<LatLng> getRoutePoints() => List.unmodifiable(_routePoints);

  /// Start the route animation.
  void start() {
    _animationController.forward();
  }

  /// Pause the route animation.
  void pause() {
    _animationController.stop();
  }

  /// Resume the route animation.
  void resume() {
    _animationController.forward();
  }

  /// Stop and reset the route animation.
  void stop() {
    _animationController.stop();
    _animationController.reset();
  }

  /// Set animation speed multiplier (1.0 = normal, 2.0 = double speed, 0.5 = half speed).
  void setSpeed(double multiplier) {
    if (multiplier <= 0) return; // Prevent invalid multipliers
    
    final currentValue = _animationController.value;
    final remainingProgress = 1.0 - currentValue;
    final remainingMilliseconds = (config.duration.inMilliseconds * remainingProgress / multiplier).round();
    final remainingDuration = Duration(milliseconds: remainingMilliseconds.clamp(0, double.infinity).toInt());
    
    _animationController.stop();
    _animationController.duration = remainingDuration;
    _animationController.forward(from: currentValue);
  }

  /// Check if animation is currently running.
  bool get isAnimating => _animationController.isAnimating;

  /// Get current progress (0.0 to 1.0).
  double get progress => _animation.value;

  /// Dispose of resources.
  void dispose() {
    _animationController.dispose();
  }
}