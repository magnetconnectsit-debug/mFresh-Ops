import 'package:core/constants/app_colors.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mfresh_ops/data/repositories/tracking_repository.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mfresh_ops/core/utils/map_marker_utils.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:core/constants/app_images.dart';
import 'package:services/services.dart';

class HistoryController extends GetxController {
  final TrackingRepository _repository = Get.find<TrackingRepository>();
  
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxList<String> routeTimes = <String>[].obs;
  final RxList<LatLng> drawnRoutePoints = <LatLng>[].obs;
  final RxList<Marker> stopMarkers = <Marker>[].obs;
  final RxList<Map<String, dynamic>> rawStoppages = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> rawLocations = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> routeSummary = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> liveStatus = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> routeSegments = <Map<String, dynamic>>[].obs;
  final Rx<Marker?> startMarker = Rx<Marker?>(null);
  final Rx<Marker?> endMarker = Rx<Marker?>(null);
  final Rx<Marker?> staffCurrentLocationMarker = Rx<Marker?>(null);
  final RxBool isLoading = true.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<MapType> currentMapType = MapType.normal.obs;
  
  final RxMap<String, String> addressCache = <String, String>{}.obs;
  
  // Replay State
  final RxBool isReplaying = false.obs;
  final RxBool isPaused = false.obs;
  final RxDouble replayProgress = 0.0.obs;
  final RxString currentReplayTime = ''.obs;
  final Rx<Marker?> movingMarker = Rx<Marker?>(null);
  
  Timer? _replayTimer;
  int _replayIndex = 0;
  BitmapDescriptor? _vehicleIcon;
  
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  
  BitmapDescriptor? _startIcon;
  BitmapDescriptor? _endIcon;
  BitmapDescriptor? _stopIcon;
  
  int? adminEmployeeId;
  String? adminEmployeeName;

