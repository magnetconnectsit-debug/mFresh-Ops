import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mfresh_ops/data/services/tracking/tracking_service.dart';
import 'package:mfresh_ops/routes/app_routes.dart';

class MapView extends GetView<TrackingService> {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Get.toNamed(AppRoutes.routeHistory),
            tooltip: 'View History',
          ),
          Obx(() => IconButton(
            icon: Icon(controller.isTracking.value ? Icons.stop : Icons.play_arrow),
            onPressed: () => controller.toggleTracking(),
            tooltip: controller.isTracking.value ? 'Stop Tracking' : 'Start Tracking',
          )),
        ],
      ),
      body: Obx(() {
        if (controller.currentPosition.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final pos = controller.currentPosition.value!;
        final latLng = LatLng(pos.latitude, pos.longitude);
        
        return GoogleMap(
          initialCameraPosition: CameraPosition(target: latLng, zoom: 15),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onMapCreated: (GoogleMapController googleMapController) {
            // Additional map setup if needed
          },
          markers: {
            Marker(
              markerId: const MarkerId('current_location'),
              position: latLng,
              infoWindow: const InfoWindow(title: 'You are here'),
            ),
          },
        );
      }),
    );
  }
}
