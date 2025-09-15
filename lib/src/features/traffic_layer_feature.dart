import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../abstractions/map_provider.dart';

/// Example of how to extend the system with new features (Open/Closed Principle)
/// This demonstrates scalability without modifying existing code

/// Traffic layer configuration
class TrafficLayerConfig {
  final bool enabled;
  final Color trafficColor;
  final double opacity;
  final TrafficDataSource dataSource;

  const TrafficLayerConfig({
    this.enabled = true,
    this.trafficColor = Colors.red,
    this.opacity = 0.7,
    this.dataSource = TrafficDataSource.realTime,
  });
}

enum TrafficDataSource {
  realTime,
  historical,
  predicted,
}

/// Abstract traffic layer provider (Interface Segregation)
abstract class ITrafficLayerProvider {
  Future<void> enableTrafficLayer(TrafficLayerConfig config);
  Future<void> disableTrafficLayer();
  Stream<TrafficData> getTrafficUpdates(LatLng center, double radius);
  bool get supportsTrafficLayer;
}

/// Traffic data model
class TrafficData {
  final List<TrafficSegment> segments;
  final DateTime timestamp;
  final TrafficDataSource source;

  TrafficData({
    required this.segments,
    required this.timestamp,
    required this.source,
  });
}

class TrafficSegment {
  final List<LatLng> points;
  final TrafficLevel level;
  final double speed; // km/h

  TrafficSegment({
    required this.points,
    required this.level,
    required this.speed,
  });
}

enum TrafficLevel {
  free,
  light,
  moderate,
  heavy,
  stopped,
}

/// Extended map provider that supports traffic layers
abstract class TrafficEnabledMapProvider extends MapProvider 
    implements ITrafficLayerProvider {
  
  TrafficLayerConfig? _trafficConfig;
  
  @override
  Future<void> enableTrafficLayer(TrafficLayerConfig config) async {
    _trafficConfig = config;
    await _enableTrafficLayerImpl(config);
  }
  
  @override
  Future<void> disableTrafficLayer() async {
    _trafficConfig = null;
    await _disableTrafficLayerImpl();
  }
  
  // Abstract methods for implementation-specific logic
  Future<void> _enableTrafficLayerImpl(TrafficLayerConfig config);
  Future<void> _disableTrafficLayerImpl();
  
  // Getter for current config
  TrafficLayerConfig? get currentTrafficConfig => _trafficConfig;
}

/// Google Maps implementation with traffic support
class GoogleMapProviderWithTraffic extends TrafficEnabledMapProvider {
  final String _apiKey;
  
  GoogleMapProviderWithTraffic(this._apiKey);
  
  @override
  Future<void> _enableTrafficLayerImpl(TrafficLayerConfig config) async {
    // Google Maps specific traffic layer implementation
    // This would integrate with Google Maps traffic layer API
    debugPrint('Enabling Google Maps traffic layer with config: $config');
  }
  
  @override
  Future<void> _disableTrafficLayerImpl() async {
    // Google Maps specific disable logic
    debugPrint('Disabling Google Maps traffic layer');
  }
  
  @override
  Stream<TrafficData> getTrafficUpdates(LatLng center, double radius) async* {
    // Mock traffic data stream
    while (true) {
      await Future.delayed(const Duration(seconds: 30));
      yield TrafficData(
        segments: _generateMockTrafficSegments(center, radius),
        timestamp: DateTime.now(),
        source: TrafficDataSource.realTime,
      );
    }
  }
  
  List<TrafficSegment> _generateMockTrafficSegments(LatLng center, double radius) {
    // Generate mock traffic data for demonstration
    return [
      TrafficSegment(
        points: [
          LatLng(center.latitude - 0.01, center.longitude - 0.01),
          LatLng(center.latitude + 0.01, center.longitude + 0.01),
        ],
        level: TrafficLevel.moderate,
        speed: 45.0,
      ),
    ];
  }
  
  @override
  bool get supportsTrafficLayer => true;
  
  // Implement other MapProvider methods by delegating to existing GoogleMapProvider
  // This shows composition over inheritance
  
  @override
  Future<void> initialize() async {
    // Implementation
  }
  
