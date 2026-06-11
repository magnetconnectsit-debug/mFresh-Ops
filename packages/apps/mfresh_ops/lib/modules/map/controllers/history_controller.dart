import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mfresh_ops/data/repositories/tracking/tracking_repository.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mfresh_ops/core/utils/map_marker_utils.dart';

class HistoryController extends GetxController {
  final TrackingRepository _repository = Get.find<TrackingRepository>();
  
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxList<Marker> stopMarkers = <Marker>[].obs;
  final Rx<Marker?> startMarker = Rx<Marker?>(null);
  final Rx<Marker?> endMarker = Rx<Marker?>(null);
  final RxBool isLoading = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  
  BitmapDescriptor? _startIcon;
  BitmapDescriptor? _endIcon;
  BitmapDescriptor? _stopIcon;

  @override
  void onInit() {
    super.onInit();
    _initIcons().then((_) => fetchHistory());
  }

  Future<void> _initIcons() async {
    _startIcon = await MapMarkerUtils.createIconMarker(color: Colors.green, iconData: Icons.play_arrow, size: 60);
    _endIcon = await MapMarkerUtils.createIconMarker(color: Colors.red, iconData: Icons.flag, size: 60);
    _stopIcon = await MapMarkerUtils.createIconMarker(color: Colors.orange, iconData: Icons.pause, size: 50);
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    routePoints.clear();
    stopMarkers.clear();
    startMarker.value = null;
    endMarker.value = null;

    final dateStr = _apiDateFormat.format(selectedDate.value);

    try {
      final routeData = await _repository.getRouteHistory(date: dateStr);
      if (routeData != null && routeData['status'] == true) {
        final List points = routeData['route_points'] ?? [];
        routePoints.value = points.map((p) => LatLng(
          double.parse(p['latitude'].toString()),
          double.parse(p['longitude'].toString()),
        )).toList();

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

      final stopData = await _repository.getStoppages(date: dateStr);
      if (stopData != null && stopData['status'] == true) {
        final List stops = stopData['stoppages'] ?? [];
        for (var i = 0; i < stops.length; i++) {
          final s = stops[i];
          stopMarkers.add(Marker(
            markerId: MarkerId('stop_$i'),
            position: LatLng(
              double.parse(s['latitude'].toString()),
              double.parse(s['longitude'].toString()),
            ),
            infoWindow: InfoWindow(
              title: 'Stop ${i + 1}',
              snippet: 'Duration: ${s['duration_minutes'] ?? s['duration']} mins',
            ),
            icon: _stopIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            anchor: const Offset(0.5, 0.5),
          ));
        }
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
      Get.snackbar('Error', 'Failed to fetch history');
    } finally {
      isLoading.value = false;
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
    }
  }
}
