import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trident_tracker/trident_tracker.dart';

/// Debug example to verify real roads are working
class DebugRealRoadsExample extends StatefulWidget {
  const DebugRealRoadsExample({super.key});

  @override
  State<DebugRealRoadsExample> createState() => _DebugRealRoadsExampleState();
}

class _DebugRealRoadsExampleState extends State<DebugRealRoadsExample> {
  String _debugInfo = 'Initializing...';
  bool _useRealRoads = true;
  TridentRouteAnimation? _currentAnimation;

  // Test route: San Francisco (downtown) to North Beach
  final LatLng _startPoint = const LatLng(37.7749, -122.4194); // Downtown SF
  final LatLng _endPoint = const LatLng(37.8049, -122.4094);   // North Beach

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Real Roads'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Debug information panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bug_report, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text(
                      'Debug Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Text(
                  'Route Settings:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('• Use Real Roads: $_useRealRoads'),
                Text('• Start: ${_startPoint.latitude.toStringAsFixed(4)}, ${_startPoint.longitude.toStringAsFixed(4)}'),
                Text('• End: ${_endPoint.latitude.toStringAsFixed(4)}, ${_endPoint.longitude.toStringAsFixed(4)}'),
                
                const SizedBox(height: 8),
                Text(
                  'Status:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(_debugInfo),
                
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _toggleRealRoads,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _useRealRoads ? Colors.green : Colors.red,
                        ),
                        child: Text(_useRealRoads ? 'Real Roads ON' : 'Real Roads OFF'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _restartAnimation,
                        child: const Text('Restart Route'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Map
          Expanded(
            child: TridentTracker(
              mapType: MapType.flutterMap,
              showCurrentLocation: false,
              initialCenter: _startPoint,
              initialZoom: 13.0,
              routeAnimation: _currentAnimation,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleRealRoads() {
    setState(() {
      _useRealRoads = !_useRealRoads;
      _debugInfo = 'Toggled to ${_useRealRoads ? "Real Roads" : "Straight Lines"}';
    });
    _restartAnimation();
  }

  void _restartAnimation() {
    setState(() {
      _debugInfo = 'Creating new route animation...';
      
      _currentAnimation = TridentRouteAnimation(
        startPoint: _startPoint,
        endPoint: _endPoint,
        duration: const Duration(seconds: 15),
        autoStart: true,
        useRealRoads: _useRealRoads,
        routeService: RouteServiceFactory.create(), // Explicitly create route service
        polylineColor: _useRealRoads ? Colors.green : Colors.red,
        polylineWidth: 4.0,
        animatedMarker: TridentLocationMarker.fromWidget(
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _useRealRoads ? Colors.green : Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
        onRouteStart: () {
          setState(() {
            _debugInfo = 'Route animation started with ${_useRealRoads ? "real roads" : "straight lines"}';
          });
        },
        onProgress: (progress) {
          setState(() {
            _debugInfo = 'Progress: ${(progress * 100).toStringAsFixed(1)}% (${_useRealRoads ? "Real Roads" : "Straight Lines"})';
          });
        },
        onRouteComplete: () {
          setState(() {
            _debugInfo = 'Route completed! Check console for route calculation logs.';
          });
        },
        onPositionChanged: (position) {
          // This callback will show if the route is being calculated
          if (_debugInfo.contains('Creating')) {
            setState(() {
              _debugInfo = 'Route calculated and animation running (${_useRealRoads ? "Real Roads" : "Straight Lines"})';
            });
          }
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    // Start with initial animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restartAnimation();
    });
  }
}

/// Simple test to verify route service is working
class RouteServiceTest extends StatefulWidget {
  const RouteServiceTest({super.key});

  @override
  State<RouteServiceTest> createState() => _RouteServiceTestState();
}

class _RouteServiceTestState extends State<RouteServiceTest> {
  String _testResult = 'Not tested yet';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Service Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Route Service Direct Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testOSRMService,
              icon: _isLoading ? 
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ) : 
                const Icon(Icons.router),
              label: Text(_isLoading ? 'Testing...' : 'Test OSRM Route Service'),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Result:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_testResult),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Expected Behavior:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('✅ Route service should return coordinates following actual roads'),
            const Text('✅ Should have more than 2 points (start and end)'),
            const Text('✅ Should calculate realistic distance and duration'),
            const Text('❌ If test fails, it will fall back to straight-line interpolation'),
          ],
        ),
      ),
    );
  }

  Future<void> _testOSRMService() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing OSRM route service...';
    });

    try {
      final routeService = RouteServiceFactory.create();
      
      final startPoint = LatLng(37.7749, -122.4194); // San Francisco
      final endPoint = LatLng(37.8049, -122.4094);   // North Beach
      
      print('🧪 Testing route service...');
      final result = await routeService.calculateRoute(
        start: startPoint,
        end: endPoint,
        profile: RouteProfile.driving,
      );
      
      setState(() {
        _isLoading = false;
        _testResult = '''✅ SUCCESS!
Route calculated with ${result.coordinates.length} points
Distance: ${(result.distance / 1000).toStringAsFixed(2)} km
Duration: ${(result.duration / 60).toStringAsFixed(1)} minutes
Profile: ${result.profile}

First 3 points:
${result.coordinates.take(3).map((p) => '${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)}').join('\n')}
''';
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _testResult = '''❌ FAILED!
Error: $e

This means the route service is not working, so real roads won't work.
The animation will fall back to straight-line interpolation.

Check:
1. Internet connection
2. OSRM server availability
3. Correct coordinates format
''';
      });
    }
  }
}