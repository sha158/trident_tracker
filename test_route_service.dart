import 'dart:io';
import 'lib/src/services/route_service.dart';
import 'package:latlong2/latlong.dart';

void main() async {
  print('🧪 Testing Route Service...');
  
  try {
    final routeService = RouteServiceFactory.create();
    
    print('📍 Testing route from Berlin to Munich...');
    final result = await routeService.calculateRoute(
      start: LatLng(52.5200, 13.4050), // Berlin
      end: LatLng(48.1351, 11.5820),   // Munich
      profile: RouteProfile.driving,
    );
    
    print('✅ SUCCESS!');
    print('📊 Route Statistics:');
    print('   • Points: ${result.coordinates.length}');
    print('   • Distance: ${(result.distance / 1000).toStringAsFixed(0)} km');
    print('   • Duration: ${(result.duration / 3600).toStringAsFixed(1)} hours');
    print('   • Profile: ${result.profile}');
    print('');
    print('🗺️ First 5 route points:');
    for (int i = 0; i < result.coordinates.take(5).length; i++) {
      final point = result.coordinates[i];
      print('   ${i + 1}. ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}');
    }
    
    if (result.coordinates.length > 2) {
      print('');
      print('🎉 Real roads routing is working correctly!');
      print('   The route has ${result.coordinates.length} points instead of just 2 (start/end)');
    } else {
      print('');
      print('⚠️ Route only has ${result.coordinates.length} points - this might be straight line routing');
    }
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('');
    print('🔍 Possible causes:');
    print('   • No internet connection');
    print('   • OSRM server is down');
    print('   • Network firewall blocking requests');
    print('   • Invalid coordinates');
    print('');
    print('🛠️ Fallback behavior:');
    print('   The animation will use enhanced straight-line interpolation');
  }
  
  exit(0);
}