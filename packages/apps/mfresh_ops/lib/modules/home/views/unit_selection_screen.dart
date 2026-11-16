// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/home/controllers/unit_selection_controller.dart';
import 'package:mfresh_ops/modules/home/models/attendance_unit_item.dart';
import 'package:mfresh_ops/modules/home/views/widgets/attendance_unit_card.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
// endregion

// Export model for backward compatibility
export 'package:mfresh_ops/modules/home/models/attendance_unit_item.dart';

// region UnitSelectionScreen Widget
class UnitSelectionScreen extends StatefulWidget {
  final bool isSelfieAttendance;

  const UnitSelectionScreen({super.key, this.isSelfieAttendance = false});

  static Future<dynamic> show(
    BuildContext context, {
    bool isSelfieAttendance = false,
  }) async {
    final result = await Get.toNamed(
      AppRoutes.unitSelection,
      arguments: {'isSelfieAttendance': isSelfieAttendance},
    );
    return result;
  }

  @override
  State<UnitSelectionScreen> createState() => _UnitSelectionScreenState();
}

class _UnitSelectionScreenState extends State<UnitSelectionScreen> {
  // region Controller & State
  late final UnitSelectionController controller;

  @override
  void initState() {
    super.initState();
    final isSelfie =
        widget.isSelfieAttendance ||
        (Get.arguments is Map && Get.arguments['isSelfieAttendance'] == true);
    controller = Get.put(UnitSelectionController(isSelfieAttendance: isSelfie));
  }

  @override
  void dispose() {
    Get.delete<UnitSelectionController>();
    super.dispose();
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
      appBar: _buildAppBar(context, controller),
      body: Stack(
        children: [
          _buildBody(context, controller),
          Obx(() {
            if (controller.isSubmitting.value) {
              return Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: Container(
                    color: AppColors.black.withValues(alpha: 0.25),
                    child: const Center(child: CustomAppLoader()),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
  // endregion

  // region Header & App Bar
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    UnitSelectionController controller,
  ) {
    return AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      showAppDrawer: true,
      hasBackButton: false,
      topHeader: const CommonShortcutHeader(),
      toolbarHeight: 48.h,
      titleSpacing: 16.w,
      title: Text(
        'Select Unit',
        style: AppTextStyle.style_16_700(color: AppColors.black),
      ),

      actions: [
        if (controller.isSelfieAttendance)
          Obx(() {
            if (controller.isLoadingEmployees.value) {
              return Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: const Center(child: CustomAppLoader(size: 18)),
              );
            }

            final selected = controller.selectedEmployee.value;
            final empName = selected != null
                ? selected.name
                : 'Select Employee';

            return Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.only(right: 16.w),
              child: AppCommonMultiSelectDropdown<int>(
                isSingleSelect: true,
                showSearch: true,
                selectedValues: selected != null ? {selected.id} : {},
                items: controller.employeeList.map((emp) {
                  final roleStr =
                      (emp.role.isNotEmpty && int.tryParse(emp.role) == null)
                      ? ' - ${emp.role}'
                      : '';
                  return DropdownMenuItem<int>(
                    value: emp.id,
                    child: Text(
                      '${emp.name}$roleStr',
                      style: AppTextStyle.style_12_400(
                        color: AppColors.grey900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val.isEmpty) {
                    controller.selectEmployee(null);
                  } else {
                    controller.selectEmployee(val.first);
                  }
                },
                customChild: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: AppColors.fieldBorderColor,
                      width: 1.r,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 115.w),
                        child: Text(
                          empName,
                          style: AppTextStyle.style_12_500(
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16.r,
                        color: AppColors.grey600,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
  // endregion

  // region Section Builders
  Widget _buildBody(BuildContext context, UnitSelectionController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CustomAppLoader(size: 40));
      }

      final grouped = controller.groupedUnits;
      final screenWidth = MediaQuery.of(context).size.width;
      final bool isTablet = screenWidth > 600;
      final bool isDesktop = screenWidth > 1000;
      final int crossAxisCount = isDesktop ? 5 : (isTablet ? 3 : 2);
      final double childAspectRatio = isDesktop ? 2.2 : (isTablet ? 1.9 : 1.75);

      return Column(
        children: [
          if (!controller.isSelfieAttendance) _buildSearchField(controller),
          Expanded(
            child: grouped.isEmpty
                ? Center(
                    child: Text(
                      'No units available',
                      style: AppTextStyle.style_14_500(
                        color: AppColors.grey300,
                      ),
                    ),
                  )
                : _buildUnitListView(
                    context,
                    controller,
                    grouped,
                    crossAxisCount,
                    childAspectRatio,
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildSearchField(UnitSelectionController controller) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      child: AppCommonSearchBar(
        controller: controller.searchController,
        hintText: 'Search unit name, location...',
        width: double.infinity,
        onChanged: (val) => controller.onSearchChanged(val),
        onClose: () => controller.clearSearch(),
      ),
    );
  }

  Widget _buildUnitListView(
    BuildContext context,
    UnitSelectionController controller,
    Map<String, List<AttendanceUnitItem>> grouped,
    int crossAxisCount,
    double childAspectRatio,
  ) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 8.h)),
        for (final entry in grouped.entries) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
              child: _buildLocationHeader(entry.key),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: childAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate((ctx, index) {
                final unit = entry.value[index];
                return Obx(() {
                  final isSelected =
                      controller.selectedUnit.value?.id == unit.id;
                  return AttendanceUnitCard(
                    unit: unit,
                    isSelected: isSelected,
                    onTap: () => controller.onUnitCardTap(unit, context),
                  );
                });
              }, childCount: entry.value.length),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 10.h)),
        ],
        SliverToBoxAdapter(child: SizedBox(height: 16.h)),
      ],
    );
  }

  Widget _buildLocationHeader(String locationName) {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locationName,
            style: AppTextStyle.style_16_700(color: AppColors.successDark),
          ),
          SizedBox(height: 2.h),
          Container(height: 2.h, color: AppColors.successDark),
        ],
      ),
    );
  }

  // endregion
}

// endregion
