import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/modules/staff_tracking/controllers/staff_tracking_controller.dart';
import 'package:mfresh_ops/modules/staff_tracking/views/widgets/employee_tracking_card.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';

class StaffTrackingScreen extends GetView<StaffTrackingController> {
  const StaffTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      drawer: const CommonSidebar(),
      appBar: PreferredSize(
        preferredSize: const AppCommonAppBar(
          topHeader: CommonShortcutHeader(),
        ).preferredSize,
        child: Obx(() {
          return AppCommonAppBar(
            title: controller.isSearching.value
                ? _buildSearchAutocomplete(context)
                : const Text('Attendance'),
            hasBackButton: false,
            showAppDrawer: true,
            topHeader: const CommonShortcutHeader(),
            actions: [
              Obx(() {
                final count = controller.selectedEmployeeIds.length;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.filter_alt_rounded,
                        color: AppColors.black,
                      ),
                      onPressed: () =>
                          controller.showMultiSelectStaffBottomSheet(),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              }),
              IconButton(
                icon: const Icon(
                  Icons.assignment_rounded,
                  color: AppColors.black,
                ),
                onPressed: () {
                  Get.toNamed('/attendance-log');
                },
              ),
              IconButton(
                icon: Icon(
                  controller.isSearching.value
                      ? Icons.close_rounded
                      : Icons.search_rounded,
                  color: AppColors.black,
                ),
                onPressed: () {
                  controller.isSearching.value = !controller.isSearching.value;
                  if (!controller.isSearching.value) {
                    controller.searchController.clear();
                  }
                },
              ),
            ],
          );
        }),
      ),
      body: Obx(() {
        final canViewMap = controller.canViewMap.value;
        final showStaffTab = controller.showStaffTab.value;

        return Column(
          children: [
            // Stats Row
            _buildStatsRow(controller),
            if (showStaffTab || canViewMap)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  key: ValueKey('${showStaffTab}_$canViewMap'),
                  controller: controller.tabController!,
              padding: const EdgeInsets.all(4),
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppColors.blue500,
              unselectedLabelColor: AppColors.grey500,
              labelStyle: AppTextStyle.style_12_600(),
              unselectedLabelStyle: AppTextStyle.style_12_500(),
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
              tabs: [
                const Tab(
                  height: 32,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('List View'),
                    ],
                  ),
                ),
                if (showStaffTab)
                  const Tab(
                    height: 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_alt_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Staff'),
                      ],
                    ),
                  ),
                if (canViewMap)
                  const Tab(
                    height: 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Map View'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              key: ValueKey('${showStaffTab}_$canViewMap'),
              controller: controller.tabController!,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Tab 1: List
                Column(
                  children: [
                    const SizedBox(height: 6),
                    Expanded(
                      child: Obx(() {
                        if (!controller.hasFetchedOnce.value) {
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
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final emp = controller.filteredEmployees[index];
                              return EmployeeTrackingCard(
                                employee: emp,
                                canViewMap: canViewMap,
                                onTap: () =>
                                    controller.openEmployeeHistory(emp),
                              );
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),

                // Tab 2: Staff (Conditionally Added)
                if (showStaffTab)
                  Column(
                    children: [
                      const SizedBox(height: 6),
                      Expanded(
                        child: Obx(() {
                          if (!controller.hasFetchedOnce.value) {
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
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final emp = controller.filteredEmployees[index];
                                return EmployeeTrackingCard(
                                  employee: emp,
                                  canViewMap: canViewMap,
                                  onTap: () =>
                                      controller.openEmployeeHistory(emp),
                                  hideBottomRow: true,
                                );
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),

                // Tab 3: Map
                if (canViewMap)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: Obx(() {
                      if (!controller.hasFetchedOnce.value) {
                        return const Center(child: CustomAppLoader());
                      }
                      return Stack(
                        children: [
                          GoogleMap(
                            mapType: controller.currentMapType.value,
                            initialCameraPosition: const CameraPosition(
                              target: LatLng(
                                20.5937,
                                78.9629,
                              ), // Center on India roughly
                              zoom: 4,
                            ),
                            markers: controller.employeeMarkers.toSet(),
                            circles: controller.employeeCircles.toSet(),
                            polylines: controller.employeePolylines.toSet(),
                            myLocationButtonEnabled: true,
                            myLocationEnabled: true,
                            mapToolbarEnabled: false,
                            zoomControlsEnabled: false,
                            onMapCreated: (mapController) {
                              controller.mapController = mapController;
                              if (controller.employeeMarkers.isNotEmpty) {
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  controller.fitBounds();
                                });
                              }
                            },
                            onCameraMove: (CameraPosition position) {
                              controller.onCameraMove(position);
                            },
                          ),
                          Positioned(
                            bottom: 180,
                            right: 16,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FloatingActionButton(
                                  mini: true,
                                  heroTag: 'zoom_in_fab',
                                  backgroundColor: AppColors.white,
                                  onPressed: () {
                                    controller.mapController?.animateCamera(
                                      CameraUpdate.zoomIn(),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: AppColors.blue500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                FloatingActionButton(
                                  mini: true,
                                  heroTag: 'zoom_out_fab',
                                  backgroundColor: AppColors.white,
                                  onPressed: () {
                                    controller.mapController?.animateCamera(
                                      CameraUpdate.zoomOut(),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.remove_rounded,
                                    color: AppColors.blue500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 120,
                            right: 16,
                            child: FloatingActionButton(
                              mini: true,
                              heroTag: 'staff_map_type_fab',
                              backgroundColor: AppColors.white,
                              onPressed: controller.toggleMapType,
                              child: Icon(
                                controller.currentMapType.value ==
                                        MapType.normal
                                    ? Icons.satellite_alt_rounded
                                    : Icons.map_rounded,
                                color: AppColors.blue500,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ), // Close Container
              ], // End TabBarView children
            ), // End TabBarView
          ), // End Expanded
        ], // End Column children
      ); // End Column
    }), // End Obx
    ); // End Scaffold
  }

  Widget _buildSearchAutocomplete(BuildContext context) {
    return Autocomplete<Map<String, dynamic>>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (controller.tabController?.index == 0 ||
            textEditingValue.text.isEmpty) {
          return const Iterable<Map<String, dynamic>>.empty();
        }
        final query = textEditingValue.text.toLowerCase();
        return controller.allEmployees.where((emp) {
          final name = (emp['name'] ?? '').toString().toLowerCase();
          final mobile = (emp['mobile'] ?? '').toString().toLowerCase();
          return name.contains(query) || mobile.contains(query);
        });
      },
      displayStringForOption: (option) => option['name'] ?? '',
      onSelected: (Map<String, dynamic> selection) {
        FocusScope.of(context).unfocus();
        controller.locateEmployeeOnMap(selection);
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by name or mobile...',
                hintStyle: AppTextStyle.style_14_400(color: AppColors.grey400),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: AppTextStyle.style_16_500(color: AppColors.black),
              onChanged: (val) {
                controller.searchController.text = val;
              },
            );
          },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 250,
                maxWidth: MediaQuery.of(context).size.width - 80,
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey[100]),
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    title: Text(
                      option['name'] ?? '',
                      style: AppTextStyle.style_14_600(color: AppColors.black),
                    ),
                    subtitle: Text(
                      option['mobile'] ?? '',
                      style: AppTextStyle.style_12_500(
                        color: AppColors.grey500,
                      ),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
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
            child: Icon(
              Icons.people_alt_outlined,
              size: 64,
              color: AppColors.blue500.withValues(alpha: 0.5),
            ),
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

  Widget _buildStatsRow(StaffTrackingController controller) {
    return Obx(() {
      int total = controller.allEmployees.length;
      int onDuty = 0;
      int offDuty = 0;
      int stopped = 0;
      int moving = 0;

      int live = 0;
      int notLive = 0;
      int notInstalled = 0;

      for (var emp in controller.allEmployees) {
        final status = emp['current_status']?.toString().toLowerCase() ?? '';
        final bool isOnDuty =
            emp['is_on_duty'] == 1 ||
            emp['is_on_duty'] == true ||
            emp['is_on_duty'] == '1';
        final lastSeen = emp['last_seen'];

        bool isNotInstalled = lastSeen == null && emp['live_status'] == null;

        if (isNotInstalled) {
          notInstalled++;
        } else if (!isOnDuty) {
          offDuty++;
        } else {
          onDuty++;

          if (status == 'moving') {
            moving++;
          } else if (status == 'stopped') {
            stopped++;
          }

          final bool isLive = !AppDateUtils.isOlderThanMinutes(
            lastSeen?.toString(),
            10,
          );
          if (isLive) {
            live++;
          } else {
            notLive++;
          }
        }
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.5),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left block (Total Staff + Grid)
                Expanded(
                  child: Column(
                    children: [
                      // Row 1: Header
                      InkWell(
                        onTap: () {
                          controller.selectedFilter.value = 'Total';
                          controller.filterEmployees();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: controller.selectedFilter.value == 'Total'
                                ? const Color(0xFFD4E4FF)
                                : const Color(0xFFF0F6FF),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6.5),
                            ),
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$total ',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'Total Staff',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(height: 1, color: Colors.grey.shade300),
                      // Row 2: Columns
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Column 1 (On Duty, Live, Not Live)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      controller.selectedFilter.value =
                                          'On Duty';
                                      controller.filterEmployees();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      color:
                                          controller.selectedFilter.value ==
                                              'On Duty'
                                          ? const Color(0xFFD1FAE5)
                                          : const Color(0xFFECFDF5),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF10B981),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '$onDuty',
                                                style: const TextStyle(
                                                  color: Color(0xFF10B981),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'On Duty',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            controller.selectedFilter.value =
                                                'Live';
                                            controller.filterEmployees();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            color:
                                                controller
                                                        .selectedFilter
                                                        .value ==
                                                    'Live'
                                                ? const Color(0xFFD1FAE5)
                                                : const Color(0xFFECFDF5),
                                            child: Column(
                                              children: [
                                                Text(
                                                  '$live',
                                                  style: const TextStyle(
                                                    color: Color(0xFF10B981),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const Text(
                                                  'Live',
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 9,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 26,
                                        color: Colors.grey.shade300,
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            controller.selectedFilter.value =
                                                'Not Live';
                                            controller.filterEmployees();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            color:
                                                controller
                                                        .selectedFilter
                                                        .value ==
                                                    'Not Live'
                                                ? const Color(0xFFFED7AA)
                                                : const Color(0xFFECFDF5),
                                            child: Column(
                                              children: [
                                                Text(
                                                  '$notLive',
                                                  style: const TextStyle(
                                                    color: Color(0xFFD97706),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const Text(
                                                  'Not Live',
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 9,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, color: Colors.grey.shade300),
                            // Column 2 (Off Duty)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      controller.selectedFilter.value =
                                          'Off Duty';
                                      controller.filterEmployees();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      color:
                                          controller.selectedFilter.value ==
                                              'Off Duty'
                                          ? const Color(0xFFFEE2E2)
                                          : const Color(0xFFFEF2F2),
                                      child: Column(
                                        children: [
                                          Text(
                                            '$offDuty',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Off Duty',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: const Color(0xFFFEF2F2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, color: Colors.grey.shade300),
                            // Column 3 (Not Installed)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      controller.selectedFilter.value =
                                          'Not Installed';
                                      controller.filterEmployees();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      color:
                                          controller.selectedFilter.value ==
                                              'Not Installed'
                                          ? const Color(0xFFE5E7EB)
                                          : const Color(0xFFF9FAFB),
                                      child: Column(
                                        children: [
                                          Text(
                                            '$notInstalled',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Not Installed',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: const Color(0xFFF9FAFB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, color: Colors.grey.shade300),
                // Right block (Moving + Stopped)
                SizedBox(
                  width: 85,
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              controller.selectedFilter.value = 'Moving';
                              controller.filterEmployees();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    controller.selectedFilter.value == 'Moving'
                                    ? const Color(0xFFC7D2FE)
                                    : const Color(0xFFEEF2FF),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(6.5),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$moving',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Moving',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(height: 1, color: Colors.grey.shade300),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              controller.selectedFilter.value = 'Stopped';
                              controller.filterEmployees();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    controller.selectedFilter.value == 'Stopped'
                                    ? const Color(0xFFFED7AA)
                                    : const Color(0xFFFFF7ED),
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(6.5),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$stopped',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Stopped',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
