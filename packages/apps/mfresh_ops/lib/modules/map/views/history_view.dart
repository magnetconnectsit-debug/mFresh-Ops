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
                    bottom: controller.rawStoppages.isNotEmpty
                        ? MediaQuery.of(context).size.height * 0.3
                        : 0,
                  ),
                  initialCameraPosition: CameraPosition(
                    target: controller.routePoints.first,
                    zoom: 14,
                  ),
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
                    ...controller.stopMarkers,
                    if (controller.startMarker.value != null)
                      controller.startMarker.value!,
                    if (controller.endMarker.value != null)
                      controller.endMarker.value!,
                    if (controller.movingMarker.value != null)
                      controller.movingMarker.value!,
                  },
                  onMapCreated: (GoogleMapController googleMapController) {
                    controller.mapController = googleMapController;
                    _fitBounds(googleMapController);
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
                              'Route History',
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
                                onTap: () => controller.fetchHistory(),
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
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => controller.stopReplay(),
                            child: const Icon(
                              Icons.stop_circle_rounded,
                              color: Colors.redAccent,
                              size: 36,
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
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (controller.rawStoppages.isNotEmpty)
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
                              final reversedIndex = controller.rawStoppages.length - 1 - index;
                              final stop = controller.rawStoppages[reversedIndex];
                              final duration =
                                  stop['duration_minutes'] ??
                                  stop['duration'] ??
                                  'Unknown';

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

                              final startStr = formatT(stop['stop_start_time']);
                              final endStr = formatT(stop['stop_end_time']);
                              String timeText = '';
                              if (startStr.isNotEmpty && endStr.isNotEmpty) {
                                timeText = '$startStr - $endStr';
                              } else if (startStr.isNotEmpty) {
                                timeText = 'Since $startStr';
                              }

                              final reason = stop['reason']?.toString();
                              final status = stop['status']?.toString();
                              final battery = stop['battery']?.toString();
                              final speed = stop['speed']?.toString();
                              final accuracy = stop['accuracy']?.toString();

                              return InkWell(
                                onTap: () => controller.onStopTapped(reversedIndex),
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
                                                color: Colors.orange,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            if (index <
                                                controller.rawStoppages.length -
                                                    1)
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
                                                    'Stop ${reversedIndex + 1}',
                                                    style:
                                                        AppTextStyle.style_14_600(
                                                          color:
                                                              AppColors.black,
                                                        ),
                                                  ),
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
                                                spacing: 8,
                                                runSpacing: 4,
                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                children: [
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.schedule_rounded,
                                                        size: 14,
                                                        color: AppColors.grey500,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '$duration mins',
                                                        style: AppTextStyle.style_12_400(color: AppColors.grey500),
                                                      ),
                                                    ],
                                                  ),
                                                  if (battery != null && battery.isNotEmpty)
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.battery_std_rounded,
                                                          size: 14,
                                                          color: AppColors.grey500,
                                                        ),
                                                        const SizedBox(width: 2),
                                                        Text(
                                                          '$battery%',
                                                          style: AppTextStyle.style_12_400(color: AppColors.grey500),
                                                        ),
                                                      ],
                                                    ),
                                                  if (speed != null && speed.isNotEmpty)
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.speed_rounded,
                                                          size: 14,
                                                          color: AppColors.grey500,
                                                        ),
                                                        const SizedBox(width: 2),
                                                        Text(
                                                          '$speed km/h',
                                                          style: AppTextStyle.style_12_400(color: AppColors.grey500),
                                                        ),
                                                      ],
                                                    ),
                                                  if (accuracy != null && accuracy.isNotEmpty)
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.gps_fixed_rounded,
                                                          size: 14,
                                                          color: AppColors.grey500,
                                                        ),
                                                        const SizedBox(width: 2),
                                                        Text(
                                                          '±$accuracy m',
                                                          style: AppTextStyle.style_12_400(color: AppColors.grey500),
                                                        ),
                                                      ],
                                                    ),
                                                  if (status != null && status.isNotEmpty)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: status.toLowerCase() == 'approved' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        status.toUpperCase(),
                                                        style: AppTextStyle.style_10_600(color: status.toLowerCase() == 'approved' ? Colors.green : Colors.orange),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                stop['placeName'] ??
                                                    'Lat: ${stop['latitude']}, Lng: ${stop['longitude']}',
                                                style:
                                                    AppTextStyle.style_12_400(
                                                      color: AppColors.grey600,
                                                    ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (reason != null &&
                                                  reason.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Reason: $reason',
                                                  style:
                                                      AppTextStyle.style_12_400(
                                                        color:
                                                            AppColors.grey500,
                                                      ).copyWith(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                ),
                                              ],
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      controller
                                                          .openInGoogleMaps(
                                                            double.parse(
                                                              stop['latitude']
                                                                  .toString(),
                                                            ),
                                                            double.parse(
                                                              stop['longitude']
                                                                  .toString(),
                                                            ),
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
                                                  const SizedBox(width: 24),
                                                  InkWell(
                                                    onTap: () {
                                                      controller.shareLocation(
                                                        double.parse(
                                                          stop['latitude']
                                                              .toString(),
                                                        ),
                                                        double.parse(
                                                          stop['longitude']
                                                              .toString(),
                                                        ),
                                                        stop['placeName'] ??
                                                            'Lat: ${stop['latitude']}, Lng: ${stop['longitude']}',
                                                      );
                                                    },
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons.share_rounded,
                                                          size: 18,
                                                          color:
                                                              AppColors.blue500,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Share',
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
                            }, childCount: controller.rawStoppages.length),
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
