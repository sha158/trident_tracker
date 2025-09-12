# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2025-01-12

### Added
- Initial release of TridentTracker package
- Support for flutter_map with OpenStreetMap tiles
- Support for flutter_osm_plugin for interactive mapping
- Automatic current location detection and display
- Built-in location permission handling using permission_handler and geolocator
- Configurable initial map center and zoom level
- Error handling and retry functionality for location services
- Comprehensive example application demonstrating both map types
- Full API documentation with dartdoc comments
- Unit and widget tests for core functionality

### Features
- **Dual Map Support**: Choose between flutter_map or flutter_osm_plugin
- **Location Services**: Automatic permission handling and current location display
- **Customizable**: Set initial position, zoom level, and location tracking behavior
- **Error Handling**: Graceful handling of permission denials and location service issues
- **Production Ready**: Comprehensive documentation, examples, and tests