  Timer? _historyPollingTimer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map) {
      adminEmployeeId = args['employee_id'];
      adminEmployeeName = args['employee_name'];
      
      final currentLat = args['current_lat'];
      final currentLng = args['current_lng'];
      if (currentLat != null && currentLng != null && currentLat.toString().isNotEmpty && currentLng.toString().isNotEmpty) {
        try {
          staffCurrentLocationMarker.value = Marker(
            markerId: const MarkerId('staff_current_location'),
            position: LatLng(double.parse(currentLat.toString()), double.parse(currentLng.toString())),
            infoWindow: InfoWindow(
              title: 'Current Location',
              snippet: args['last_seen'] != null ? 'Last seen: ${args['last_seen']}' : null,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            zIndex: 10,
          );
        } catch (e) {
          debugPrint('Failed to parse staff current location: $e');
        }
      }
    }
    _initIcons();
    fetchHistory();
    _startHistoryPolling();
  }

  void _startHistoryPolling() {
    _historyPollingTimer?.cancel();
    _historyPollingTimer = null;

    final now = DateTime.now();
    final isToday = selectedDate.value.year == now.year &&
        selectedDate.value.month == now.month &&
        selectedDate.value.day == now.day;

    if (isToday) {
      _historyPollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!isLoading.value && !isReplaying.value) {
          fetchHistory(isRefresh: true, isSilent: true);
        }
      });
    }
  }

  Future<void> _initIcons() async {
    try {
      _startIcon = await MapMarkerUtils.createAssetMarker(AppImages.mapStartIcon, width: 100);
      _endIcon = await MapMarkerUtils.createAssetMarker(AppImages.mapEndIcon, width: 100);
      _stopIcon = await MapMarkerUtils.createAssetMarker(AppImages.mapStopIcon, width: 80);
    } catch (e) {
      debugPrint('Failed to load asset markers: $e');
      _startIcon = await MapMarkerUtils.createIconMarker(color: Colors.green, iconData: Icons.storefront_rounded, size: 70);
      _endIcon = await MapMarkerUtils.createIconMarker(color: Colors.red, iconData: Icons.location_on_rounded, size: 70);
      _stopIcon = await MapMarkerUtils.createDotMarker(color: Colors.orange, size: 30);
    }
    _vehicleIcon = await MapMarkerUtils.createNavigationArrowMarker(color: Colors.blueAccent, size: 80);

    if (staffCurrentLocationMarker.value != null) {
      final name = adminEmployeeName ?? 'User';
      String initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';
      if (name.contains(' ')) {
        final parts = name.split(' ');
        if (parts.length > 1 && parts[1].isNotEmpty) {
          initials += parts[1][0].toUpperCase();
        }
      }
      final customIcon = await MapMarkerUtils.createCustomMarker(
        color: Colors.blue,
        text: initials,
      );
      staffCurrentLocationMarker.value = staffCurrentLocationMarker.value!.copyWith(
        iconParam: customIcon,
      );
    }
  }

  Future<void> fetchHistory({bool isRefresh = false, bool isSilent = false}) async {
    if (!isSilent) {
      isLoading.value = true;
    }
    if (!isSilent && !isRefresh) {
      stopReplay();
    }
    
    if (!isRefresh && !isSilent) {
      routePoints.clear();
      drawnRoutePoints.clear();
      stopMarkers.clear();
      rawStoppages.clear();
      rawLocations.clear();
      routeSummary.clear();
      liveStatus.clear();
      routeSegments.clear();
      startMarker.value = null;
      endMarker.value = null;
    }

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      
      final routeData = adminEmployeeId != null 
          ? await _repository.getEmployeeRouteHistory(employeeId: adminEmployeeId!, date: dateStr)
          : await _repository.getRouteHistory(date: dateStr);
      if (routeData != null && routeData['status'] == true) {
        final List points = routeData['route_points'] ?? [];
        if (points.isNotEmpty) {
          debugPrint('First route point: ${points.first}');
        }
        routePoints.value = points.map((p) => LatLng(
          double.parse(p['latitude'].toString()),
          double.parse(p['longitude'].toString()),
        )).toList();
        
        rawLocations.value = points.map((p) => Map<String, dynamic>.from(p)).toList();
        
        routeTimes.value = points.asMap().entries.map((entry) {
          int idx = entry.key;
          dynamic p = entry.value;
          
          String? timeStr = p['location_time']?.toString() ?? 
                            p['created_at']?.toString() ?? 
                            p['timestamp']?.toString() ?? 
                            p['time']?.toString();
                            
          if (timeStr != null) {
            try {
              return DateFormat('hh:mm a').format(DateTime.parse(timeStr).toLocal());
            } catch (e) {
              return timeStr;
            }
          }
          return 'Pt. ${idx + 1}';
        }).toList();
        
        drawnRoutePoints.value = routePoints.toList();

        if (routePoints.isNotEmpty && _startIcon != null) {
          startMarker.value = Marker(
            markerId: const MarkerId('start'),
            position: routePoints.first,
            icon: _startIcon!,
            infoWindow: const InfoWindow(title: 'Start Location'),
            anchor: const Offset(0.5, 0.5),
          );
        }
        if (routePoints.length > 1 && _endIcon != null) {
          endMarker.value = Marker(
            markerId: const MarkerId('end'),
            position: routePoints.last,
            icon: _endIcon!,
            infoWindow: const InfoWindow(title: 'End/Current Location'),
            anchor: const Offset(0.5, 0.5),
          );
        }
      }

      final stopData = adminEmployeeId != null
          ? await _repository.getEmployeeStoppages(employeeId: adminEmployeeId!, date: dateStr)
          : await _repository.getStoppages(date: dateStr);
      if (stopData != null && stopData['status'] == true) {
        final List stops = stopData['stoppages'] ?? [];
        
        // Reverse geocode all stops
        final List<Map<String, dynamic>> processedStops = [];
        final List<Marker> newStopMarkers = [];
        for (var i = 0; i < stops.length; i++) {
          final Map<String, dynamic> s = Map<String, dynamic>.from(stops[i]);
          double lat = double.parse(s['latitude'].toString());
          double lng = double.parse(s['longitude'].toString());

          String placeName = 'Lat: $lat, Lng: $lng';
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
            if (placemarks.isNotEmpty) {
              final place = placemarks.first;
              // Filter out plus codes (typically contain a '+')
              final parts = [place.street, place.subLocality, place.locality, place.administrativeArea]
                  .where((e) => e != null && e.isNotEmpty && !e.contains('+'))
                  .toList();
              if (parts.isNotEmpty) {
                placeName = parts.join(', ');
              }
            }
          } catch (e) {
            debugPrint('Geocoding error: $e');
          }

          s['placeName'] = placeName;
          processedStops.add(s);

          newStopMarkers.add(Marker(
            markerId: MarkerId('stop_$i'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: 'Stop ${i + 1}',
              snippet: 'Duration: ${s['duration_minutes'] ?? s['duration']} mins',
            ),
            icon: _stopIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            anchor: const Offset(0.5, 0.5),
          ));
        }
        stopMarkers.assignAll(newStopMarkers);
        rawStoppages.value = processedStops;
      }

      final now = DateTime.now();
      final isToday = selectedDate.value.year == now.year &&
          selectedDate.value.month == now.month &&
          selectedDate.value.day == now.day;
      if (isToday) {
        try {
          final targetEmployeeId = adminEmployeeId ?? Get.find<StorageService>().getUser()?.id;
          final statusRes = await _repository.getCurrentStatus();
          if (statusRes != null && statusRes['status'] == true) {
            final List emps = statusRes['employees'] ?? [];
            final emp = emps.firstWhereOrNull((e) => (e['id'] ?? e['user_id']) == targetEmployeeId);
            if (emp != null) {
              liveStatus.value = Map<String, dynamic>.from(emp);
              
              final lat = emp['latitude'];
              final lng = emp['longitude'];
              if (lat != null && lng != null && lat.toString().isNotEmpty && lng.toString().isNotEmpty) {
                final status = emp['current_status']?.toString().toLowerCase();
                final isOffDuty = status == null || status.isEmpty || status == 'off-duty' || status == 'offline';

                BitmapDescriptor customIcon;
                if (isOffDuty && _endIcon != null) {
                  customIcon = _endIcon!;
                } else {
                  Color markerColor = Colors.blue;
                  if (status == 'moving') {
                    markerColor = Colors.green;
                  } else if (status == 'stopped') {
                    markerColor = Colors.orange;
                  }

                  final name = adminEmployeeName ?? emp['name'] ?? 'User';
                  String initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';
                  if (name.contains(' ')) {
                    final parts = name.split(' ');
                    if (parts.length > 1 && parts[1].isNotEmpty) {
                      initials += parts[1][0].toUpperCase();
                    }
                  }

                  final bool isOnDuty = emp['is_on_duty'] == 1 || emp['is_on_duty'] == true;
                  final Color borderColor = isOnDuty ? AppColors.green : AppColors.red;

                  final imageUrl = emp['image_url']?.toString();
                  if (imageUrl != null && !imageUrl.endsWith('/NA') && imageUrl.isNotEmpty) {
                    customIcon = await MapMarkerUtils.createNetworkImageMarker(
                      imageUrl: imageUrl,
                      color: markerColor,
                      fallbackText: initials,
                      borderColor: borderColor,
                    );
                  } else {
                    customIcon = await MapMarkerUtils.createCustomMarker(
                      color: markerColor,
                      text: initials,
                      borderColor: borderColor,
                    );
                  }
                }

                final LatLng newPos = LatLng(double.parse(lat.toString()), double.parse(lng.toString()));
                staffCurrentLocationMarker.value = Marker(
                  markerId: const MarkerId('staff_current_location'),
                  position: newPos,
                  infoWindow: InfoWindow(
                    title: adminEmployeeName != null ? '$adminEmployeeName\'s Location' : 'Current Location',
                    snippet: emp['last_seen'] != null ? 'Last seen: ${emp['last_seen']}' : null,
                  ),
                  icon: customIcon,
                  zIndex: 10,
                );

                mapController?.animateCamera(
                  CameraUpdate.newLatLng(newPos),
                );
              }
            }
          }
        } catch (e) {
          debugPrint('Error fetching current status for employee: $e');
        }
      }



      final segmentData = adminEmployeeId != null
          ? await _repository.getEmployeeSegments(employeeId: adminEmployeeId!, date: dateStr)
          : await _repository.getSegments(date: dateStr);
      if (segmentData != null && segmentData['status'] == true) {
        routeSegments.value = List<Map<String, dynamic>>.from(segmentData['segments'] ?? segmentData['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
      if (!isSilent) {
        Get.snackbar('Error', 'Failed to fetch history');
      }
    } finally {
      if (!isSilent) {
        isLoading.value = false;
      }
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      fetchHistory();
      _startHistoryPolling();
    }
  }

  void startReplay() {
    if (routePoints.isEmpty) return;
    if (isReplaying.value && !isPaused.value) return;

    if (!isPaused.value) {
      _replayIndex = 0;
      replayProgress.value = 0.0;
    }
    
    isReplaying.value = true;
    isPaused.value = false;

    _replayTimer?.cancel();
    _replayTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_replayIndex >= routePoints.length - 1) {
        stopReplay();
        return;
      }

      final LatLng current = routePoints[_replayIndex];
      final LatLng next = routePoints[_replayIndex + 1];
      final double bearing = _calculateBearing(current, next);

      _replayIndex++;
      replayProgress.value = _replayIndex / (routePoints.length - 1);
      
      if (_replayIndex < routeTimes.length) {
        currentReplayTime.value = routeTimes[_replayIndex];
      }
      
      drawnRoutePoints.value = routePoints.sublist(0, _replayIndex + 1);

      movingMarker.value = Marker(
        markerId: const MarkerId('moving_vehicle'),
        position: current,
        icon: _vehicleIcon ?? BitmapDescriptor.defaultMarker,
        rotation: bearing,
        anchor: const Offset(0.5, 0.5),
        zIndex: 100,
      );
    });
  }

  void pauseReplay() {
    isPaused.value = true;
    _replayTimer?.cancel();
  }

  GoogleMapController? mapController;
  final DraggableScrollableController sheetController = DraggableScrollableController();

  void onStopTapped(int index) {
    if (index >= 0 && index < rawStoppages.length) {
      final stop = rawStoppages[index];
      final lat = double.parse(stop['latitude'].toString());
      final lng = double.parse(stop['longitude'].toString());
      
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 13));
      Future.delayed(const Duration(milliseconds: 300), () {
        mapController?.showMarkerInfoWindow(MarkerId('stop_$index'));
      });

      // Animate the bottom sheet down to reveal the map
      if (sheetController.isAttached) {
        sheetController.animateTo(
          0.3, // return to initialChildSize
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void onLocationTapped(int index) {
    if (index >= 0 && index < rawLocations.length) {
      final loc = rawLocations[index];
      final lat = double.parse(loc['latitude'].toString());
      final lng = double.parse(loc['longitude'].toString());
      
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16));

      if (sheetController.isAttached) {
        sheetController.animateTo(
          0.3,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void onSegmentTapped(int index) {
    if (index >= 0 && index < routeSegments.length) {
      final segment = routeSegments[index];
      // Try to get 'to' location first, fallback to 'from', fallback to general latitude
      final latStr = segment['to_latitude']?.toString() ?? segment['from_latitude']?.toString() ?? segment['latitude']?.toString() ?? '0';
      final lngStr = segment['to_longitude']?.toString() ?? segment['from_longitude']?.toString() ?? segment['longitude']?.toString() ?? '0';
      
      final lat = double.tryParse(latStr) ?? 0.0;
      final lng = double.tryParse(lngStr) ?? 0.0;
      
      if (lat != 0.0 && lng != 0.0) {
        mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16));

        if (sheetController.isAttached) {
          sheetController.animateTo(
            0.3,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }

  Future<void> getAddressFor(double lat, double lng) async {
    final key = '$lat,$lng';
    if (addressCache.containsKey(key)) return;
    
    // Set a temporary loading state
    addressCache[key] = 'Loading address...';

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = [place.street, place.subLocality, place.locality, place.administrativeArea]
            .where((e) => e != null && e.isNotEmpty && !e.contains('+'))
            .toList();
        if (parts.isNotEmpty) {
          addressCache[key] = parts.join(', ');
          return;
        }
      }
    } catch (e) {
      // Ignore geocoding errors (e.g., rate limits or no connection)
    }
    
    // Fallback if geocoding fails
    addressCache[key] = 'Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)}';
  }

  Future<void> openInGoogleMaps(double lat, double lng) async {
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    final Uri uri = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Error', 'Could not open Google Maps');
    }
  }

  Future<void> shareLocation(double lat, double lng, String name) async {
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    await Share.share('Check out this stop location: $name\n$googleMapsUrl');
  }

  void toggleMapType() {
    currentMapType.value = currentMapType.value == MapType.normal ? MapType.satellite : MapType.normal;
  }

  void stopReplay() {
    isReplaying.value = false;
    isPaused.value = false;
    _replayTimer?.cancel();
    movingMarker.value = null;
    _replayIndex = 0;
    replayProgress.value = 0.0;
    currentReplayTime.value = '';
    drawnRoutePoints.value = routePoints.toList();
  }

  bool _wasPlayingBeforeScrub = false;

  void onScrubStart() {
    _wasPlayingBeforeScrub = isReplaying.value && !isPaused.value;
    pauseReplay();
  }

  void onScrubbing(double progress) {
    replayProgress.value = progress;
    if (routePoints.isNotEmpty) {
      int scrubIndex = (progress * (routePoints.length - 1)).round();
      if (scrubIndex >= 0 && scrubIndex < routeTimes.length) {
        currentReplayTime.value = routeTimes[scrubIndex];
      }
    }
  }

  void onScrubEnd(double progress) {
    seekReplay(progress);
    if (_wasPlayingBeforeScrub) {
      startReplay();
    }
  }

  void seekReplay(double progress) {
    if (routePoints.isEmpty) return;
    _replayIndex = (progress * (routePoints.length - 1)).round();
    replayProgress.value = progress;
    drawnRoutePoints.value = routePoints.sublist(0, _replayIndex + 1);
    
    if (_replayIndex < routeTimes.length) {
      currentReplayTime.value = routeTimes[_replayIndex];
    }
    
    if (_replayIndex < routePoints.length) {
      double bearing = 0;
      if (_replayIndex < routePoints.length - 1) {
        bearing = _calculateBearing(routePoints[_replayIndex], routePoints[_replayIndex + 1]);
      }
      movingMarker.value = Marker(
        markerId: const MarkerId('moving_vehicle'),
        position: routePoints[_replayIndex],
        icon: _vehicleIcon ?? BitmapDescriptor.defaultMarker,
        rotation: bearing,
        anchor: const Offset(0.5, 0.5),
        zIndex: 100,
      );
    }
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final double startLat = start.latitude * (math.pi / 180.0);
    final double startLng = start.longitude * (math.pi / 180.0);
    final double endLat = end.latitude * (math.pi / 180.0);
    final double endLng = end.longitude * (math.pi / 180.0);

    final double dLng = endLng - startLng;

    final double y = math.sin(dLng) * math.cos(endLat);
    final double x = math.cos(startLat) * math.sin(endLat) -
        math.sin(startLat) * math.cos(endLat) * math.cos(dLng);

    final double bearing = math.atan2(y, x);
    return (bearing * (180.0 / math.pi) + 360.0) % 360.0;
  }

  @override
  void onClose() {
    _replayTimer?.cancel();
    _historyPollingTimer?.cancel();
    super.onClose();
  }
}
