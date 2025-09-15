import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:http/http.dart' as http;

// Standalone route service test without Flutter dependencies

class LatLng {
  final double latitude;
  final double longitude;
  
  const LatLng(this.latitude, this.longitude);
  
  @override
  String toString() => 'LatLng($latitude, $longitude)';
}

class RouteResult {
  final List<LatLng> coordinates;
  final double distance;
  final int duration;
  
  RouteResult({
    required this.coordinates,
    required this.distance,
    required this.duration,
  });
}

class OSRMRouteService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1';
  final http.Client _httpClient;

  OSRMRouteService() : _httpClient = http.Client();

  Future<RouteResult> calculateRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    try {
      final coordinates = [start, end];
      final coordinatesString = coordinates
          .map((coord) => '${coord.longitude},${coord.latitude}')
          .join(';');
      
      final url = '$_baseUrl/driving/$coordinatesString?'
          'overview=full&geometries=geojson&steps=false';

      print('🌐 Making request to: $url');
      final response = await _httpClient.get(Uri.parse(url));
      
      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseOSRMResponse(data);
      } else {
        throw Exception('OSRM API error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Request failed: $e');
      throw e;
    }
  }

  RouteResult _parseOSRMResponse(Map<String, dynamic> data) {
    final route = data['routes'][0];
    final geometry = route['geometry'];
    final coordinates = (geometry['coordinates'] as List)
        .map<LatLng>((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
        .toList();

    return RouteResult(
      coordinates: coordinates,
      distance: route['distance'].toDouble(),
      duration: route['duration'].toInt(),
    );
  }
}

void main() async {
  print('🧪 Standalone Route Service Test');
  print('═' * 50);
  
  try {
    final routeService = OSRMRouteService();
    
    // Test with a well-known route: London to Edinburgh
    final start = LatLng(51.5074, -0.1278);  // London
    final end = LatLng(55.9533, -3.1883);    // Edinburgh
    
    print('📍 Testing route:');
    print('   Start: London ($start)');
    print('   End: Edinburgh ($end)');
    print('');
    
    print('🔄 Calculating route...');
    final result = await routeService.calculateRoute(
      start: start,
      end: end,
    );
    
    print('');
    print('✅ SUCCESS!');
    print('═' * 30);
    print('📊 Route Statistics:');
    print('   • Points: ${result.coordinates.length}');
    print('   • Distance: ${(result.distance / 1000).toStringAsFixed(0)} km');
    print('   • Duration: ${(result.duration / 3600).toStringAsFixed(1)} hours');
    print('');
    print('🗺️ First 3 route points:');
    for (int i = 0; i < result.coordinates.take(3).length; i++) {
      final point = result.coordinates[i];
      print('   ${i + 1}. ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}');
    }
    print('');
    print('🗺️ Last 3 route points:');
    final lastPoints = result.coordinates.skip(result.coordinates.length - 3).toList();
    for (int i = 0; i < lastPoints.length; i++) {
      final point = lastPoints[i];
      final index = result.coordinates.length - 3 + i + 1;
      print('   $index. ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}');
    }
    
    print('');
    if (result.coordinates.length > 2) {
      print('🎉 Real roads routing is working!');
      print('   The route has ${result.coordinates.length} points following actual roads.');
      print('   This proves the OSRM service is accessible and working correctly.');
    } else {
      print('⚠️ Unexpected: Route only has ${result.coordinates.length} points');
    }
    
  } catch (e) {
    print('');
    print('❌ ERROR: $e');
    print('');
    print('🔍 Possible causes:');
    print('   • No internet connection');
    print('   • OSRM server (router.project-osrm.org) is down');
    print('   • Network firewall blocking HTTPS requests');
    print('   • DNS resolution issues');
    print('');
    print('🧪 Try testing manually:');
    print('   Open: https://router.project-osrm.org/route/v1/driving/-0.1278,51.5074;-3.1883,55.9533?overview=full&geometries=geojson');
    print('   This should return a JSON response with route data.');
  }
  
  exit(0);
}