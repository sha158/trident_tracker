# TridentTracker Example

This example demonstrates how to use the TridentTracker package with both supported map implementations.

## Features Demonstrated

- **Flutter Map Integration**: Using OpenStreetMap tiles with flutter_map
- **OSM Plugin Integration**: Using the flutter_osm_plugin implementation
- **Current Location**: Automatic location detection and display
- **Custom Locations**: Setting initial map center and zoom
- **Permission Handling**: Graceful handling of location permission requests

## Running the Example

1. Ensure you have Flutter installed and set up
2. Navigate to the example directory:
   ```bash
   cd example
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the example:
   ```bash
   flutter run
   ```

## Configuration

The example app will request location permissions when needed. Make sure to:

1. **For Android**: Add the required permissions to `android/app/src/main/AndroidManifest.xml`
2. **For iOS**: Add the usage descriptions to `ios/Runner/Info.plist`

See the main package README for detailed configuration instructions.