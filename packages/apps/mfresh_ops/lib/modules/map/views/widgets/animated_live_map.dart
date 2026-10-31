import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:mfresh_ops/data/services/tracking_service.dart';
import 'package:mfresh_ops/core/utils/map_marker_utils.dart';

class AnimatedLiveMap extends StatefulWidget {
  const AnimatedLiveMap({super.key});

  @override
  State<AnimatedLiveMap> createState() => _AnimatedLiveMapState();
}

class _AnimatedLiveMapState extends State<AnimatedLiveMap>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  LatLng? _prevPosition;
  LatLng? _currentMarkerPosition;
  double _markerRotation = 0.0;
  bool _followUser = true;
  BitmapDescriptor? _carIcon;
  StreamSubscription<Position?>? _posSubscription;
  AnimationController? _animController;
  Tween<double>? _tween;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcon();
    
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Smooth 1.5s interpolation
    );

    // Initial position setup
    final initialPos = TrackingService.to.currentPosition.value;
    if (initialPos != null) {
      _currentMarkerPosition = LatLng(initialPos.latitude, initialPos.longitude);
      _prevPosition = _currentMarkerPosition;
    }

    // Listen to real-time position stream
    _posSubscription = TrackingService.to.currentPosition.listen((Position? pos) {
      if (pos == null) return;
      final newLatLng = LatLng(pos.latitude, pos.longitude);

      if (_prevPosition == null) {
        setState(() {
          _currentMarkerPosition = newLatLng;
          _prevPosition = newLatLng;
        });
        if (_mapController != null) {
          _mapController!.animateCamera(CameraUpdate.newLatLng(newLatLng));
        }
        return;
      }

      // Calculate bearing from previous position to the new position
      final bearing = _calculateBearing(_prevPosition!, newLatLng);

      final startPos = _currentMarkerPosition ?? _prevPosition!;
      final targetPos = newLatLng;

      // Angular interpolation logic (shortest path to avoid spinning)
      final startRot = _markerRotation;
      final targetRot = bearing;
      double rotDiff = targetRot - startRot;
      while (rotDiff < -180) rotDiff += 360;
      while (rotDiff > 180) rotDiff -= 360;

      _animController!.stop();
      _tween = Tween<double>(begin: 0.0, end: 1.0);
      final animation = _tween!.animate(CurvedAnimation(
        parent: _animController!,
        curve: Curves.easeInOutCubic,
      ));

      animation.addListener(() {
        final double t = animation.value;
        final double lat = startPos.latitude + (targetPos.latitude - startPos.latitude) * t;
        final double lng = startPos.longitude + (targetPos.longitude - startPos.longitude) * t;
        final double rot = startRot + rotDiff * t;

        if (mounted) {
          setState(() {
            _currentMarkerPosition = LatLng(lat, lng);
            _markerRotation = rot;
          });
        }

        if (_followUser && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(LatLng(lat, lng)),
          );
        }
      });

      _animController!.forward(from: 0.0);
      _prevPosition = newLatLng;
    });
  }

  Future<void> _loadMarkerIcon() async {
    final icon = await MapMarkerUtils.createNavigationArrowMarker(
      color: const Color(0xFF4F46E5), // Premium Indigo theme color
      size: 110,
    );
    if (mounted) {
      setState(() {
        _carIcon = icon;
      });
    }
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final double startLat = start.latitude * math.pi / 180;
    final double startLng = start.longitude * math.pi / 180;
    final double endLat = end.latitude * math.pi / 180;
    final double endLng = end.longitude * math.pi / 180;

    final double dLng = endLng - startLng;

    final double y = math.sin(dLng) * math.cos(endLat);
    final double x = math.cos(startLat) * math.sin(endLat) -
        math.sin(startLat) * math.cos(endLat) * math.cos(dLng);

    final double bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  MapType _currentMapType = MapType.normal;

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  @override
  void dispose() {
    _posSubscription?.cancel();
    _animController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentMarkerPosition == null) {
      return const Center(child: CustomAppLoader());
    }

    return Stack(
      children: [
        Listener(
          onPointerDown: (_) {
            if (_followUser) {
              setState(() {
                _followUser = false;
              });
            }
          },
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentMarkerPosition!,
              zoom: 14.5,
            ),
            mapType: _currentMapType,
            myLocationEnabled: false, // We use our custom animated marker
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId('current_location'),
                position: _currentMarkerPosition!,
                rotation: _markerRotation,
                anchor: const Offset(0.5, 0.5), // Center to pivot rotation
                icon: _carIcon ?? BitmapDescriptor.defaultMarker,
                infoWindow: const InfoWindow(title: 'You are here'),
              ),
            },
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),
        ),
        // Map Type Toggle Button
        Positioned(
          bottom: _followUser ? 100.h : 160.h,
          right: 20.w,
          child: FloatingActionButton(
            heroTag: 'btn_map_type',
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF4F46E5),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            onPressed: _toggleMapType,
            child: const Icon(Icons.layers_rounded),
          ),
        ),
        // Recenter Floating Button
        if (!_followUser)
          Positioned(
            bottom: 100.h,
            right: 20.w,
            child: FloatingActionButton(
              heroTag: 'btn_recenter',
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4F46E5),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              onPressed: () {
                setState(() {
                  _followUser = true;
                });
                if (_currentMarkerPosition != null && _mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: _currentMarkerPosition!,
                        zoom: 14.5,
                      ),
                    ),
                  );
                }
              },
              child: const Icon(Icons.gps_fixed),
            ),
          ),
      ],
    );
  }
}
