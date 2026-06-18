import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/modules/staff_tracking/controllers/staff_tracking_controller.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class StaffTrackingScreen extends GetView<StaffTrackingController> {
  const StaffTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppCommonAppBar(
          title: const Text('Staff Tracking'),
          hasBackButton: true,
        ),
        body: Column(
          children: [
            // Modern Segmented Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                padding: const EdgeInsets.all(4),
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.blue500,
                unselectedLabelColor: AppColors.grey500,
                labelStyle: AppTextStyle.style_14_600(),
                unselectedLabelStyle: AppTextStyle.style_14_500(),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('List View'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('Map View'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Tab 1: List
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: AppCommonSearchBar(
                          controller: controller.searchController,
                          hintText: 'Search staff by name or mobile',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value && controller.allEmployees.isEmpty) {
                            return const Center(child: CustomAppLoader());
                          }

                          if (controller.filteredEmployees.isEmpty) {
                            return _buildEmptyState();
                          }

                          return RefreshIndicator(
                            onRefresh: controller.fetchEmployees,
                            color: AppColors.blue500,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              itemCount: controller.filteredEmployees.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final emp = controller.filteredEmployees[index];
                                return _buildEmployeeCard(emp);
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  
                  // Tab 2: Map
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Obx(() {
                      return GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(20.5937, 78.9629), // Center on India roughly
                          zoom: 4,
                        ),
                        markers: controller.employeeMarkers.toSet(),
                        myLocationButtonEnabled: false,
                        myLocationEnabled: false,
                        mapToolbarEnabled: false,
                        zoomControlsEnabled: false,
                        onMapCreated: (mapController) {
                          controller.mapController = mapController;
                        },
                        onCameraMove: (CameraPosition position) {
                          controller.onCameraMove(position);
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.blue500.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_alt_outlined, size: 64, color: AppColors.blue500.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            'No staff found',
            style: AppTextStyle.style_18_600(color: AppColors.black),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: AppTextStyle.style_14_400(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Map<String, dynamic> emp) {
    final name = emp['name'] ?? 'Unknown';
    final mobile = emp['mobile'] ?? '';
    final status = emp['current_status']?.toString().toLowerCase();
    final lastSeen = emp['last_seen'];

    Color statusColor = Colors.grey;
    Color statusBgColor = Colors.grey.withValues(alpha: 0.1);
    String statusText = 'Offline';

    if (status == 'moving') {
      statusColor = Colors.green;
      statusBgColor = Colors.green.withValues(alpha: 0.1);
      statusText = 'Moving';
    } else if (status == 'stopped') {
      statusColor = Colors.orange;
      statusBgColor = Colors.orange.withValues(alpha: 0.1);
      statusText = 'Stopped';
    }

    String formattedLastSeen = AppDateUtils.formatToDateTimeAmPm(lastSeen?.toString());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.openEmployeeHistory(emp),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.blue500, AppColors.blue500.withValues(alpha: 0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blue500.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          name.toString().isNotEmpty ? name.toString().substring(0, 1).toUpperCase() : 'U',
                          style: AppTextStyle.style_18_700(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTextStyle.style_16_600(color: AppColors.black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          if (mobile.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.phone_iphone_rounded, size: 14, color: AppColors.grey500),
                                const SizedBox(width: 4),
                                Text(
                                  mobile,
                                  style: AppTextStyle.style_14_400(color: AppColors.grey600),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    // Call Button
                    if (mobile.isNotEmpty)
                      InkWell(
                        onTap: () async {
                          final Uri url = Uri(scheme: 'tel', path: mobile);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.call_rounded, size: 18, color: Colors.green),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Bottom row with Status and Last Seen
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[100]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              statusText,
                              style: AppTextStyle.style_12_600(color: statusColor),
                            ),
                          ],
                        ),
                      ),
                      // Last Seen
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: AppColors.grey500),
                          const SizedBox(width: 4),
                          Text(
                            formattedLastSeen,
                            style: AppTextStyle.style_12_500(color: AppColors.grey500),
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
      ),
    );
  }
}
