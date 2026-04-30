import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_tickets_controller.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:core/widgets/app_common_drop_down.dart';
import 'package:models/models.dart';

class SupportTicketsScreen extends StatelessWidget {
  const SupportTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SupportTicketsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        showAppDrawer: true,
        hasBackButton: false,
        title: Obx(
          () => controller.isSearching.value
              ? TextField(
                  controller: controller.searchController,
                  autofocus: true,
                  style: AppTextStyle.style_14_400(color: AppColors.black),
                  decoration: InputDecoration(
                    hintText: 'Search tickets...',
                    hintStyle: AppTextStyle.style_14_400(
                      color: AppColors.grey300,
                    ),
                    border: InputBorder.none,
                  ),
                )
              : Text(
                  'Support Tickets',
                  style: AppTextStyle.style_18_700(color: AppColors.black),
                ),
        ),
        actions: [
          Obx(
            () => IconButton(
              onPressed: () => controller.toggleSearch(),
              icon: Icon(
                controller.isSearching.value ? Icons.close : Icons.search,
                color: AppColors.black,
                size: 24.r,
              ),
            ),
          ),
        ],
      ),
      drawer: const CommonSidebar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryRow(),
              SizedBox(height: 12.h),
              _buildFiltersSection(controller),
              SizedBox(height: 12.h),
              _buildActionButtons(context, controller),
              SizedBox(height: 12.h),
              Obx(() => _buildTicketsTable(controller)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    final controller = Get.find<SupportTicketsController>();
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total: ${controller.totalTickets.value}',
            style: AppTextStyle.style_11_700(color: AppColors.black),
          ),
          SizedBox(height: 6.h),
          SizedBox(
            height: 24.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: controller.unitCounts.length,
              separatorBuilder: (context, index) => SizedBox(width: 6.w),
              itemBuilder: (context, index) {
                final unit = controller.unitCounts[index];
                return _buildSummaryItem(
                  '${unit.unit ?? 'N/A'} - ${unit.totalTickets}',
                  AppColors.orange,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color),
      ),
      child: Center(
        child: Text(label, style: AppTextStyle.style_10_600(color: color)),
      ),
    );
  }

  Widget _buildFiltersSection(SupportTicketsController controller) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.blue100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterGrid(controller),
          SizedBox(height: 12.h),
          _buildActiveFilters(controller),
          SizedBox(height: 12.h),
          Center(
            child: Wrap(
              spacing: 10.w,
              runSpacing: 8.h,
              children: [
                _buildFilterButton('Reset', AppColors.secondary, onTap: () => controller.resetFilters()),
                _buildFilterButton('Apply', AppColors.info, onTap: () => controller.applyFilters()),
                _buildFilterButton('Save Filter', AppColors.success, onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(SupportTicketsController controller) {
    return Obx(() {
      final List<dynamic> allSelected = [
        ...controller.selectedAssignees,
        if (controller.selectedPriority.value != null) controller.selectedPriority.value,
        ...controller.selectedCategories,
        if (controller.selectedSubCategory.value != null) controller.selectedSubCategory.value,
        ...controller.selectedUnits,
        ...controller.selectedStatuses,
        ...controller.selectedProjects,
      ];

      if (allSelected.isEmpty) return const SizedBox.shrink();

      return Wrap(
        spacing: 8.w,
        runSpacing: 4.h,
        children: allSelected.map((item) {
          String label = '';
          if (item is SupportCategory) {
            label = item.categoryName;
          } else if (item is SupportSubCategory) {
            label = item.subCategoryName;
          } else if (item is SupportProject) {
            label = item.projectName;
          } else if (item is SupportUnit) {
            label = item.unitName;
          } else if (item is AssigneeModel) {
            label = item.name;
          } else if (item is String) {
            label = item;
          }

          return _buildChip(label, () => controller.removeFilter(item));
        }).toList(),
      );
    });
  }

  Widget _buildChip(String label, VoidCallback onDelete) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyle.style_10_600(color: AppColors.primary)),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close, size: 12.r, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterGrid(SupportTicketsController controller) {
    return Obx(() => GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8.h,
      crossAxisSpacing: 10.w,
      childAspectRatio: 2.2, // Adjusted for dropdown height
      children: [
        AppCommonDropdown<AssigneeModel>(
          title: 'Assignee',
          hintText: 'Select',
          isMultiSelect: true,
          selectedValues: controller.selectedAssignees,
          options: controller.assigneeOptions,
          onMultiSelectChanged: (v) => controller.selectedAssignees.assignAll(v),
          height: 32.h,
        ),
        AppCommonDropdown<String>(
          title: 'Priority',
          hintText: 'Select',
          isMultiSelect: false,
          value: controller.selectedPriority.value,
          options: controller.priorityOptions,
          onChanged: (v) => controller.selectedPriority.value = v,
          height: 32.h,
        ),
        AppCommonDropdown<SupportCategory>(
          title: 'Category',
          hintText: 'Select',
          isMultiSelect: true,
          selectedValues: controller.selectedCategories,
          options: controller.categoryOptions,
          onMultiSelectChanged: (v) {
            controller.selectedCategories.assignAll(v);
            if (v.isNotEmpty) {
              // Fetch subcategories for the last selected category for now
              controller.fetchSubCategories(v.last.categoryId);
            } else {
              controller.subCategories.clear();
              controller.selectedSubCategory.value = null;
            }
          },
          height: 32.h,
        ),
        AppCommonDropdown<SupportSubCategory>(
          title: 'Sub Cat',
          hintText: 'Select',
          isMultiSelect: false,
          value: controller.selectedSubCategory.value,
          options: controller.subCategoryOptions,
          onChanged: (v) => controller.selectedSubCategory.value = v,
          height: 32.h,
        ),
        AppCommonDropdown<SupportUnit>(
          title: 'Unit',
          hintText: 'Select',
          isMultiSelect: true,
          selectedValues: controller.selectedUnits,
          options: controller.unitOptions,
          onMultiSelectChanged: (v) => controller.selectedUnits.assignAll(v),
          height: 32.h,
        ),
        AppCommonDropdown<String>(
          title: 'Status',
          hintText: 'Select',
          isMultiSelect: true,
          selectedValues: controller.selectedStatuses,
          options: controller.statusOptions,
          onMultiSelectChanged: (v) => controller.selectedStatuses.assignAll(v),
          height: 32.h,
        ),
        AppCommonDropdown<SupportProject>(
          title: 'Project',
          hintText: 'Select',
          isMultiSelect: true,
          selectedValues: controller.selectedProjects,
          options: controller.projectOptions,
          onMultiSelectChanged: (v) => controller.selectedProjects.assignAll(v),
          height: 32.h,
        ),
      ],
    ));
  }

  Widget _buildFilterButton(String label, Color color, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          label,
          style: AppTextStyle.style_11_600(color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, SupportTicketsController controller) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        _buildMainActionButton(
          'Create Ticket',
          AppColors.info,
          () => Get.toNamed(AppRoutes.createSupportTicket),
        ),
        _buildMainActionButton(
          'Export',
          AppColors.success,
          () => _showExportOptions(context, controller),
        ),
      ],
    );
  }

  void _showExportOptions(BuildContext context, SupportTicketsController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Export Tickets',
              style: AppTextStyle.style_16_700(color: AppColors.black),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: const Icon(Icons.table_view_rounded, color: AppColors.success),
              title: Text('Export to Excel', style: AppTextStyle.style_14_500(color: AppColors.black)),
              onTap: () {
                Get.back();
                controller.exportTickets(isPdf: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.red),
              title: Text('Export to PDF', style: AppTextStyle.style_14_500(color: AppColors.black)),
              onTap: () {
                Get.back();
                controller.exportTickets(isPdf: true);
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          label,
          style: AppTextStyle.style_12_600(color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildTicketsTable(SupportTicketsController controller) {
    if (controller.isLoading.value && controller.tickets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.tickets.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Text(
            'No tickets found',
            style: AppTextStyle.style_14_400(color: AppColors.grey400),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.grey50),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: AppColors.grey50),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: DataTable(
            showCheckboxColumn: false,
            horizontalMargin: 12.w,
            headingRowHeight: 36.h,
            dataRowMinHeight: 44.h,
            dataRowMaxHeight: 44.h,
            columnSpacing: 20.w,
            headingRowColor: WidgetStateProperty.all(AppColors.blue50),
            columns: [
              _buildTableHeader('Ticket'),
              _buildTableHeader('Unit No.'),
              _buildTableHeader('Subject'),
              _buildTableHeader('Project'),
              _buildTableHeader('Category'),
              _buildTableHeader('Sub-Catgry'),
              _buildTableHeader('Status'),
              _buildTableHeader('Priority'),
              _buildTableHeader('Assignee'),
              _buildTableHeader('Posted Date'),
            ],
            rows: controller.tickets.map((ticket) {
              return DataRow(
                onSelectChanged: (_) => Get.toNamed(
                  AppRoutes.ticketDetails,
                  arguments: ticket.id,
                ),
                cells: [
                  DataCell(
                    Text(
                      ticket.id.toString(),
                      style: AppTextStyle.style_11_600(color: AppColors.info),
                    ),
                  ),
                  DataCell(
                    Text(
                      ticket.unitNo ?? '',
                      style: AppTextStyle.style_11_400(color: AppColors.black),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 150.w,
                      child: Text(
                        ticket.subject ?? '',
                        style: AppTextStyle.style_11_400(
                          color: AppColors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      ticket.project ?? '',
                      style: AppTextStyle.style_11_400(color: AppColors.black),
                    ),
                  ),
                  DataCell(
                    Text(
                      ticket.mCategory ?? '',
                      style: AppTextStyle.style_11_400(color: AppColors.black),
                    ),
                  ),
                  DataCell(
                    Text(
                      ticket.subCat ?? '',
                      style: AppTextStyle.style_11_400(color: AppColors.black),
                    ),
                  ),
                  DataCell(
                    Text(
                      ticket.statusLabel ?? '',
                      style: AppTextStyle.style_11_700(
                        color: _parseColor(ticket.statusTextColor) ??
                            AppColors.red,
                      ),
                    ),
                  ),
                  DataCell(_buildPriorityBadge(
                    ticket.priorityLabel ?? '',
                    _parseColor(ticket.priorityBgColor),
                  )),
                  DataCell(
                    Text(
                      ticket.assignedTo ?? '',
                      style: AppTextStyle.style_11_400(color: AppColors.black),
                    ),
                  ),
                  DataCell(
                    Text(
                      ticket.postedDate ?? '',
                      style: AppTextStyle.style_10_400(color: AppColors.black),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Color? _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return null;
    if (colorStr.startsWith('#')) {
      final buffer = StringBuffer();
      if (colorStr.length == 7) buffer.write('ff');
      buffer.write(colorStr.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    }
    // Handle standard color names if any, otherwise return null
    return null;
  }

  DataColumn _buildTableHeader(String label) {
    return DataColumn(
      label: Text(
        label,
        style: AppTextStyle.style_11_700(color: AppColors.black),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority, Color? bgColor) {
    Color color = bgColor ?? AppColors.grey300;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        priority,
        style: AppTextStyle.style_9_400(
          color: color.computeLuminance() > 0.5 ? AppColors.black : AppColors.white,
        ),
      ),
    );
  }
}
