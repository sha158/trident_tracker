import 'package:flutter/material.dart';
import 'package:trident_tracker/trident_tracker.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TridentTracker Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MapSelectionScreen(),
    );
  }
}

class MapSelectionScreen extends StatelessWidget {
  const MapSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TridentTracker Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.map,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 32),
            const Text(
              'Choose a Map Implementation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'TridentTracker supports two different map implementations. Select one to see it in action.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapScreen(
                      mapType: MapType.flutterMap,
                      title: 'Flutter Map Demo',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.layers),
              label: const Text('Flutter Map'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapScreen(
                      mapType: MapType.osmPlugin,
                      title: 'OSM Plugin Demo',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.public),
              label: const Text('OSM Plugin'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GoogleMapsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.satellite),
              label: const Text('Google Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomLocationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.location_city),
              label: const Text('Custom Location Demo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomMarkerScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.push_pin),
              label: const Text('Custom Marker Demo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RouteAnimationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.route),
              label: const Text('Route Animation Demo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MapScreen extends StatelessWidget {
  final MapType mapType;
  final String title;

  const MapScreen({
    super.key,
    required this.mapType,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: TridentTracker(
        mapType: mapType,
        onLocationPermissionDenied: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission is required to show your current position.'),
              backgroundColor: Colors.orange,
            ),
          );
        },
      ),
    );
  }
}

class CustomLocationScreen extends StatelessWidget {
  const CustomLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Custom Location Demo'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.layers), text: 'Flutter Map'),
              Tab(icon: Icon(Icons.public), text: 'OSM Plugin'),
              Tab(icon: Icon(Icons.satellite), text: 'Google Maps'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TridentTracker(
              mapType: MapType.flutterMap,
              initialCenter: const LatLng(40.7589, -73.9851), // New York
              initialZoom: 12.0,
              showCurrentLocation: false,
            ),
            TridentTracker(
              mapType: MapType.osmPlugin,
              initialCenter: const LatLng(48.8566, 2.3522), // Paris
              initialZoom: 12.0,
              showCurrentLocation: false,
            ),
            TridentTracker(
              mapType: MapType.googleMaps,
              googleMapsApiKey: const String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: 'demo-key'),
              initialCenter: const LatLng(37.7749, -122.4194), // San Francisco
              initialZoom: 12.0,
              showCurrentLocation: false,
              onGoogleMapsApiKeyError: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Google Maps API key is required. Please set GOOGLE_MAPS_API_KEY environment variable.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}




class GoogleMapsScreen extends StatelessWidget {
  const GoogleMapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Google Maps requires an API key. Set GOOGLE_MAPS_API_KEY environment variable or replace the demo key below.',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TridentTracker(
              mapType: MapType.googleMaps,
              googleMapsApiKey: const String.fromEnvironment(
                'GOOGLE_MAPS_API_KEY', 
                defaultValue: 'demo-key-replace-with-real-key'
              ),
              onGoogleMapsApiKeyError: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Google Maps API key is required. Please:\n'
                      '1. Get an API key from Google Cloud Console\n'
                      '2. Set GOOGLE_MAPS_API_KEY environment variable\n'
                      '3. Configure platform-specific settings',
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 5),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomMarkerScreen extends StatelessWidget {
  const CustomMarkerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Custom Marker Demo'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.circle), text: 'Default Blue'),
              Tab(icon: Icon(Icons.circle), text: 'Custom Color'),
              Tab(icon: Icon(Icons.widgets), text: 'Custom Widget'),
              Tab(icon: Icon(Icons.animation), text: 'Pulsing'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Default Blue Marker
            TridentTracker(
              mapType: MapType.flutterMap,
              locationMarker: TridentLocationMarker.defaultBlue(
                title: 'You are here!',
                description: 'Default blue marker',
              ),
            ),
            
            // Custom Color Marker
            TridentTracker(
              mapType: MapType.flutterMap,
              locationMarker: TridentLocationMarker.defaultRed(
                size: const Size(50, 50),
                title: 'Custom Red Marker',
                description: 'Larger red location marker',
              ),
            ),
            
            // Custom Widget Marker
            TridentTracker(
              mapType: MapType.flutterMap,
              locationMarker: TridentLocationMarker.fromWidget(
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.pink],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                title: 'Custom Widget',
                description: 'Beautiful gradient marker with shadow',
              ),
            ),
            
            // Pulsing Marker
            TridentTracker(
              mapType: MapType.flutterMap,
              locationMarker: TridentLocationMarker.pulsing(
                color: Colors.green,
                size: const Size(45, 45),
                title: 'Pulsing Marker',
                description: 'Animated pulsing effect',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RouteAnimationScreen extends StatefulWidget {
  const RouteAnimationScreen({super.key});

  @override
  State<RouteAnimationScreen> createState() => _RouteAnimationScreenState();
}

class _RouteAnimationScreenState extends State<RouteAnimationScreen> {
  // Sample route points
  final LatLng _startPoint = const LatLng(37.7749, -122.4194); // San Francisco
  final LatLng _endPoint = const LatLng(37.7849, -122.4094); // About 1km north
  final List<LatLng> _waypoints = [
    const LatLng(37.7799, -122.4144), // Midpoint
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Route Animation Demo'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car), text: 'Vehicle'),
              Tab(icon: Icon(Icons.motorcycle), text: 'Delivery'),
              Tab(icon: Icon(Icons.directions_walk), text: 'Walking'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Vehicle Animation
            _buildRouteAnimationMap(
              TridentRouteAnimation.vehicle(
                startPoint: _startPoint,
                endPoint: _endPoint,
                waypoints: _waypoints,
                duration: const Duration(seconds: 15),
                onComplete: () => _showCompletionSnackBar('Vehicle route completed!'),
              ),
            ),
            
            // Delivery Animation
            _buildRouteAnimationMap(
              TridentRouteAnimation.delivery(
                startPoint: _startPoint,
                endPoint: _endPoint,
                waypoints: _waypoints,
                duration: const Duration(seconds: 12),
                onComplete: () => _showCompletionSnackBar('Delivery completed!'),
              ),
            ),
            
            // Walking Animation
            _buildRouteAnimationMap(
              TridentRouteAnimation.walking(
                startPoint: _startPoint,
                endPoint: _endPoint,
                waypoints: _waypoints,
                duration: const Duration(seconds: 20),
                onComplete: () => _showCompletionSnackBar('Walking route completed!'),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _startRoute,
          label: const Text('Start Route'),
          icon: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }

  Widget _buildRouteAnimationMap(TridentRouteAnimation routeAnimation) {
    return TridentTracker(
      mapType: MapType.flutterMap,
      showCurrentLocation: false,
      initialCenter: _startPoint,
      initialZoom: 14.0,
      routeAnimation: routeAnimation,
    );
  }

  void _startRoute() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Route animation started! Routes auto-start when configured.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showCompletionSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}