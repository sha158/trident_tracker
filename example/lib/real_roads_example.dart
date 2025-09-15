import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trident_tracker/trident_tracker.dart';
import 'package:trident_tracker/src/services/route_service.dart';

/// Example demonstrating real road routing vs straight lines
class RealRoadsExample extends StatelessWidget {
  const RealRoadsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Roads vs Straight Lines',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RealRoadsScreen(),
    );
  }
}

class RealRoadsScreen extends StatelessWidget {
  const RealRoadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real Roads vs Straight Lines'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Route Following Comparison',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            const Text(
              'See the difference between straight-line routing and real road following:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            ElevatedButton.icon(
              onPressed: () => _showStraightLineRoute(context),
              icon: const Icon(Icons.trending_up),
              label: const Text('Straight Line Route (Old)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () => _showRealRoadRoute(context),
              icon: const Icon(Icons.route),
              label: const Text('Real Road Route (New)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () => _showComparison(context),
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Side-by-Side Comparison'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 30),
            
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Real Road Routing Features:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('✅ Follows actual roads and paths'),
                    Text('✅ Respects traffic rules and restrictions'),
                    Text('✅ Different profiles (driving, walking, cycling)'),
                    Text('✅ Accurate distance and time calculations'),
                    Text('✅ Automatic fallback if API unavailable'),
                    Text('✅ Uses OpenStreetMap (free) or Google Maps'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStraightLineRoute(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StraightLineRouteExample(),
      ),
    );
  }

  void _showRealRoadRoute(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RealRoadRouteExample(),
      ),
    );
  }

  void _showComparison(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ComparisonRouteExample(),
      ),
    );
  }
}

/// Example showing old straight-line routing
class StraightLineRouteExample extends StatelessWidget {
  const StraightLineRouteExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Straight Line Route (Old)'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: TridentTracker(
        mapType: MapType.flutterMap,
        showCurrentLocation: false,
        initialCenter: const LatLng(37.7749, -122.4194), // San Francisco
        initialZoom: 13.0,
        routeAnimation: TridentRouteAnimation.vehicle(
          startPoint: const LatLng(37.7749, -122.4194), // Downtown SF
          endPoint: const LatLng(37.8049, -122.4094),   // North Beach
          waypoints: const [
            LatLng(37.7849, -122.4144), // Union Square
          ],
          duration: const Duration(seconds: 20),
          useRealRoads: false, // Force straight line routing
          onComplete: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Straight line route completed! Notice how it cuts through buildings and water.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Straight Lines'),
        icon: const Icon(Icons.trending_up),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/// Example showing new real road routing
class RealRoadRouteExample extends StatelessWidget {
  const RealRoadRouteExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real Road Route (New)'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: TridentTracker(
        mapType: MapType.flutterMap,
        showCurrentLocation: false,
        initialCenter: const LatLng(37.7749, -122.4194), // San Francisco
        initialZoom: 13.0,
        routeAnimation: TridentRouteAnimation.vehicle(
          startPoint: const LatLng(37.7749, -122.4194), // Downtown SF
          endPoint: const LatLng(37.8049, -122.4094),   // North Beach
          waypoints: const [
            LatLng(37.7849, -122.4144), // Union Square
          ],
          duration: const Duration(seconds: 25),
          useRealRoads: true, // Use real road routing
          routeService: RouteServiceFactory.create(), // Uses OSRM by default
          onComplete: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Real road route completed! Notice how it follows actual streets.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 4),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Real Roads'),
        icon: const Icon(Icons.route),
        backgroundColor: Colors.green,
      ),
    );
  }
}

/// Side-by-side comparison
class ComparisonRouteExample extends StatelessWidget {
  const ComparisonRouteExample({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Route Comparison'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Straight Line', icon: Icon(Icons.trending_up)),
              Tab(text: 'Real Roads', icon: Icon(Icons.route)),
              Tab(text: 'Different Profiles', icon: Icon(Icons.directions)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Straight line route
            _buildRouteMap(
              useRealRoads: false,
              color: Colors.red,
              label: 'Straight Line (cuts through everything)',
            ),
            
            // Real road route
            _buildRouteMap(
              useRealRoads: true,
              color: Colors.green,
              label: 'Real Roads (follows streets)',
            ),
            
            // Different route profiles
            _buildProfileComparison(),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteMap({
    required bool useRealRoads,
    required Color color,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: color.withOpacity(0.1),
          child: Row(
            children: [
              Icon(
                useRealRoads ? Icons.route : Icons.trending_up,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
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
            initialCenter: const LatLng(37.7749, -122.4194),
            initialZoom: 13.0,
            routeAnimation: TridentRouteAnimation(
              startPoint: const LatLng(37.7749, -122.4194),
              endPoint: const LatLng(37.8049, -122.4094),
              waypoints: const [LatLng(37.7849, -122.4144)],
              duration: const Duration(seconds: 15),
              useRealRoads: useRealRoads,
              polylineColor: color,
              polylineWidth: 4.0,
              autoStart: true,
              animatedMarker: TridentLocationMarker.fromWidget(
                Icon(
                  Icons.directions_car,
                  color: color,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileComparison() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.withOpacity(0.1),
          child: const Row(
            children: [
              Icon(Icons.directions, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Different Transportation Modes',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
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
            initialCenter: const LatLng(37.7749, -122.4194),
            initialZoom: 13.0,
            routeAnimation: TridentRouteAnimation.walking(
              startPoint: const LatLng(37.7749, -122.4194),
              endPoint: const LatLng(37.7849, -122.4144),
              duration: const Duration(seconds: 20),
              useRealRoads: true,
              onComplete: () {
                // Could show different route types sequentially
              },
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'This example shows walking routes, which follow pedestrian paths and may differ from driving routes.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}