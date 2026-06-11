import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mfresh_ops/data/services/tracking/tracking_service.dart';
import 'package:mfresh_ops/routes/app_routes.dart';

import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';

class MapView extends GetView<TrackingService> {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppCommonAppBar(
        title: Text(
          'Live Tracking',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        hasBackButton: true,
        iconColor: AppColors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.black),
            onPressed: () => Get.toNamed(AppRoutes.routeHistory),
            tooltip: 'View History',
          ),
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
