# TridentTracker

A Flutter package for displaying maps with current location using either flutter_map or flutter_osm_plugin based on user arguments.

## Features

- 🗺️ Support for three map providers: flutter_map (OpenStreetMap), flutter_osm_plugin, and Google Maps
- 📍 Automatic current location detection and display
- 🎯 Customizable initial position and zoom level
- 🔐 Built-in location permission handling
- 🔑 Conditional API key validation (only required for Google Maps)
- ⚡ Easy-to-use widget with minimal configuration

## Getting started

### Dependencies

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  trident_tracker: ^0.0.1
```

### Android Configuration

Add these permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

For Android 6.0+, also add:

```xml
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

### iOS Configuration

Add these keys to your `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to show your current position on the map.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to show your current position on the map.</string>
```

## Usage

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:trident_tracker/trident_tracker.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('TridentTracker Demo')),
        body: TridentTracker(
          mapType: MapType.flutterMap, // or MapType.osmPlugin
        ),
      ),
    );
  }
}
```

### Advanced Usage

```dart
TridentTracker(
  mapType: MapType.flutterMap,
  initialZoom: 15.0,
  initialCenter: LatLng(37.7749, -122.4194), // San Francisco
  showCurrentLocation: true,
  onLocationPermissionDenied: () {
    // Handle permission denied
    print('Location permission denied');
  },
)
```

### MapType Options

- `MapType.flutterMap`: Uses flutter_map with OpenStreetMap tiles
- `MapType.osmPlugin`: Uses flutter_osm_plugin with interactive features
- `MapType.googleMaps`: Uses Google Maps with official Google Maps SDK (requires API key)

### Google Maps Usage

```dart
TridentTracker(
  mapType: MapType.googleMaps,
  googleMapsApiKey: "YOUR_API_KEY_HERE", // Required for Google Maps
  showCurrentLocation: true,
)
```

**Important:** API key is only required when using `MapType.googleMaps`. Other map types work without any API key.

## Google Maps Configuration

### 1. Get API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
4. Create an API key
5. Restrict the API key to your app's package name/bundle ID

### 2. Android Setup
Add to `android/app/src/main/AndroidManifest.xml` inside the `<application>` tag:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

### 3. iOS Setup
Add to `ios/Runner/AppDelegate.swift`:
```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 4. Environment-Based API Key (Recommended)
```dart
TridentTracker(
  mapType: MapType.googleMaps,
  googleMapsApiKey: const String.fromEnvironment('GOOGLE_MAPS_API_KEY'),
)
```

Then run your app with:
```bash
flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_api_key_here
```

## Required Permissions

This package requires location permissions to function properly. The package will automatically request permissions when needed, but you must configure them in your platform-specific files as shown above.

## Additional information

This package uses:
- [flutter_map](https://pub.dev/packages/flutter_map) for the flutter_map implementation
- [flutter_osm_plugin](https://pub.dev/packages/flutter_osm_plugin) for the OSM plugin implementation
- [geolocator](https://pub.dev/packages/geolocator) for location services
- [permission_handler](https://pub.dev/packages/permission_handler) for permission management

For issues and feature requests, please visit the [GitHub repository](https://github.com/your-repo/trident_tracker).