  @override
  Widget buildMap({
    required LatLng? initialCenter,
    required double initialZoom,
    LatLng? currentLocation,
    dynamic locationMarker,
    dynamic routeAnimation,
    dynamic routeController,
  }) {
    // Build map with traffic layer overlay
    return Stack(
      children: [
        // Base map
        Container(), // GoogleMapProvider().buildMap(...),
        
        // Traffic layer overlay
        if (currentTrafficConfig?.enabled == true)
          _buildTrafficOverlay(),
      ],
    );
  }
  
  Widget _buildTrafficOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: currentTrafficConfig!.trafficColor.withOpacity(
            currentTrafficConfig!.opacity * 0.3,
          ),
        ),
        child: const Center(
          child: Text(
            'Traffic Layer Active',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
  
  @override
  Future<void> moveToLocation(LatLng location) async {
    // Implementation
  }
  
  @override
  void updateLocationMarker(LatLng location, dynamic marker) {
    // Implementation
  }
  
  @override
  void updateRouteAnimation(dynamic controller) {
    // Implementation
  }
  
  @override
  void dispose() {
    // Implementation
  }
  
  @override
  bool get supportsCustomMarkers => true;
  
  @override
  bool get supportsRouteAnimation => true;
  
  @override
  bool get supportsPolylines => true;
}

/// Extended factory that can create traffic-enabled providers
class ExtendedMapProviderFactory extends MapProviderFactory {
  static TrafficEnabledMapProvider createWithTraffic(
    MapType mapType, {
    String? apiKey,
  }) {
    switch (mapType) {
      case MapType.googleMaps:
        if (apiKey == null) {
          throw ArgumentError('Google Maps API key is required');
        }
        return GoogleMapProviderWithTraffic(apiKey);
      
      case MapType.flutterMap:
      case MapType.osmPlugin:
        throw UnsupportedError('Traffic layer not supported for $mapType');
    }
  }
}

/// Widget that demonstrates the scalable traffic feature
class TridentTrackerWithTraffic extends StatefulWidget {
  final MapType mapType;
  final String? googleMapsApiKey;
  final TrafficLayerConfig? trafficConfig;
  final LatLng? initialCenter;
  final double initialZoom;

  const TridentTrackerWithTraffic({
    super.key,
    required this.mapType,
    this.googleMapsApiKey,
    this.trafficConfig,
    this.initialCenter,
    this.initialZoom = 15.0,
  });

  @override
  State<TridentTrackerWithTraffic> createState() => _TridentTrackerWithTrafficState();
}

class _TridentTrackerWithTrafficState extends State<TridentTrackerWithTraffic> {
  late TrafficEnabledMapProvider _mapProvider;
  bool _trafficEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeMapProvider();
  }

  void _initializeMapProvider() {
    try {
      _mapProvider = ExtendedMapProviderFactory.createWithTraffic(
        widget.mapType,
        apiKey: widget.googleMapsApiKey,
      );
      
      if (widget.trafficConfig != null) {
        _enableTraffic();
      }
    } catch (e) {
      // Handle unsupported map types gracefully
      debugPrint('Traffic not supported for ${widget.mapType}: $e');
    }
  }

  Future<void> _toggleTraffic() async {
    if (_trafficEnabled) {
      await _mapProvider.disableTrafficLayer();
    } else {
      await _mapProvider.enableTrafficLayer(
        widget.trafficConfig ?? const TrafficLayerConfig(),
      );
    }
    
    setState(() {
      _trafficEnabled = !_trafficEnabled;
    });
  }

  Future<void> _enableTraffic() async {
    if (widget.trafficConfig != null) {
      await _mapProvider.enableTrafficLayer(widget.trafficConfig!);
      setState(() {
        _trafficEnabled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _mapProvider.buildMap(
        initialCenter: widget.initialCenter,
        initialZoom: widget.initialZoom,
        currentLocation: null,
        locationMarker: null,
        routeAnimation: null,
        routeController: null,
      ),
      floatingActionButton: _mapProvider.supportsTrafficLayer
          ? FloatingActionButton(
              onPressed: _toggleTraffic,
              tooltip: _trafficEnabled ? 'Disable Traffic' : 'Enable Traffic',
              child: Icon(
                _trafficEnabled ? Icons.traffic : Icons.traffic_outlined,
                color: _trafficEnabled ? Colors.red : null,
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _mapProvider.dispose();
    super.dispose();
  }
}