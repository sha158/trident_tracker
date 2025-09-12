import 'package:flutter/material.dart';
import 'trident_location_marker.dart';

/// Helper class for creating marker widgets for different map implementations.
class TridentMarkerWidgets {
  /// Creates a Flutter widget for the location marker.
  /// 
  /// This is used by flutter_map and can be used for other implementations
  /// that support Flutter widgets as markers.
  static Widget buildMarkerWidget(TridentLocationMarker? marker) {
    if (marker == null) {
      return _buildDefaultMarker();
    }

    switch (marker.type) {
      case TridentLocationMarkerType.asset:
        return _buildAssetMarker(marker);
      case TridentLocationMarkerType.widget:
        return marker.widget!;
      case TridentLocationMarkerType.defaultIcon:
        return _buildDefaultIconMarker(marker);
      case TridentLocationMarkerType.pulsing:
        return _buildPulsingMarker(marker);
    }
  }

  /// Creates a default blue marker when no custom marker is provided.
  static Widget _buildDefaultMarker() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.my_location,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  /// Creates a marker from an asset image.
  static Widget _buildAssetMarker(TridentLocationMarker marker) {
    return SizedBox(
      width: marker.size.width,
      height: marker.size.height,
      child: Image.asset(
        marker.assetPath!,
        width: marker.size.width,
        height: marker.size.height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to default marker if asset fails to load
          return _buildDefaultMarker();
        },
      ),
    );
  }

  /// Creates a default styled icon marker with custom color.
  static Widget _buildDefaultIconMarker(TridentLocationMarker marker) {
    final color = marker.color ?? Colors.blue;
    
    return Container(
      width: marker.size.width,
      height: marker.size.height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(marker.size.width / 2),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.my_location,
        color: Colors.white,
        size: marker.size.width * 0.5,
      ),
    );
  }

  /// Creates an animated pulsing marker.
  static Widget _buildPulsingMarker(TridentLocationMarker marker) {
    return _PulsingMarker(
      color: marker.color ?? Colors.blue,
      size: marker.size,
    );
  }
}

/// A widget that creates a pulsing animation effect for location markers.
class _PulsingMarker extends StatefulWidget {
  final Color color;
  final Size size;

  const _PulsingMarker({
    required this.color,
    required this.size,
  });

  @override
  State<_PulsingMarker> createState() => _PulsingMarkerState();
}

class _PulsingMarkerState extends State<_PulsingMarker>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing ring
            Container(
              width: widget.size.width * (1 + _animation.value * 0.5),
              height: widget.size.height * (1 + _animation.value * 0.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(
                  alpha: (1 - _animation.value) * 0.3,
                ),
              ),
            ),
            // Inner marker
            Container(
              width: widget.size.width,
              height: widget.size.height,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.my_location,
                color: Colors.white,
                size: widget.size.width * 0.4,
              ),
            ),
          ],
        );
      },
    );
  }
}