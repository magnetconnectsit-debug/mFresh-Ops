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
    return Container(
      padding: EdgeInsets.fromLTRB(6.w, 8.h, 6.w, 6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.grey50),
      ),
      child: Obx(() {
        final unitOptions = controller.unitOptions;
        final selectedUnits = controller.selectedUnitOptions;

        final auditorOptions = controller.auditorOptions;
        final selectedAuditors = controller.selectedAuditorOptions;

        final hasDateFilter = controller.fromDate.value != null && controller.fromDate.value!.isNotEmpty;
        final hasMonthFilter = controller.selectedFromMonth.value != null;
        final hasAnyFilter = selectedUnits.isNotEmpty ||
            selectedAuditors.isNotEmpty ||
            hasDateFilter ||
            hasMonthFilter;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Filter Rows
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                final unitWidget = MultiSelectDropdownWidget<int>(
                  label: 'Unit',
                  hint: 'Unit',
                  isSingleSelect: false,
                  showSelectAll: true,
                  showSearch: true,
                  selectedValues: controller.selectedUnitIds.toSet(),
                  items: unitOptions
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
                );

                final auditorWidget = MultiSelectDropdownWidget<int>(
                  label: 'Audited By',
                  hint: 'Audited By',
                  isSingleSelect: false,
                  showSelectAll: true,
                  showSearch: true,
                  selectedValues: controller.selectedAuditorIds.toSet(),
                  items: auditorOptions
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
                    controller.selectedAuditorIds.assignAll(values);
                    controller.fetchAuditReport();
                  },
                );

                final dateWidget = _buildDatePickerField(context);
                final monthWidget = _buildMonthPickerField(context);

                if (!isMobile) {
                  return Row(
                    children: [
                      Expanded(child: unitWidget),
                      SizedBox(width: 4.w),
                      Expanded(child: auditorWidget),
                      SizedBox(width: 4.w),
                      Expanded(child: dateWidget),
                      SizedBox(width: 4.w),
                      Expanded(child: monthWidget),
                    ],
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(child: unitWidget),
                        SizedBox(width: 4.w),
                        Expanded(child: auditorWidget),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Expanded(child: dateWidget),
                        SizedBox(width: 4.w),
                        Expanded(child: monthWidget),
                      ],
                    ),
                  ],
                );
              },
            ),

            // Active Filter Chips Section
            if (hasAnyFilter) ...[
              SizedBox(height: 6.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Active Filters:',
                      style: AppTextStyle.style_11_600(color: AppColors.grey500),
                    ),
                    SizedBox(width: 6.w),
                    // Unit chips
                    ...selectedUnits.map(
                      (unit) => Padding(
                        padding: EdgeInsets.only(right: 4.w),
                        child: _buildFilterChip(
                          label: 'Unit: ${unit.name}',
                          onRemove: () => controller.removeUnitFilter(unit.id),
                        ),
                      ),
                    ),
                    // Auditor chips
                    ...selectedAuditors.map(
                      (auditor) => Padding(
                        padding: EdgeInsets.only(right: 4.w),
                        child: _buildFilterChip(
                          label: 'Auditor: ${auditor.name}',
                          onRemove: () => controller.removeAuditorFilter(auditor.id),
                        ),
                      ),
                    ),
                    // Date chip
                    if (hasDateFilter && !hasMonthFilter)
                      Padding(
                        padding: EdgeInsets.only(right: 4.w),
                        child: _buildFilterChip(
                          label: 'Date: ${controller.dateRangeDisplayText}',
                          onRemove: () => controller.clearDateRangeFilter(),
                        ),
                      ),
                    // Month chip
                    if (hasMonthFilter)
                      Padding(
                        padding: EdgeInsets.only(right: 4.w),
                        child: _buildFilterChip(
                          label: 'Month: ${controller.monthRangeDisplayText}',
                          onRemove: () => controller.clearMonthRangeFilter(),
                        ),
                      ),
                    // Reset All
                    GestureDetector(
                      onTap: () => controller.resetFilters(),
                      child: Padding(
                        padding: EdgeInsets.only(left: 4.w, right: 4.w),
                        child: Text(
                          'Clear All',
                          style: AppTextStyle.style_11_500(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    final hasValue = controller.fromDate.value != null && controller.fromDate.value!.isNotEmpty;
    final displayText = controller.dateRangeDisplayText;

    return InkWell(
      onTap: () => controller.openDateRangePicker(context),
      child: InputDecorator(
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: 'Select Date',
              style: AppTextStyle.style_11_400(color: AppColors.grey200),
            ),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 6.w,
            vertical: 2.0.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(
              color: hasValue ? AppColors.primaryOrange : AppColors.borderColor,
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(
              color: hasValue ? AppColors.primaryOrange : AppColors.borderColor,
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                hasValue ? displayText : 'Select Date',
                style: hasValue
                    ? AppTextStyle.style_12_400(color: AppColors.grey900).copyWith(fontSize: 11.sp)
                    : AppTextStyle.style_12_400(color: AppColors.grey300).copyWith(fontSize: 11.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 13.r,
              color: hasValue ? AppColors.primaryOrange : AppColors.grey300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthPickerField(BuildContext context) {
    final hasValue = controller.selectedFromMonth.value != null;
    final displayText = controller.monthRangeDisplayText;

    return InkWell(
      onTap: () => controller.openMonthRangePicker(context),
      child: InputDecorator(
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: 'Select Month',
              style: AppTextStyle.style_11_400(color: AppColors.grey200),
            ),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 6.w,
            vertical: 2.0.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(
              color: hasValue ? AppColors.primaryOrange : AppColors.borderColor,
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(
              color: hasValue ? AppColors.primaryOrange : AppColors.borderColor,
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                hasValue ? displayText : 'Select Month',
                style: hasValue
                    ? AppTextStyle.style_12_400(color: AppColors.grey900).copyWith(fontSize: 11.sp)
                    : AppTextStyle.style_12_400(color: AppColors.grey300).copyWith(fontSize: 11.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.calendar_month_outlined,
              size: 13.r,
              color: hasValue ? AppColors.primaryOrange : AppColors.grey300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
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
            label,
            style: AppTextStyle.style_11_500(
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 13.sp,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
