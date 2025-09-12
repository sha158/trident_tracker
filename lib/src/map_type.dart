/// Enumeration of available map implementations.
/// 
/// The [MapType] enum defines the different map providers
/// that can be used with the TridentTracker widget.
enum MapType {
  /// Use flutter_map with OpenStreetMap tiles.
  /// 
  /// This implementation provides a lightweight map solution
  /// with good performance and customization options.
  flutterMap,
  
  /// Use flutter_osm_plugin for interactive map features.
  /// 
  /// This implementation offers advanced OSM features and
  /// more interactive capabilities.
  osmPlugin,
  
  /// Use Google Maps with official Google Maps SDK.
  /// 
  /// This implementation provides Google Maps with full features
  /// including satellite imagery, street view, and Places API integration.
  /// Requires a valid Google Maps API key.
  googleMaps,
}