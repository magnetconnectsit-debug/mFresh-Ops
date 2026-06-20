import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mfresh_ops/modules/staff_tracking/controllers/staff_tracking_controller.dart';
import 'package:mfresh_ops/modules/staff_tracking/views/widgets/employee_tracking_card.dart';

class StaffTrackingScreen extends GetView<StaffTrackingController> {
  const StaffTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          return AppCommonAppBar(
            title: controller.isSearching.value 
                ? _buildSearchAutocomplete(context)
                : const Text('Staff Tracking'),
            hasBackButton: !controller.isSearching.value,
            actions: [
              IconButton(
                icon: Icon(controller.isSearching.value ? Icons.close_rounded : Icons.search_rounded, color: AppColors.black),
                onPressed: () {
                  controller.isSearching.value = !controller.isSearching.value;
                  if (!controller.isSearching.value) {
                    controller.searchController.clear();
                  }
                },
              )
            ],
          );
        }),
      ),
      body: Column(
          children: [
            // Modern Segmented Tab Bar
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
                                return EmployeeTrackingCard(
                                  employee: emp,
                                  onTap: () => controller.openEmployeeHistory(emp),
                                );
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
    );
  }

  Widget _buildSearchAutocomplete(BuildContext context) {
    return Autocomplete<Map<String, dynamic>>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (controller.tabController.index == 0 || textEditingValue.text.isEmpty) {
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
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
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
              constraints: BoxConstraints(maxHeight: 250, maxWidth: MediaQuery.of(context).size.width - 80),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[100]),
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    title: Text(option['name'] ?? '', style: AppTextStyle.style_14_600(color: AppColors.black)),
                    subtitle: Text(option['mobile'] ?? '', style: AppTextStyle.style_12_500(color: AppColors.grey500)),
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

  // Employee card moved to EmployeeTrackingCard widget
}
