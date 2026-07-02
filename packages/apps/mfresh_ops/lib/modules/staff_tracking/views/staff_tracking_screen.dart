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

class StaffTrackingScreen extends GetView<StaffTrackingController> {
  const StaffTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      drawer: const CommonSidebar(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 50),
        child: Obx(() {
          return AppCommonAppBar(
            title: controller.isSearching.value
                ? _buildSearchAutocomplete(context)
                : const Text('Staff Tracking'),
            hasBackButton: false,
            showAppDrawer: true,
            topHeader: const CommonShortcutHeader(),
            actions: [
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
      body: Column(
        children: [
          // Stats Row
          _buildStatsRow(controller),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: controller.tabController,
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
              tabs: const [
                Tab(
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
                Tab(
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
              controller: controller.tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Tab 1: List
                Column(
                  children: [
                    const SizedBox(height: 6),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value &&
                            controller.allEmployees.isEmpty) {
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

                // Tab 2: Map
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
                            myLocationButtonEnabled: true,
                            myLocationEnabled: true,
                            mapToolbarEnabled: false,
                            zoomControlsEnabled: false,
                            onMapCreated: (mapController) {
                              controller.mapController = mapController;
                            },
                            onCameraMove: (CameraPosition position) {
                              controller.onCameraMove(position);
                            },
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAutocomplete(BuildContext context) {
    return Autocomplete<Map<String, dynamic>>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (controller.tabController.index == 0 ||
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
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Row 1: Total Staff
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  controller.selectedFilter.value = 'Total';
                  controller.filterEmployees();
                },
                borderRadius: BorderRadius.circular(6),
                child: Obx(() {
                  final isSelected = controller.selectedFilter.value == 'Total';
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFD4E4FF)
                          : const Color(0xFFEBF3FF),
                      border: Border.all(
                        color: const Color(0xFFB3D4FF),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFFB3D4FF,
                                ).withValues(alpha: 0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people_alt_outlined,
                          size: 16,
                          color: AppColors.black,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$total',
                          style: AppTextStyle.style_12_600(
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Total Staff',
                          style: AppTextStyle.style_10_500(
                            color: AppColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 6),

            // Row 2: On Duty, Off Duty, Not Installed
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    controller,
                    'On Duty',
                    onDuty,
                    Colors.green,
                    Icons.work_outline,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildStatBox(
                    controller,
                    'Off Duty',
                    offDuty,
                    Colors.red,
                    Icons.home_work_outlined,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildStatBox(
                    controller,
                    'Not Installed',
                    notInstalled,
                    Colors.grey,
                    Icons.mobile_off_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Row 3: Live/Not Live & Moving/Stopped
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        _buildRowStatItem(
                          controller,
                          'Live',
                          live,
                          Colors.green,
                          Icons.wifi,
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _buildRowStatItem(
                          controller,
                          'Not Live',
                          notLive,
                          Colors.orange,
                          Icons.wifi_off,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        _buildRowStatItem(
                          controller,
                          'Moving',
                          moving,
                          Colors.blue,
                          Icons.directions_run,
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _buildRowStatItem(
                          controller,
                          'Stopped',
                          stopped,
                          Colors.deepOrangeAccent,
                          Icons.front_hand,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatBox(
    StaffTrackingController controller,
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    final isSelected = controller.selectedFilter.value == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.selectedFilter.value = label;
          controller.filterEmployees();
        },
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? color : Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text('$count', style: AppTextStyle.style_12_600(color: color)),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyle.style_9_400(
                    color: isSelected ? AppColors.black : Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowStatItem(
    StaffTrackingController controller,
    String label,
    int count,
    Color dotColor,
    IconData icon,
  ) {
    final isSelected = controller.selectedFilter.value == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.selectedFilter.value = label;
          controller.filterEmployees();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: isSelected
              ? dotColor.withValues(alpha: 0.15)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, size: 14, color: dotColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyle.style_10_500(
                  color: isSelected ? AppColors.black : Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              Text(
                '$count',
                style: AppTextStyle.style_12_600(color: AppColors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
