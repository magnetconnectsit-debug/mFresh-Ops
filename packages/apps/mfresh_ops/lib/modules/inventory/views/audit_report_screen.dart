import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import '../controllers/audit_report_controller.dart';
import 'widgets/audit_report_table.dart';

class AuditReportScreen extends StatefulWidget {
  const AuditReportScreen({super.key});

  @override
  State<AuditReportScreen> createState() => _AuditReportScreenState();
}

class _AuditReportScreenState extends State<AuditReportScreen> {
  late final AuditReportController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AuditReportController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        showAppDrawer: true,
        hasBackButton: false,
        topHeader: const CommonShortcutHeader(),
        title: Obx(
          () => controller.isSearching.value
              ? AppCommonSearchBar(
                  controller: controller.searchController,
                  hintText: 'Search audit no, unit, auditor...',
                  onChanged: (_) => controller.applySearch(),
                )
              : Text(
                  'Inventory Audit Report',
                  style: AppTextStyle.style_16_700(color: AppColors.black),
                ),
        ),
        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.toggleSearch,
              icon: Icon(
                controller.isSearching.value ? Icons.close : Icons.search,
              ),
            ),
          ),
        ],
      ),
      drawer: const CommonSidebar(),
      body: AppRefreshIndicator(
        onRefresh: controller.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(12.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterCard(),
              SizedBox(height: 12.h),
              const AuditReportTable(),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Module Table Filter Card UI ──────────────────────────────────────────────

  Widget _buildFilterCard() {
    const double filterHeight = 28;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Obx(() {
        final options = controller.unitOptions;
        final selectedUnits = controller.selectedUnitOptions;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MultiSelectDropdownWidget<int>(
              label: 'Select Unit',
              hint: 'Select Unit',
              isSingleSelect: false,
              showSelectAll: true,
              showSearch: true,
              height: filterHeight.h,
              selectedValues: controller.selectedUnitIds.toSet(),
              items: options
                  .map(
                    (opt) => DropdownMenuItem<int>(
                      value: opt.id,
                      child: Text(
                        opt.name,
                        style: AppTextStyle.style_12_400(color: AppColors.grey900),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (values) {
                controller.selectedUnitIds.assignAll(values);
                controller.fetchAuditReport();
              },
            ),
            if (selectedUnits.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Selected Unit:',
                    style: AppTextStyle.style_11_600(color: AppColors.grey500),
                  ),
                  ...selectedUnits.map(
                    (unit) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            unit.name,
                            style: AppTextStyle.style_11_500(
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          GestureDetector(
                            onTap: () => controller.removeUnitFilter(unit.id),
                            child: Icon(
                              Icons.close,
                              size: 13.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (selectedUnits.length > 1)
                    GestureDetector(
                      onTap: () => controller.clearUnitFilters(),
                      child: Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Text(
                          'Clear All',
                          style: AppTextStyle.style_11_500(color: Colors.red),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        );
      }),
    );
  }
}
