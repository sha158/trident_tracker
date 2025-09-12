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
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Custom Location Demo'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.layers), text: 'Flutter Map'),
              Tab(icon: Icon(Icons.public), text: 'OSM Plugin'),
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
          ],
        ),
      ),
    );
  }
}