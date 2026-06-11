import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mfresh_ops/modules/map/controllers/history_controller.dart';
import 'package:intl/intl.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppCommonAppBar(
        title: Text(
          'Route History',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        hasBackButton: true,
        iconColor: AppColors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.blue500),
            onPressed: () => controller.fetchHistory(),
            tooltip: 'Refresh',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Obx(() => TextButton.icon(
              onPressed: () => controller.selectDate(context),
              icon: const Icon(Icons.calendar_today, color: AppColors.blue500, size: 18),
              label: Text(
                DateFormat('MMM dd, yyyy').format(controller.selectedDate.value),
                style: AppTextStyle.style_14_600(color: AppColors.blue500),
              ),
            )),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.blue500),
          );
        }

        if (controller.routePoints.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 64, color: AppColors.grey300),
                const SizedBox(height: 16),
                Text(
                  'No route history found.',
                  style: AppTextStyle.style_16_600(color: AppColors.grey600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a different date to view past routes.',
                  style: AppTextStyle.style_14_400(color: AppColors.grey500),
                ),
              ],
            ),
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
              color: AppColors.black,
              width: 4,
              jointType: JointType.round,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              geodesic: true,
              patterns: [PatternItem.dash(20), PatternItem.gap(10)],
            ),
          },
          markers: {
            ...controller.stopMarkers,
            if (controller.startMarker.value != null) controller.startMarker.value!,
            if (controller.endMarker.value != null) controller.endMarker.value!,
          },
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
