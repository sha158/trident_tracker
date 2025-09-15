import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trident_tracker/trident_tracker.dart';

/// Simple test to verify real roads functionality
class SimpleRealRoadsTest extends StatelessWidget {
  const SimpleRealRoadsTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Roads Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Real Roads Test'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade50,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🧪 Real Roads Test',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('This test will show a route from Berlin to Munich, Germany.'),
                  Text('• GREEN line = Real roads (should follow highways)'),
                  Text('• Check console for route calculation logs'),
                  Text('• Route should have 100+ points if working correctly'),
                ],
              ),
            ),
            
            // Map with real roads
            Expanded(
              child: TridentTracker(
                mapType: MapType.flutterMap,
                showCurrentLocation: false,
                initialCenter: const LatLng(52.5200, 13.4050), // Berlin
                initialZoom: 6.0, // Zoom out to see full route
                routeAnimation: TridentRouteAnimation(
                  startPoint: const LatLng(52.5200, 13.4050), // Berlin
                  endPoint: const LatLng(48.1351, 11.5820),   // Munich
                  duration: const Duration(seconds: 30),
                  autoStart: true,
                  useRealRoads: true,
                  polylineColor: Colors.green,
                  polylineWidth: 5.0,
                  routeService: RouteServiceFactory.create(),
                  animatedMarker: TridentLocationMarker.fromWidget(
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  onRouteStart: () {
                    print('🚗 Route animation started');
                  },
                  onProgress: (progress) {
                    if (progress == 0.0 || progress % 0.1 < 0.01) {
                      print('🛣️ Route progress: ${(progress * 100).toStringAsFixed(0)}%');
                    }
                  },
                  onRouteComplete: () {
                    print('🏁 Route animation completed');
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Manual test of route service
            _testRouteService(context);
          },
          label: const Text('Test Route API'),
          icon: const Icon(Icons.api),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  Future<void> _testRouteService(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Testing route service...'),
          ],
        ),
      ),
    );

    try {
      final routeService = RouteServiceFactory.create();
      print('🧪 Manual route service test starting...');
      
      final result = await routeService.calculateRoute(
        start: const LatLng(52.5200, 13.4050), // Berlin
        end: const LatLng(48.1351, 11.5820),   // Munich
        profile: RouteProfile.driving,
      );

      Navigator.of(context).pop(); // Close loading dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('✅ Route Service Test Result'),
          content: Text(
            'Route calculated successfully!\n\n'
            'Points: ${result.coordinates.length}\n'
            'Distance: ${(result.distance / 1000).toStringAsFixed(0)} km\n'
            'Duration: ${(result.duration / 3600).toStringAsFixed(1)} hours\n'
            'Profile: ${result.profile}\n\n'
            'First point: ${result.coordinates.first.latitude.toStringAsFixed(4)}, ${result.coordinates.first.longitude.toStringAsFixed(4)}\n'
            'Last point: ${result.coordinates.last.latitude.toStringAsFixed(4)}, ${result.coordinates.last.longitude.toStringAsFixed(4)}'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      print('✅ Manual test successful: ${result.coordinates.length} points');
      
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('❌ Route Service Test Failed'),
          content: Text(
            'Error: $e\n\n'
            'This means:\n'
            '• No internet connection, OR\n'
            '• OSRM server is down, OR\n'
            '• Network restrictions\n\n'
            'The animation will fall back to straight-line routing.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      
      print('❌ Manual test failed: $e');
    }
  }
}

/// Comparison widget showing both real and fake routes
class ComparisonWidget extends StatelessWidget {
  const ComparisonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Real vs Fake Routes'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'REAL ROADS', icon: Icon(Icons.route)),
              Tab(text: 'STRAIGHT LINE', icon: Icon(Icons.trending_up)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Real roads
            _buildMap(
              useRealRoads: true,
              color: Colors.green,
              title: 'Real Roads (should follow highways)',
            ),
            
            // Straight line
            _buildMap(
              useRealRoads: false,
              color: Colors.red,
              title: 'Straight Line (cuts through everything)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap({
    required bool useRealRoads,
    required Color color,
    required String title,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: color.withOpacity(0.1),
          child: Row(
            children: [
              Icon(useRealRoads ? Icons.route : Icons.trending_up, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TridentTracker(
            mapType: MapType.flutterMap,
            showCurrentLocation: false,
            initialCenter: const LatLng(52.5200, 13.4050), // Berlin
            initialZoom: 6.0,
            routeAnimation: TridentRouteAnimation(
              startPoint: const LatLng(52.5200, 13.4050), // Berlin
              endPoint: const LatLng(48.1351, 11.5820),   // Munich
              duration: const Duration(seconds: 25),
              autoStart: true,
              useRealRoads: useRealRoads,
              polylineColor: color,
              polylineWidth: 4.0,
              animatedMarker: TridentLocationMarker.fromWidget(
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}