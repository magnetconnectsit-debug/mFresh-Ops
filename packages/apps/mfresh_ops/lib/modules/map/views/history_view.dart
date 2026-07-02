import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mfresh_ops/modules/map/controllers/history_controller.dart';
import 'package:intl/intl.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/custom_app_loader.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(() {
        final bool isInitialLoad =
            controller.isLoading.value && controller.routePoints.isEmpty;

        return Stack(
          children: [
            if (isInitialLoad)
              const Positioned.fill(child: Center(child: CustomAppLoader()))
            else if (controller.routePoints.isEmpty)
              Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        size: 64,
                        color: AppColors.grey300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No route history found.',
                        style: AppTextStyle.style_16_600(
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select a different date to view past routes.',
                        style: AppTextStyle.style_14_400(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Positioned.fill(
                child: GoogleMap(
                  padding: EdgeInsets.only(
                    bottom: (controller.routeSegments.isNotEmpty || controller.routeSummary.isNotEmpty)
                        ? MediaQuery.of(context).size.height * 0.35
                        : 0,
                  ),
                  initialCameraPosition: CameraPosition(
                    target: controller.staffCurrentLocationMarker.value != null
                        ? controller.staffCurrentLocationMarker.value!.position
                        : (controller.routePoints.isNotEmpty 
                            ? controller.routePoints.first 
                            : const LatLng(20.5937, 78.9629)),
                    zoom: controller.staffCurrentLocationMarker.value != null ? 14.5 : (controller.routePoints.isNotEmpty ? 14 : 4),
                  ),
                  myLocationEnabled: controller.adminEmployeeId == null,
                  myLocationButtonEnabled: controller.adminEmployeeId == null,
                  mapType: controller.currentMapType.value,
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: controller.drawnRoutePoints.toList(),
                      color: AppColors.blue500,
                      width: 5,
                      jointType: JointType.round,
                      startCap: Cap.roundCap,
                      endCap: Cap.roundCap,
                      geodesic: true,
                    ),
                  },
                  markers: {
                    if (controller.routePoints.isNotEmpty) ...[
                      ...controller.stopMarkers,
                      if (controller.startMarker.value != null)
                        controller.startMarker.value!,
                      if (controller.endMarker.value != null && controller.staffCurrentLocationMarker.value == null)
                        controller.endMarker.value!,
                    ],
                    if (controller.movingMarker.value != null)
                      controller.movingMarker.value!,
                    if (controller.staffCurrentLocationMarker.value != null)
                      controller.staffCurrentLocationMarker.value!,
                  },
                  onMapCreated: (GoogleMapController googleMapController) {
                    controller.mapController = googleMapController;
                    if (controller.staffCurrentLocationMarker.value != null) {
                      googleMapController.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          controller.staffCurrentLocationMarker.value!.position,
                          14.5,
                        ),
                      );
                    } else {
                      _fitBounds(googleMapController);
                    }
                  },
                ),
              ),
            // Floating Header & Replay Controls Overlay
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Pill
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Get.back(),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              controller.adminEmployeeName != null 
                                  ? "${controller.adminEmployeeName}'s Route" 
                                  : 'Route History',
                              style: AppTextStyle.style_16_700(
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => controller.toggleMapType(),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.layers_rounded,
                              color: AppColors.blue500,
                              size: 20,
                            ),
                          ),
                        ),
                        controller.isLoading.value &&
                                controller.routePoints.isNotEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CustomAppLoader(size: 20),
                              )
                            : InkWell(
                                onTap: () => controller.fetchHistory(isRefresh: true),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.refresh_rounded,
                                    color: AppColors.blue500,
                                    size: 20,
                                  ),
                                ),
                              ),
                        GestureDetector(
                          onTap: () => controller.selectDate(context),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_rounded,
                                color: AppColors.blue500,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat(
                                  'MMM dd',
                                ).format(controller.selectedDate.value),
                                style: AppTextStyle.style_14_600(
                                  color: AppColors.blue500,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Replay Controls Pill
                  if (controller.routePoints.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Obx(
                            () => GestureDetector(
                              onTap: () {
                                if (controller.isReplaying.value &&
                                    !controller.isPaused.value) {
                                  controller.pauseReplay();
                                } else {
                                  controller.startReplay();
                                }
                              },
                              child: Icon(
                                controller.isReplaying.value &&
                                        !controller.isPaused.value
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_fill_rounded,
                                color: AppColors.blue500,
                                size: 36,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SliderTheme(
                              data: const SliderThemeData(
                                trackHeight: 4,
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                overlayShape: RoundSliderOverlayShape(
                                  overlayRadius: 14,
                                ),
                              ),
                              child: Obx(
                                () => Slider(
                                  value: controller.replayProgress.value,
                                  onChangeStart: (_) =>
                                      controller.onScrubStart(),
                                  onChanged: (val) {
                                    controller.onScrubbing(val);
                                  },
                                  onChangeEnd: (val) =>
                                      controller.onScrubEnd(val),
                                  activeColor: AppColors.blue500,
                                  inactiveColor: Colors.grey[300],
                                ),
                              ),
                            ),
                          ),
                          Obx(() {
                            if (controller.currentReplayTime.value.isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  controller.currentReplayTime.value,
                                  style: AppTextStyle.style_12_600(
                                    color: AppColors.black,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                          const SizedBox(width: 8),
                          Obx(() => GestureDetector(
                                onTap: controller.togglePlaybackSpeed,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.blue500
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${controller.playbackSpeed.value}x',
                                    style: AppTextStyle.style_12_600(
                                        color: AppColors.blue500),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (controller.routeSegments.isNotEmpty ||
                controller.routeSummary.isNotEmpty ||
                controller.liveStatus.isNotEmpty)
              DraggableScrollableSheet(
                controller: controller.sheetController,
                initialChildSize: 0.3,
                minChildSize: 0.1,
                maxChildSize: 0.6,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              // Drag handle
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  width: 40,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Timeline',
                                    style: AppTextStyle.style_16_700(
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                        // Summary panel
                        SliverToBoxAdapter(
                          child: Obx(() {
                            final isToday = controller.selectedDate.value.year == DateTime.now().year &&
                                controller.selectedDate.value.month == DateTime.now().month &&
                                controller.selectedDate.value.day == DateTime.now().day;

                            if (!isToday || controller.liveStatus.isEmpty) return const SizedBox.shrink();

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.blue500.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.blue500.withValues(alpha: 0.2)),
                                ),
                                child: Builder(
                                  builder: (context) {
                                    final live = controller.liveStatus;
                                    final summaryItems = <Widget>[];

                                    if (live['current_status'] != null) {
                                      summaryItems.add(_buildSummaryItem(Icons.info_outline, 'Status', live['current_status'].toString().toUpperCase()));
                                    }
                                    if (live['battery'] != null) {
                                      summaryItems.add(_buildSummaryItem(Icons.battery_std, 'Battery', '${live['battery']}%'));
                                    }
                                    if (live['speed'] != null) {
                                      summaryItems.add(_buildSummaryItem(Icons.speed, 'Speed', '${double.tryParse(live['speed'].toString())?.toStringAsFixed(2) ?? 0} km/h'));
                                    }
                                    if (live['last_seen'] != null) {
                                      String formatLastSeen(String dt) {
                                        try {
                                          return DateFormat('hh:mm a').format(DateTime.parse(dt).toLocal());
                                        } catch (_) {
                                          return dt.split(' ').last;
                                        }
                                      }
                                      summaryItems.add(_buildSummaryItem(Icons.access_time_rounded, 'Last Seen', formatLastSeen(live['last_seen'].toString())));
                                    }

                                    return Wrap(
                                      alignment: WrapAlignment.center,
                                      runSpacing: 16,
                                      children: summaryItems.map((w) => FractionallySizedBox(
                                        widthFactor: summaryItems.length > 4 ? 0.33 : 0.25,
                                        child: w,
                                      )).toList(),
                                    );
                                  },
                                ),
                              ),
                            );
                          }),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final reversedIndex = controller.routeSegments.length - 1 - index;
                              final segment = controller.routeSegments[reversedIndex];

                              String formatT(dynamic t) {
                                if (t == null) return '';
                                try {
                                  return DateFormat('hh:mm a').format(
                                    DateTime.parse(t.toString()).toLocal(),
                                  );
                                } catch (_) {
                                  return t.toString();
                                }
                              }

                              final startTime = formatT(segment['start_time']);
                              final endTime = formatT(segment['end_time']);
                              final timeText = endTime.isEmpty ? startTime : '$startTime - $endTime';
                              
                              final distanceRaw = double.tryParse(segment['distance_km']?.toString() ?? '0') ?? 0.0;
                              final distance = distanceRaw.toStringAsFixed(2);
                              
                              final duration = segment['duration_minutes']?.toString() ?? '0';
                              final status = segment['status']?.toString() ?? 'Unknown';
                              
                              final fromLat = double.tryParse(segment['from_latitude']?.toString() ?? segment['latitude']?.toString() ?? '0') ?? 0.0;
                              final fromLng = double.tryParse(segment['from_longitude']?.toString() ?? segment['longitude']?.toString() ?? '0') ?? 0.0;
                              final fromAddressKey = '$fromLat,$fromLng';

                              final toLat = double.tryParse(segment['to_latitude']?.toString() ?? segment['latitude']?.toString() ?? '0') ?? 0.0;
                              final toLng = double.tryParse(segment['to_longitude']?.toString() ?? segment['longitude']?.toString() ?? '0') ?? 0.0;
                              final toAddressKey = '$toLat,$toLng';
                              
                              if (!controller.addressCache.containsKey(fromAddressKey)) {
                                controller.getAddressFor(fromLat, fromLng);
                              }
                              if (!controller.addressCache.containsKey(toAddressKey) && toLat != 0.0 && toLng != 0.0) {
                                controller.getAddressFor(toLat, toLng);
                              }

                              final isMoving = status.toLowerCase() == 'moving';
                              final statusColor = isMoving ? Colors.green : Colors.orange;

                              Widget buildInfoChip(IconData icon, String text, Color color) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: color.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(icon, size: 12, color: color),
                                      const SizedBox(width: 4),
                                      Text(
                                        text,
                                        style: AppTextStyle.style_10_600(color: color),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return InkWell(
                                onTap: () => controller.onSegmentTapped(reversedIndex),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              margin: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: statusColor,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            if (index <
                                                controller.routeSegments.length - 1)
                                              Expanded(
                                                child: Container(
                                                  width: 2,
                                                  color: Colors.grey[300],
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Trip ${reversedIndex + 1}',
                                                    style:
                                                        AppTextStyle.style_14_600(
                                                          color:
                                                              AppColors.black,
                                                        ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  if (timeText.isNotEmpty)
                                                    Text(
                                                      timeText,
                                                      style:
                                                          AppTextStyle.style_12_600(
                                                            color: AppColors
                                                                .blue500,
                                                          ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Wrap(
                                                spacing: 6,
                                                runSpacing: 6,
                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: statusColor.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(isMoving ? Icons.directions_car_rounded : Icons.pause_circle_filled_rounded, size: 12, color: statusColor),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          status.toUpperCase(),
                                                          style: AppTextStyle.style_10_600(color: statusColor),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (isMoving)
                                                    buildInfoChip(
                                                      Icons.route_rounded,
                                                      '$distance km',
                                                      AppColors.blue500,
                                                    ),
                                                  buildInfoChip(
                                                    Icons.timer_rounded,
                                                    '$duration mins',
                                                    AppColors.blue500,
                                                  ),
                                                  if (segment['avg_speed_kmph'] != null)
                                                    buildInfoChip(
                                                      Icons.speed_rounded,
                                                      'Avg: ${double.tryParse(segment['avg_speed_kmph'].toString())?.toStringAsFixed(1) ?? '0'} km/h',
                                                      Colors.purple,
                                                    ),
                                                  if (segment['max_speed_kmph'] != null)
                                                    buildInfoChip(
                                                      Icons.speed_rounded,
                                                      'Max: ${double.tryParse(segment['max_speed_kmph'].toString())?.toStringAsFixed(1) ?? '0'} km/h',
                                                      Colors.red,
                                                    ),
                                                  if (segment['battery'] != null)
                                                    buildInfoChip(
                                                      Icons.battery_std_rounded,
                                                      '${segment['battery']}%',
                                                      Colors.teal,
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Obx(() {
                                                final fromAddr = controller.addressCache[fromAddressKey] ?? 'Loading address...';
                                                final toAddr = controller.addressCache[toAddressKey] ?? 'Loading address...';
                                                final isMoving = status.toLowerCase() == 'moving';
                                                
                                                if (isMoving) {
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('From: $fromAddr', style: AppTextStyle.style_12_400(color: AppColors.grey600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                      const SizedBox(height: 2),
                                                      Text('To: $toAddr', style: AppTextStyle.style_12_400(color: AppColors.grey600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                    ],
                                                  );
                                                } else {
                                                  return Text('At: $fromAddr', style: AppTextStyle.style_12_400(color: AppColors.grey600), maxLines: 2, overflow: TextOverflow.ellipsis);
                                                }
                                              }),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      controller
                                                          .openInGoogleMaps(
                                                            fromLat,
                                                            fromLng,
                                                          );
                                                    },
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .directions_rounded,
                                                          size: 18,
                                                          color:
                                                              AppColors.blue500,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Directions',
                                                          style:
                                                              AppTextStyle.style_12_600(
                                                                color: AppColors
                                                                    .blue500,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: controller.routeSegments.length,
                          ),
                        ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      }),
    );
  }

  void _fitBounds(GoogleMapController googleMapController) {
    if (controller.routePoints.isEmpty && controller.staffCurrentLocationMarker.value == null) return;

    double? minLat, maxLat, minLng, maxLng;

    void updateBounds(LatLng p) {
      if (minLat == null || p.latitude < minLat!) minLat = p.latitude;
      if (maxLat == null || p.latitude > maxLat!) maxLat = p.latitude;
      if (minLng == null || p.longitude < minLng!) minLng = p.longitude;
      if (maxLng == null || p.longitude > maxLng!) maxLng = p.longitude;
    }

    for (final p in controller.routePoints) {
      updateBounds(p);
    }
    
    if (controller.staffCurrentLocationMarker.value != null) {
      updateBounds(controller.staffCurrentLocationMarker.value!.position);
    }

    if (minLat == null || maxLat == null || minLng == null || maxLng == null) return;

    // If it's a single point, just zoom into it
    if (minLat == maxLat && minLng == maxLng) {
      googleMapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(minLat!, minLng!), 14));
      return;
    }

    googleMapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat!, minLng!),
          northeast: LatLng(maxLat!, maxLng!),
        ),
        50.0, // padding
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Tooltip(
            message: label,
            triggerMode: TooltipTriggerMode.tap,
            preferBelow: false,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.blue500.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.blue500, size: 16),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyle.style_10_600(color: AppColors.black),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
