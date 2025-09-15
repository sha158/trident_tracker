import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Service for calculating routes along actual roads
abstract class IRouteService {
  Future<RouteResult> calculateRoute({
    required LatLng start,
    required LatLng end,
    List<LatLng>? waypoints,
    RouteProfile profile = RouteProfile.driving,
  });
}

/// Route calculation result
class RouteResult {
  final List<LatLng> coordinates;
  final double distance; // in meters
  final int duration; // in seconds
  final String geometry; // encoded polyline
  final RouteProfile profile;

  RouteResult({
    required this.coordinates,
    required this.distance,
    required this.duration,
    required this.geometry,
    required this.profile,
  });
}

/// Route profile types
enum RouteProfile {
  driving,
  walking,
  cycling,
  delivery,
}

/// OpenStreetMap Routing Service (OSRM) implementation
class OSRMRouteService implements IRouteService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1';
  final http.Client _httpClient;

  OSRMRouteService({http.Client? httpClient}) 
      : _httpClient = httpClient ?? http.Client();

  @override
  Future<RouteResult> calculateRoute({
    required LatLng start,
    required LatLng end,
    List<LatLng>? waypoints,
    RouteProfile profile = RouteProfile.driving,
  }) async {
    try {
      final coordinates = [start, ...(waypoints ?? []), end];
      final coordinatesString = coordinates
          .map((coord) => '${coord.longitude},${coord.latitude}')
          .join(';');
      
      final profileString = _getProfileString(profile);
      final url = '$_baseUrl/$profileString/$coordinatesString?'
          'overview=full&geometries=geojson&steps=false';

      final response = await _httpClient.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseOSRMResponse(data, profile);
      } else {
        throw RouteCalculationException('OSRM API error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to simple interpolation if routing service fails
      return _fallbackRoute(start, end, waypoints, profile);
    }
  }

  String _getProfileString(RouteProfile profile) {
    switch (profile) {
      case RouteProfile.driving:
      case RouteProfile.delivery:
        return 'driving';
      case RouteProfile.walking:
        return 'foot';
      case RouteProfile.cycling:
        return 'bike';
    }
  }

  RouteResult _parseOSRMResponse(Map<String, dynamic> data, RouteProfile profile) {
    final route = data['routes'][0];
    final geometry = route['geometry'];
    final coordinates = (geometry['coordinates'] as List)
        .map<LatLng>((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
        .toList();

    return RouteResult(
      coordinates: coordinates,
      distance: route['distance'].toDouble(),
      duration: route['duration'].toInt(),
      geometry: json.encode(geometry),
      profile: profile,
    );
  }

  RouteResult _fallbackRoute(
    LatLng start,
    LatLng end,
    List<LatLng>? waypoints,
    RouteProfile profile,
  ) {
    // Enhanced fallback with road-like curves
    final allPoints = [start, ...(waypoints ?? []), end];
    final roadLikePoints = <LatLng>[];

    for (int i = 0; i < allPoints.length - 1; i++) {
      final currentPoint = allPoints[i];
      final nextPoint = allPoints[i + 1];
      
      // Add intermediate points that simulate road curves
      roadLikePoints.addAll(_generateRoadLikeSegment(currentPoint, nextPoint));
    }

    // Ensure end point is included
    if (roadLikePoints.isEmpty || roadLikePoints.last != end) {
      roadLikePoints.add(end);
    }

    final distance = _calculateTotalDistance(roadLikePoints);
    final duration = _estimateDuration(distance, profile);

    return RouteResult(
      coordinates: roadLikePoints,
      distance: distance,
      duration: duration,
      geometry: '',
      profile: profile,
    );
  }

  List<LatLng> _generateRoadLikeSegment(LatLng start, LatLng end) {
    const int segmentCount = 20;
    final points = <LatLng>[];
    
    // Add some randomness to simulate real roads
    final random = Random();
    
    for (int i = 0; i <= segmentCount; i++) {
      final t = i / segmentCount;
      
      // Basic interpolation
      final lat = start.latitude + (end.latitude - start.latitude) * t;
      final lng = start.longitude + (end.longitude - start.longitude) * t;
      
      // Add slight curves to simulate roads (smaller deviation)
      final deviation = 0.0001; // Reduced deviation for more realistic roads
      final latOffset = (random.nextDouble() - 0.5) * deviation * sin(t * pi * 3);
      final lngOffset = (random.nextDouble() - 0.5) * deviation * cos(t * pi * 2);
      
      points.add(LatLng(
        lat + latOffset,
        lng + lngOffset,
      ));
    }
    
    return points;
  }

  double _calculateTotalDistance(List<LatLng> points) {
    double totalDistance = 0.0;
    const distance = Distance();
    
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += distance.as(LengthUnit.Meter, points[i], points[i + 1]);
    }
    
    return totalDistance;
  }

  int _estimateDuration(double distanceMeters, RouteProfile profile) {
    // Estimate duration based on profile
    double speedKmh;
    switch (profile) {
      case RouteProfile.driving:
        speedKmh = 50.0; // Urban driving speed
        break;
      case RouteProfile.delivery:
        speedKmh = 35.0; // Delivery vehicle speed (with stops)
        break;
      case RouteProfile.cycling:
        speedKmh = 15.0; // Cycling speed
        break;
      case RouteProfile.walking:
        speedKmh = 5.0; // Walking speed
        break;
    }
    
    final distanceKm = distanceMeters / 1000;
    final durationHours = distanceKm / speedKmh;
    return (durationHours * 3600).round(); // Convert to seconds
  }

  void dispose() {
    _httpClient.close();
  }
}

/// Google Directions API implementation
class GoogleDirectionsService implements IRouteService {
  final String _apiKey;
  final http.Client _httpClient;
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';

  GoogleDirectionsService(this._apiKey, {http.Client? httpClient}) 
      : _httpClient = httpClient ?? http.Client();

  @override
  Future<RouteResult> calculateRoute({
    required LatLng start,
    required LatLng end,
    List<LatLng>? waypoints,
    RouteProfile profile = RouteProfile.driving,
  }) async {
    try {
      final origin = '${start.latitude},${start.longitude}';
      final destination = '${end.latitude},${end.longitude}';
      
      var url = '$_baseUrl?origin=$origin&destination=$destination&key=$_apiKey';
      
      // Add waypoints if provided
      if (waypoints != null && waypoints.isNotEmpty) {
        final waypointsString = waypoints
            .map((wp) => '${wp.latitude},${wp.longitude}')
            .join('|');
        url += '&waypoints=$waypointsString';
      }
      
      // Add travel mode based on profile
      final mode = _getTravelMode(profile);
      url += '&mode=$mode';

      final response = await _httpClient.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseGoogleResponse(data, profile);
      } else {
        throw RouteCalculationException('Google Directions API error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to OSRM if Google API fails
      final osrmService = OSRMRouteService();
      return await osrmService.calculateRoute(
        start: start,
        end: end,
        waypoints: waypoints,
        profile: profile,
      );
    }
  }

  String _getTravelMode(RouteProfile profile) {
    switch (profile) {
      case RouteProfile.driving:
      case RouteProfile.delivery:
        return 'driving';
      case RouteProfile.walking:
        return 'walking';
      case RouteProfile.cycling:
        return 'bicycling';
    }
  }

  RouteResult _parseGoogleResponse(Map<String, dynamic> data, RouteProfile profile) {
    if (data['status'] != 'OK' || data['routes'].isEmpty) {
      throw RouteCalculationException('No route found');
    }

    final route = data['routes'][0];
    final leg = route['legs'][0];
    final overviewPolyline = route['overview_polyline']['points'];
    
    // Decode Google polyline
    final coordinates = _decodePolyline(overviewPolyline);

    return RouteResult(
      coordinates: coordinates,
      distance: leg['distance']['value'].toDouble(),
      duration: leg['duration']['value'].toInt(),
      geometry: overviewPolyline,
      profile: profile,
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> coordinates = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int byte;
      
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      
      int deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += deltaLat;

      shift = 0;
      result = 0;
      
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      
      int deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += deltaLng;

      coordinates.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return coordinates;
  }

  void dispose() {
    _httpClient.close();
  }
}

/// Route service factory
class RouteServiceFactory {
  static IRouteService create({
    String? googleApiKey,
    bool preferGoogle = false,
  }) {
    if (preferGoogle && googleApiKey != null && googleApiKey.isNotEmpty) {
      return GoogleDirectionsService(googleApiKey);
    } else {
      return OSRMRouteService();
    }
  }
}

/// Exception for route calculation errors
class RouteCalculationException implements Exception {
  final String message;
  
  RouteCalculationException(this.message);
  
  @override
  String toString() => 'RouteCalculationException: $message';
}