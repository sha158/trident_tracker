# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
TridentTracker is a Flutter package that provides map functionality with current location support. It allows users to choose between two map implementations: flutter_map or flutter_osm_plugin based on user arguments.

## Architecture
- **Package Type**: Flutter package (not an app)
- **Main Library**: `lib/trident_tracker.dart` - Exports the main components
- **Core Components**:
  - `TridentTracker` widget - Main map widget supporting both map types
  - `MapType` enum - Defines available map types (flutterMap, osmPlugin)
  - `LocationService` - Handles location permissions and current location detection
- **Testing**: Comprehensive widget and unit tests in `test/trident_tracker_test.dart`

## Development Commands

### Dependencies
```bash
flutter pub get
```

### Testing
```bash
flutter test                    # Run all tests
flutter test test/trident_tracker_test.dart  # Run specific test file
```

### Code Analysis & Linting
```bash
flutter analyze                 # Static analysis
dart format .                   # Format code
dart format --set-exit-if-changed .  # Check formatting
```

### Package Commands
```bash
dart pub publish --dry-run      # Validate package for publishing
dart pub deps                   # Show dependency tree
```

## Project Structure
- `lib/src/` - Source code directory
  - `trident_tracker_widget.dart` - Main widget implementation
  - `map_type.dart` - MapType enum definition
  - `location_service.dart` - Location handling utilities
- `test/` - Unit and widget tests
- `pubspec.yaml` - Package dependencies and metadata
- `analysis_options.yaml` - Uses flutter_lints for code analysis rules

## Key Dependencies
- `flutter_map: ^7.0.2` - OpenStreetMap implementation
- `flutter_osm_plugin: ^1.0.3` - OSM plugin implementation
- `geolocator: ^13.0.1` - Location services
- `permission_handler: ^11.3.1` - Permission management
- `latlong2: ^0.9.1` - Latitude/longitude utilities

## Development Notes
- Uses Flutter SDK ^3.7.2
- Includes flutter_lints ^5.0.0 for code quality
- Package supports both Android and iOS with proper permission configurations
- Location permissions are handled automatically by LocationService
- Widget supports both map types with consistent API