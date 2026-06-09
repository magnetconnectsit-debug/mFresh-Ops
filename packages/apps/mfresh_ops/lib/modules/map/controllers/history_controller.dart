import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mfresh_ops/data/repositories/tracking/tracking_repository.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class HistoryController extends GetxController {
  final TrackingRepository _repository = Get.find<TrackingRepository>();
  
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxList<Marker> stopMarkers = <Marker>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    routePoints.clear();
    stopMarkers.clear();

    final dateStr = _apiDateFormat.format(selectedDate.value);

    try {
      final routeData = await _repository.getRouteHistory(date: dateStr);
      if (routeData != null && routeData['status'] == true) {
        final List points = routeData['route_points'] ?? [];
        routePoints.value = points.map((p) => LatLng(
          double.parse(p['latitude'].toString()),
          double.parse(p['longitude'].toString()),
        )).toList();
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
              snippet: 'Duration: ${s['duration']}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
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
