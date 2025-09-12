/// TridentTracker - A Flutter package for displaying maps with current location.
/// 
/// This package provides a unified interface for displaying maps using
/// flutter_map, flutter_osm_plugin, or Google Maps, with built-in location services.
/// 
/// ## Features
/// 
/// * Support for three map implementations (flutter_map, OSM plugin, Google Maps)
/// * Automatic current location detection
/// * Permission handling
/// * Customizable initial position and zoom
/// * Conditional API key validation (only for Google Maps)
/// 
/// ## Usage
/// 
/// ```dart
/// import 'package:trident_tracker/trident_tracker.dart';
/// 
/// // Flutter Map (no API key needed)
/// TridentTracker(
///   mapType: MapType.flutterMap,
///   showCurrentLocation: true,
/// )
/// 
/// // Google Maps (API key required)
/// TridentTracker(
///   mapType: MapType.googleMaps,
///   googleMapsApiKey: "your-api-key",
///   showCurrentLocation: true,
/// )
/// ```
library;

export 'src/trident_tracker_widget.dart';
export 'src/map_type.dart';
export 'src/location_service.dart';
export 'src/trident_location_marker.dart';
export 'src/trident_route_animation.dart';