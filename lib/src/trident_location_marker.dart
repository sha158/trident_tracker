import 'package:flutter/material.dart';

/// Defines how the current location marker should be displayed on the map.
/// 
/// The [TridentLocationMarker] provides multiple ways to customize the
/// appearance of the current location marker across different map implementations.
class TridentLocationMarker {
  final TridentLocationMarkerType _type;
  final String? _assetPath;
  final Widget? _widget;
  final Size _size;
  final String? _title;
  final String? _description;
  final Color? _color;

  const TridentLocationMarker._(
    this._type, {
    String? assetPath,
    Widget? widget,
    Size size = const Size(40, 40),
    String? title,
    String? description,
    Color? color,
  })  : _assetPath = assetPath,
        _widget = widget,
        _size = size,
        _title = title,
        _description = description,
        _color = color;

  /// Creates a location marker using a custom image from assets.
  /// 
  /// Example:
  /// ```dart
  /// TridentLocationMarker.fromAsset(
  ///   'assets/my_marker.png',
  ///   size: Size(50, 50),
  ///   title: 'You are here',
  /// )
  /// ```
  factory TridentLocationMarker.fromAsset(
    String assetPath, {
    Size size = const Size(40, 40),
    String? title,
    String? description,
  }) {
    return TridentLocationMarker._(
      TridentLocationMarkerType.asset,
      assetPath: assetPath,
      size: size,
      title: title,
      description: description,
    );
  }

  /// Creates a location marker using a custom Flutter widget.
  /// 
  /// Example:
  /// ```dart
  /// TridentLocationMarker.fromWidget(
  ///   Container(
  ///     width: 30,
  ///     height: 30,
  ///     decoration: BoxDecoration(
  ///       color: Colors.blue,
  ///       shape: BoxShape.circle,
  ///       border: Border.all(color: Colors.white, width: 3),
  ///     ),
  ///     child: Icon(Icons.person, color: Colors.white, size: 20),
  ///   ),
  ///   title: 'Current Location',
  /// )
  /// ```
  factory TridentLocationMarker.fromWidget(
    Widget widget, {
    String? title,
    String? description,
  }) {
    return TridentLocationMarker._(
      TridentLocationMarkerType.widget,
      widget: widget,
      title: title,
      description: description,
    );
  }

  /// Creates a default blue location marker.
  /// 
  /// This provides a consistent blue marker across all map types.
  factory TridentLocationMarker.defaultBlue({
    Size size = const Size(40, 40),
    String? title,
    String? description,
  }) {
    return TridentLocationMarker._(
      TridentLocationMarkerType.defaultIcon,
      size: size,
      color: Colors.blue,
      title: title,
      description: description,
    );
  }

  /// Creates a default red location marker.
  /// 
  /// This provides a consistent red marker across all map types.
  factory TridentLocationMarker.defaultRed({
    Size size = const Size(40, 40),
    String? title,
    String? description,
  }) {
    return TridentLocationMarker._(
      TridentLocationMarkerType.defaultIcon,
      size: size,
      color: Colors.red,
      title: title,
      description: description,
    );
  }

  /// Creates a default green location marker.
  /// 
  /// This provides a consistent green marker across all map types.
  factory TridentLocationMarker.defaultGreen({
    Size size = const Size(40, 40),
    String? title,
    String? description,
  }) {
    return TridentLocationMarker._(
      TridentLocationMarkerType.defaultIcon,
      size: size,
      color: Colors.green,
      title: title,
      description: description,
    );
  }

  /// Creates a pulsing animated location marker.
  /// 
  /// This creates an animated marker that pulses to draw attention.
  factory TridentLocationMarker.pulsing({
    Color color = Colors.blue,
    Size size = const Size(40, 40),
    String? title,
    String? description,
  }) {
    return TridentLocationMarker._(
      TridentLocationMarkerType.pulsing,
      size: size,
      color: color,
      title: title,
      description: description,
    );
  }

  // Getters for accessing private properties
  TridentLocationMarkerType get type => _type;
  String? get assetPath => _assetPath;
  Widget? get widget => _widget;
  Size get size => _size;
  String? get title => _title;
  String? get description => _description;
  Color? get color => _color;
}

/// Enumeration of different location marker types.
enum TridentLocationMarkerType {
  /// Custom image from assets
  asset,
  
  /// Custom Flutter widget
  widget,
  
  /// Default icon with customizable color
  defaultIcon,
  
  /// Animated pulsing marker
  pulsing,
}