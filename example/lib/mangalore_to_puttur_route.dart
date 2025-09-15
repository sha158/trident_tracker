import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trident_tracker/trident_tracker.dart';

/// Real route example: Mangalore to Puttur via NH75
class MangaloreToPutturRoute extends StatefulWidget {
  const MangaloreToPutturRoute({super.key});

  @override
  State<MangaloreToPutturRoute> createState() => _MangaloreToPutturRouteState();
}

class _MangaloreToPutturRouteState extends State<MangaloreToPutturRoute> {
  String _status = 'Ready to start journey';
  TridentRouteAnimation? _currentAnimation;

  // Mangalore to Puttur coordinates
  final LatLng _mangalore = const LatLng(12.9141, 74.8560); // Mangalore city center
  final LatLng _puttur = const LatLng(12.7593, 75.2063);    // Puttur town center

  // Strategic waypoints to ensure route follows NH75 highway
  final List<LatLng> _nh75Waypoints = [
    const LatLng(12.8800, 74.9200), // Towards Bantwal
    const LatLng(12.8400, 75.0300), // Bantwal area
    const LatLng(12.8000, 75.1200), // En route to Puttur
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mangalore → Puttur Route'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Route information panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.route, color: Colors.green, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Mangalore to Puttur via NH75',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Distance: ~40 km | Highway: NH75 | Duration: ~1 hour'),
                const Text('Route: Mangalore → Bantwal → Puttur'),
                const SizedBox(height: 8),
                Text(
                  'Status: $_status',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _startRealRoadsRoute,
                        icon: const Icon(Icons.route),
                        label: const Text('Real Roads Route'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _startStraightLineRoute,
                        icon: const Icon(Icons.trending_up),
                        label: const Text('Straight Line'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
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
              initialCenter: _mangalore,
              initialZoom: 10.0, // Zoom to show both cities
              routeAnimation: _currentAnimation,
            ),
          ),
        ],
      ),
    );
  }

  void _startRealRoadsRoute() {
    setState(() {
      _status = 'Calculating route via NH75 highway...';
      
      _currentAnimation = TridentRouteAnimation(
        startPoint: _mangalore,
        endPoint: _puttur,
        waypoints: _nh75Waypoints, // Force route through NH75
        duration: const Duration(seconds: 30), // Longer duration for 40km route
        autoStart: true,
        useRealRoads: true,
        routeService: RouteServiceFactory.create(),
        polylineColor: Colors.green,
        polylineWidth: 4.0,
        animatedMarker: TridentLocationMarker.fromWidget(
          Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        onRouteStart: () {
          setState(() {
            _status = 'Journey started: Mangalore → Puttur via NH75';
          });
          print('🚗 Real roads route started: Mangalore to Puttur');
        },
        onProgress: (progress) {
          final percentage = (progress * 100).toStringAsFixed(1);
          setState(() {
            if (progress < 0.3) {
              _status = 'Driving through Mangalore city ($percentage%)';
            } else if (progress < 0.6) {
              _status = 'On NH75 highway towards Bantwal ($percentage%)';
            } else if (progress < 0.9) {
              _status = 'Approaching Puttur town ($percentage%)';
            } else {
              _status = 'Almost reached Puttur ($percentage%)';
            }
          });
        },
        onRouteComplete: () {
          setState(() {
            _status = 'Journey completed! Reached Puttur safely 🎉';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Successfully reached Puttur via NH75!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    });
  }

  void _startStraightLineRoute() {
    setState(() {
      _status = 'Creating straight line route (unrealistic)...';
      
      _currentAnimation = TridentRouteAnimation(
        startPoint: _mangalore,
        endPoint: _puttur,
        duration: const Duration(seconds: 15),
        autoStart: true,
        useRealRoads: false, // Straight line for comparison
        polylineColor: Colors.red,
        polylineWidth: 4.0,
        animatedMarker: TridentLocationMarker.fromWidget(
          Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        onRouteStart: () {
          setState(() {
            _status = 'Flying in straight line (not realistic)';
          });
        },
        onProgress: (progress) {
          setState(() {
            _status = 'Straight line progress: ${(progress * 100).toStringAsFixed(1)}%';
          });
        },
        onRouteComplete: () {
          setState(() {
            _status = 'Straight line completed (cuts through hills!)';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Straight line route completed (unrealistic)'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });
  }
}

/// Alternative version with more detailed waypoints
class DetailedMangalorePutturRoute extends StatelessWidget {
  const DetailedMangalorePutturRoute({super.key});

  @override
  Widget build(BuildContext context) {
    // More detailed waypoints for better road following
    const detailedWaypoints = [
      LatLng(12.9000, 74.8800), // Exit Mangalore via Pumpwell
      LatLng(12.8800, 74.9200), // Heading towards Bantwal
      LatLng(12.8500, 75.0000), // Near Bantwal junction
      LatLng(12.8300, 75.0500), // Through Bantwal town
      LatLng(12.8100, 75.1200), // On road to Puttur
      LatLng(12.7800, 75.1800), // Approaching Puttur
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed NH75 Route'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🛣️ Detailed NH75 Route with Multiple Waypoints',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('This version uses 6 waypoints to ensure accurate road following:'),
                Text('Mangalore → Pumpwell → Bantwal → Puttur'),
              ],
            ),
          ),
          Expanded(
            child: TridentTracker(
              mapType: MapType.flutterMap,
              showCurrentLocation: false,
              initialCenter: const LatLng(12.8367, 75.0313), // Midpoint between cities
              initialZoom: 9.5,
              routeAnimation: TridentRouteAnimation.vehicle(
                startPoint: const LatLng(12.9141, 74.8560), // Mangalore
                endPoint: const LatLng(12.7593, 75.2063),   // Puttur
                waypoints: detailedWaypoints,
                duration: const Duration(seconds: 40),
                useRealRoads: true,
                onComplete: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎯 Detailed route completed!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick test version
class QuickMangaloreTest extends StatelessWidget {
  const QuickMangaloreTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mangalore-Puttur Route Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Quick Route Test'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: TridentTracker(
          mapType: MapType.flutterMap,
          showCurrentLocation: false,
          initialCenter: const LatLng(12.8367, 75.0313),
          initialZoom: 9.5,
          routeAnimation: TridentRouteAnimation.vehicle(
            startPoint: const LatLng(12.9141, 74.8560), // Mangalore
            endPoint: const LatLng(12.7593, 75.2063),   // Puttur
            waypoints: const [
              LatLng(12.8400, 75.0300), // Via Bantwal
            ],
            duration: const Duration(seconds: 25),
            useRealRoads: true,
            onComplete: () {
              print('🏁 Mangalore to Puttur route completed!');
            },
          ),
        ),
      ),
    );
  }
}