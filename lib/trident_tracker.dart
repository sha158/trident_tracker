/// TridentTracker - A Flutter package for displaying maps with current location.
/// 
/// This package provides a unified interface for displaying maps using either
/// flutter_map or flutter_osm_plugin, with built-in location services.
/// 
/// ## Features
/// 
/// * Support for multiple map implementations
/// * Automatic current location detection
/// * Permission handling
/// * Customizable initial position and zoom
/// 
/// ## Usage
/// 
/// ```dart
/// import 'package:trident_tracker/trident_tracker.dart';
/// 
/// TridentTracker(
///   mapType: MapType.flutterMap,
///   showCurrentLocation: true,
/// )
/// ```
library;

export 'src/trident_tracker_widget.dart';
export 'src/map_type.dart';
export 'src/location_service.dart';