import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trident_tracker/src/trident_tracker_refactored.dart';
import 'package:trident_tracker/src/features/traffic_layer_feature.dart';
import 'package:trident_tracker/trident_tracker.dart';

/// Example demonstrating SOLID principles and scalability
class SolidPrinciplesExample extends StatelessWidget {
  const SolidPrinciplesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOLID Principles Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SolidPrinciplesScreen(),
    );
  }
}

class SolidPrinciplesScreen extends StatelessWidget {
  const SolidPrinciplesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOLID Principles & Scalability Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'SOLID Principles Implementation',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            _buildPrincipleCard(
              'Single Responsibility',
              'Each class has one reason to change',
              Icons.single_bed,
              Colors.blue,
            ),
            
            _buildPrincipleCard(
              'Open/Closed',
              'Open for extension, closed for modification',
              Icons.extension,
              Colors.green,
            ),
            
            _buildPrincipleCard(
              'Liskov Substitution',
              'Objects are replaceable with instances of subtypes',
              Icons.swap_horiz,
              Colors.orange,
            ),
            
            _buildPrincipleCard(
              'Interface Segregation',
              'Many client-specific interfaces',
              Icons.view_module,
              Colors.purple,
            ),
            
            _buildPrincipleCard(
              'Dependency Inversion',
              'Depend on abstractions, not concretions',
              Icons.device_hub,
              Colors.red,
            ),
            
            const SizedBox(height: 30),
            
            ElevatedButton.icon(
              onPressed: () => _showRefactoredExample(context),
              icon: const Icon(Icons.architecture),
              label: const Text('View Refactored Map'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () => _showTrafficExample(context),
              icon: const Icon(Icons.traffic),
              label: const Text('View Scalable Traffic Feature'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () => _showComparison(context),
              icon: const Icon(Icons.compare),
              label: const Text('Compare Before/After'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrincipleCard(String title, String description, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRefactoredExample(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RefactoredMapExample(),
      ),
    );
  }

  void _showTrafficExample(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TrafficFeatureExample(),
      ),
    );
  }

  void _showComparison(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ComparisonExample(),
      ),
    );
  }
}

/// Example using the refactored SOLID-compliant TridentTracker
class RefactoredMapExample extends StatelessWidget {
  const RefactoredMapExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refactored Map (SOLID Principles)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: TridentTrackerRefactored(
        mapType: MapType.flutterMap,
        showCurrentLocation: true,
        routeAnimation: TridentRouteAnimation.vehicle(
          startPoint: const LatLng(37.7749, -122.4194),
          endPoint: const LatLng(37.7849, -122.4094),
          duration: const Duration(seconds: 15),
          onComplete: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Route completed using SOLID principles!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
        onLocationPermissionDenied: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission handled by interface'),
              backgroundColor: Colors.orange,
            ),
          );
        },
      ),
    );
  }
}

/// Example of the new scalable traffic feature
class TrafficFeatureExample extends StatelessWidget {
  const TrafficFeatureExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scalable Traffic Feature'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: TridentTrackerWithTraffic(
        mapType: MapType.googleMaps,
        googleMapsApiKey: "demo-key", // Would use real key in production
        initialCenter: const LatLng(37.7749, -122.4194),
        trafficConfig: const TrafficLayerConfig(
          enabled: true,
          trafficColor: Colors.red,
          opacity: 0.8,
          dataSource: TrafficDataSource.realTime,
        ),
      ),
    );
  }
}

/// Comparison showing before/after SOLID implementation
class ComparisonExample extends StatelessWidget {
  const ComparisonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Before vs After SOLID'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Before (Monolithic)', icon: Icon(Icons.warning)),
              Tab(text: 'After (SOLID)', icon: Icon(Icons.check_circle)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Before: Original implementation
            _buildComparisonSection(
              'Original Implementation Issues',
              [
                '❌ TridentTrackerState handles everything',
                '❌ Adding new maps modifies existing code',
                '❌ Tight coupling between components',
                '❌ Hard to test individual components',
                '❌ Difficult to extend with new features',
              ],
              Colors.red.shade100,
            ),
            
            // After: SOLID implementation
            _buildComparisonSection(
              'SOLID Implementation Benefits',
              [
                '✅ Single responsibility for each class',
                '✅ Easy to add new map providers',
                '✅ Loose coupling through interfaces',
                '✅ Each component is testable',
                '✅ Features extend without modification',
              ],
              Colors.green.shade100,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonSection(String title, List<String> points, Color backgroundColor) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...points.map((point) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              point,
              style: const TextStyle(fontSize: 16),
            ),
          )),
          const SizedBox(height: 30),
          
          if (title.contains('SOLID')) ...[
            const Text(
              'Scalability Example:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: const Text(
                'Adding traffic layer feature:\n\n'
                '1. Create ITrafficLayerProvider interface\n'
                '2. Extend TrafficEnabledMapProvider\n'
                '3. Implement GoogleMapProviderWithTraffic\n'
                '4. No modifications to existing code!\n\n'
                'This demonstrates Open/Closed Principle - '
                'open for extension, closed for modification.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}