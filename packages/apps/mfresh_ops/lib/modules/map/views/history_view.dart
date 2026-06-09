import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mfresh_ops/modules/map/controllers/history_controller.dart';
import 'package:intl/intl.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route History'),
        actions: [
          Obx(() => TextButton.icon(
            onPressed: () => controller.selectDate(context),
            icon: const Icon(Icons.calendar_today, color: Colors.white, size: 18),
            label: Text(
              DateFormat('MMM dd').format(controller.selectedDate.value),
              style: const TextStyle(color: Colors.white),
            ),
          )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.routePoints.isEmpty) {
          return const Center(
            child: Text('No history found for this date.'),
          );
        }

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: controller.routePoints.first,
            zoom: 14,
          ),
          polylines: {
            Polyline(
              polylineId: const PolylineId('route'),
              points: controller.routePoints.toList(),
              color: Colors.blue,
              width: 5,
            ),
          },
          markers: Set<Marker>.from(controller.stopMarkers),
          onMapCreated: (GoogleMapController googleMapController) {
            // Adjust bounds to show entire route
            _fitBounds(googleMapController);
          },
        );
      }),
    );
  }

  void _fitBounds(GoogleMapController googleMapController) {
    if (controller.routePoints.isEmpty) return;

    double minLat = controller.routePoints.first.latitude;
    double maxLat = controller.routePoints.first.latitude;
    double minLng = controller.routePoints.first.longitude;
    double maxLng = controller.routePoints.first.longitude;

    for (final p in controller.routePoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    googleMapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50.0, // padding
      ),
    );
  }
}
