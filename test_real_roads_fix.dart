import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trident_tracker/trident_tracker.dart';

/// Test to verify the real roads fix works correctly
void main() {
  runApp(const TestRealRoadsFix());
}

class TestRealRoadsFix extends StatelessWidget {
  const TestRealRoadsFix({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Roads Fix Test',
      home: const RealRoadsTestPage(),
    );
  }
}

class RealRoadsTestPage extends StatefulWidget {
  const RealRoadsTestPage({super.key});

  @override
  State<RealRoadsTestPage> createState() => _RealRoadsTestPageState();
}

class _RealRoadsTestPageState extends State<RealRoadsTestPage> {
  String _status = 'Ready to test real roads fix';

  // Mangalore to Puttur coordinates with strategic waypoints
  final LatLng _mangalore = const LatLng(12.9141, 74.8560);
  final LatLng _puttur = const LatLng(12.7593, 75.2063);
  final List<LatLng> _waypoints = [
    const LatLng(12.8800, 74.9200), // Towards Bantwal
    const LatLng(12.8400, 75.0300), // Bantwal area
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real Roads Fix Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🧪 Testing Real Roads Fix',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Status: $_status'),
                const SizedBox(height: 8),
                const Text('Expected: You should see debug logs starting with:'),
                const Text('🔄 Setting up REAL ROADS animation...'),
                const Text('🛣️ Calculating real road route from...'),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _startTest,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Real Roads Test'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),
          ),
          Expanded(
            child: TridentTracker(
              mapType: MapType.flutterMap,
              showCurrentLocation: false,
              initialCenter: _mangalore,
              initialZoom: 9.0,
              routeAnimation: TridentRouteAnimation(
                startPoint: _mangalore,
                endPoint: _puttur,
                waypoints: _waypoints,
                duration: const Duration(seconds: 25),
                autoStart: false, // Manual start
                useRealRoads: true, // This should now work!
                routeService: RouteServiceFactory.create(), // Explicit route service
                polylineColor: Colors.blue,
                polylineWidth: 4.0,
                animatedMarker: TridentLocationMarker.fromWidget(
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                onRouteStart: () {
                  setState(() {
                    _status = 'Real roads route started! Check console for logs.';
                  });
                  print('✅ Real roads route animation started successfully!');
                },
                onProgress: (progress) {
                  setState(() {
                    _status = 'Real roads progress: ${(progress * 100).toStringAsFixed(1)}%';
                  });
                },
                onRouteComplete: () {
                  setState(() {
                    _status = 'Real roads route completed successfully!';
                  });
                  print('🎉 Real roads route completed!');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startTest() {
    setState(() {
      _status = 'Starting real roads test...';
    });
    print('🧪 Starting real roads test - check for debug logs above');
    // The route animation should start automatically when the widget rebuilds
  }
}