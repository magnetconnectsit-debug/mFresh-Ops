import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_tickets_controller.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';

class SupportTicketsScreen extends StatelessWidget {
  const SupportTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupportTicketsController>();

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppCommonAppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        showAppDrawer: true,
        hasBackButton: false,
        title: Text(
          "All Support Tickets",
          style: AppTextStyle.style_18_700(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.toggleSearch(),
            icon: Icon(Icons.search, color: Colors.black, size: 24.r),
          ),
        ],
      ),
      drawer: const CommonSidebar(),
      body: SafeArea(
        child: Obx(() {
          // Use skeletonizer for initial loading
          final showSkeleton =
              controller.isLoading.value && controller.tickets.isEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.r, 20.r, 20.r, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Total tickets
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Skeletonizer(
                            enabled: showSkeleton,
                            child: Text(
                              "Total Tickets: ${controller.totalTickets.value}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        // Reset filter button
                        Skeletonizer(
                          enabled: showSkeleton,
                          child: _actionButton(
                            label: "Reset Filter",
                            colors: const [Color(0xFF9E9E9E), Color(0xFF757575)],
                            onTap: () => controller.resetFilters(),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 5.h),

                    // Unit summary chips
                    if (controller.unitCounts.isNotEmpty || showSkeleton)
                      Skeletonizer(
                        enabled: showSkeleton,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                (showSkeleton
                                        ? List.generate(
                                            5,
                                            (index) => "Unit - 0",
                                          )
                                        : controller.unitCounts
                                              .map(
                                                (e) =>
                                                    "${e.unit} - ${e.totalTickets}",
                                              )
                                              .toList())
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      int index = entry.key;
                                      String label = entry.value;
                                      Color color = [
                                        Colors.blue,
                                        Colors.green,
                                        Colors.red,
                                        Colors.orange,
                                        Colors.teal,
                                      ][index % 5];

                                      return Container(
                                        margin: EdgeInsets.only(right: 8.w),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: color),
                                          borderRadius: BorderRadius.circular(
                                            4.r,
                                          ),
                                        ),
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      );
                                    })
                                    .toList(),
                          ),
                        ),
                      ),

                    SizedBox(height: 10.h),

                    Skeletonizer(
                      enabled: showSkeleton,
                      child: _buildFilterSection(controller),
                    ),

                    SizedBox(height: 10.h),

                    Skeletonizer(
                      enabled: showSkeleton,
                      child: _buildActionButtons(controller),
                    ),

                    SizedBox(height: 10.h),
                  ],
                ),
              ),

              // Table section - Expanded to take remaining space and handle its own scrolling
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.r),
                  child: _buildTicketsTable(controller),
                ),
              ),

              SizedBox(height: 10.h),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFilterSection(SupportTicketsController controller) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          int crossAxis = isMobile ? 2 : 4;

          return GridView.count(
            crossAxisCount: crossAxis,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8.h,
            crossAxisSpacing: 8.w,
            childAspectRatio: 4.2,
            children: [
              // UNIT (multi-select)
              _buildMultiSelectDropdown<SupportUnit>(
                label: "Unit",
                selectedValues: controller.selectedUnits.toSet(),
                items: controller.unitOptions
                    .map(
                      (opt) => DropdownMenuItem(
                        value: opt.value,
                        child: Text(
                          opt.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (values) =>
                    controller.selectedUnits.assignAll(values.toList()),
                showSearch: true,
              ),

              // GLOBAL SEARCH
              TextField(
                controller: controller.searchController,
                onChanged: (v) => controller.applyFilters(),
                style: TextStyle(fontSize: 12.sp),
                decoration: InputDecoration(
                  labelText: "Global",
                  labelStyle: TextStyle(fontSize: 12.sp),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),

              // CATEGORY
              _buildSingleDropdown<SupportCategory>(
                "Category",
                controller.selectedCategories.isNotEmpty
                    ? controller.selectedCategories.first
                    : null,
                controller.categoryOptions
                    .map(
                      (opt) => DropdownMenuItem(
                        value: opt.value,
                        child: Text(
                          opt.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    )
                    .toList(),
                (val) {
                  if (val != null) {
                    controller.selectedCategories.assignAll([val]);
                    controller.fetchSubCategories(val.categoryId);
                  } else {
                    controller.selectedCategories.clear();
                  }
                },
              ),

              // SUB CATEGORY
              _buildSingleDropdown<SupportSubCategory>(
                "Sub Category",
                controller.selectedSubCategory.value,
                controller.subCategoryOptions
                    .map(
                      (opt) => DropdownMenuItem(
                        value: opt.value,
                        child: Text(
                          opt.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    )
                    .toList(),
                (val) => controller.selectedSubCategory.value = val,
              ),

              // STATUS (multi-select)
              _buildMultiSelectDropdown<String>(
                label: "Status",
                selectedValues: controller.selectedStatuses.toSet(),
                items: [
                  DropdownMenuItem(
                    value: "0",
                    child: Text("New", style: TextStyle(fontSize: 12.sp)),
                  ),
                  DropdownMenuItem(
                    value: "1",
                    child: Text("WIP", style: TextStyle(fontSize: 12.sp)),
                  ),
                  DropdownMenuItem(
                    value: "4",
                    child: Text("Hold", style: TextStyle(fontSize: 12.sp)),
                  ),
                  DropdownMenuItem(
                    value: "5",
                    child: Text("Awaited", style: TextStyle(fontSize: 12.sp)),
                  ),
                  DropdownMenuItem(
                    value: "2",
                    child: Text("Resolved", style: TextStyle(fontSize: 12.sp)),
                  ),
                  DropdownMenuItem(
                    value: "3",
                    child: Text("Closed", style: TextStyle(fontSize: 12.sp)),
                  ),
                ],
                onChanged: (values) =>
                    controller.selectedStatuses.assignAll(values.toList()),
              ),

              // PROJECT (multi-select)
              _buildMultiSelectDropdown<SupportProject>(
                label: "Project",
                selectedValues: controller.selectedProjects.toSet(),
                items: controller.projectOptions
                    .map(
                      (opt) => DropdownMenuItem(
                        value: opt.value,
                        child: Text(
                          opt.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (values) =>
                    controller.selectedProjects.assignAll(values.toList()),
              ),

              // ASSIGNEE (multi-select)
              _buildMultiSelectDropdown<AssigneeModel>(
                label: "Assignee",
                selectedValues: controller.selectedAssignees.toSet(),
                items: controller.assigneeOptions
                    .map(
                      (opt) => DropdownMenuItem(
                        value: opt.value,
                        child: Text(
                          opt.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (values) =>
                    controller.selectedAssignees.assignAll(values.toList()),
                showSearch: true,
              ),

              // APPLY BUTTON
              InkWell(
                onTap: () => controller.applyFilters(),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FAAD9), Color(0xFF2E89C1)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "APPLY FILTER",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMultiSelectDropdown<T>({
    required String label,
    required Set<T> selectedValues,
    required List<DropdownMenuItem<T>> items,
    required Function(Set<T>) onChanged,
    bool showSearch = false,
  }) {
    return MultiSelectDropdownWidget<T>(
      label: label,
      selectedValues: selectedValues,
      items: items,
      onChanged: onChanged,
      showSearch: showSearch,
    );
  }

  Widget _buildSingleDropdown<T>(
    String label,
    T? value,
    List<DropdownMenuItem<T>> items,
    Function(T?) onChanged,
  ) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      icon: const SizedBox.shrink(),
      isDense: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12.sp),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  Widget _buildActionButtons(SupportTicketsController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _actionButton(
            label: "Create Ticket",
            colors: const [Color(0xFF4FAAD9), Color(0xFF2E89C1)],
            onTap: () => Get.toNamed(AppRoutes.createSupportTicket),
          ),
          SizedBox(width: 4.w),
          _actionButton(
            label: "Export Excel",
            colors: const [Color(0xFF67B27B), Color(0xFF4E9362)],
            onTap: () => controller.exportTickets(),
          ),
          Obx(() {
            if (controller.selectedTickets.isNotEmpty) {
              return Padding(
                padding: EdgeInsets.only(left: 4.w),
                child: _actionButton(
                  label: "Bulk Edit",
                  colors: const [Color(0xFF1E88E5), Color(0xFF0D47A1)],
                  onTap: () => _showBulkEditDialog(controller),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showBulkEditDialog(SupportTicketsController controller) {
    controller.resetBulkEdit();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Container(
          width: Get.width * 0.9,
          constraints: BoxConstraints(maxWidth: 400.w),
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF9F1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Bulk Update Tickets",
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Column(
                children: [
                  _buildBulkDropdownRow<SupportUnit>(
                    "Units",
                    controller.bulkEnableUnit,
                    controller.bulkSelectedUnit,
                    controller.unitOptions,
                    (val) => controller.bulkSelectedUnit.value = val,
                  ),
                  SizedBox(height: 10.h),
                  _buildBulkDropdownRow<String>(
                    "Priority",
                    controller.bulkEnablePriority,
                    controller.bulkSelectedPriority,
                    controller.priorityOptions,
                    (val) => controller.bulkSelectedPriority.value = val,
                  ),
                  SizedBox(height: 10.h),
                  _buildBulkDropdownRow<String>(
                    "Status",
                    controller.bulkEnableStatus,
                    controller.bulkSelectedStatus,
                    controller.statusOptions,
                    (val) => controller.bulkSelectedStatus.value = val,
                  ),
                  SizedBox(height: 10.h),
                  _buildBulkDropdownRow<SupportCategory>(
                    "Category",
                    controller.bulkEnableCategory,
                    controller.bulkSelectedCategory,
                    controller.categoryOptions,
                    (val) {
                      controller.bulkSelectedCategory.value = val;
                      if (val != null) {
                        controller.fetchBulkSubCategories(val.categoryId);
                      }
                    },
                  ),
                  SizedBox(height: 10.h),
                  Obx(() => _buildBulkDropdownRow<SupportSubCategory>(
                    "Sub-Cat",
                    controller.bulkEnableSubCategory,
                    controller.bulkSelectedSubCategory,
                    controller.bulkSubCategories.map((e) => DropdownOption(value: e, label: e.subCategoryName)).toList(),
                    (val) => controller.bulkSelectedSubCategory.value = val,
                  )),
                  SizedBox(height: 10.h),
                  _buildBulkDropdownRow<AssigneeModel>(
                    "Assignee",
                    controller.bulkEnableAssignee,
                    controller.bulkSelectedAssignee,
                    controller.assigneeOptions,
                    (val) => controller.bulkSelectedAssignee.value = val,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => controller.submitBulkEdit(),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      "Update",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulkDropdownRow<T>(
    String label,
    RxBool isEnabled,
    Rxn<T> selectedValue,
    List<DropdownOption<T>> options,
    Function(T?) onChanged,
  ) {
    return Row(
      children: [
        Obx(() => Checkbox(
          value: isEnabled.value,
          onChanged: (val) {
            isEnabled.value = val ?? false;
            if (!isEnabled.value) selectedValue.value = null;
          },
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        )),
        SizedBox(
          width: 65.w,
          child: Text(
            label, 
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Obx(() => Container(
            height: 34.h,
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: selectedValue.value,
                isExpanded: true,
                isDense: true,
                hint: Text("Select", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                icon: Icon(Icons.keyboard_arrow_down, size: 16.r, color: Colors.grey),
                items: options.map((opt) {
                  return DropdownMenuItem<T>(
                    value: opt.value,
                    child: Text(
                      opt.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  );
                }).toList(),
                onChanged: isEnabled.value ? onChanged : null,
              ),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildTicketsTable(SupportTicketsController controller) {
    if (controller.isLoading.value && controller.tickets.isEmpty) {
      return _buildSkeletonTable();
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

    final Map<int, TableColumnWidth> columnWidths = {
      for (int i = 0; i <= 15; i++) i: const IntrinsicColumnWidth(),
    };

    return Obx(() {
      // Ensure Obx watches for selection and expansion changes
      controller.selectedTickets.length;
      controller.expandedSubjectTickets.length;

      return RefreshIndicator(
        onRefresh: () => controller.fetchTickets(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: Get.width - 40),
              child: Table(
                columnWidths: columnWidths,
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  // Header Row
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFC5D5F0)),
                    children: [
                      TableCell(
                        child: Container(
                          height: 28,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.grey.shade300),
                              left: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Transform.scale(
                            scale: 0.85,
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: Checkbox(
                                value: controller.tickets.isNotEmpty &&
                                    controller.tickets.every((t) =>
                                        controller.selectedTickets.contains(t.id)),
                                onChanged: (val) =>
                                    controller.selectAllTickets(val),
                                activeColor: AppColors.primary,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                side: const BorderSide(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      TableCell(child: _buildHeaderCell("Ticket", hasRight: true)),
                      TableCell(child: _buildHeaderCell("Unit No.", hasRight: true)),
                      TableCell(child: _buildHeaderCell("Subject", hasRight: true)),
                      TableCell(child: _buildHeaderCell("Project", hasRight: true)),
                      TableCell(child: _buildHeaderCell("Category", hasRight: true)),
                      TableCell(child: _buildHeaderCell("Sub-Category", hasRight: true)),
                      TableCell(child: _buildHeaderCell("Status", hasRight: true)),
                      TableCell(child: _buildHeaderCell("Priority", hasRight: true)),
                      TableCell(child: _buildHeaderCell("Assignee", hasRight: true)),
                      TableCell(child: _buildHeaderCell("Comment", hasRight: true)),
                      TableCell(child: _buildHeaderCell("Follow-up-on", hasRight: true)),
                      TableCell(child: _buildHeaderCell("Date/Time Open", hasRight: true)),
                      TableCell(child: _buildHeaderCell("Date/Time Close", hasRight: true)),
                      TableCell(child: _buildHeaderCell("District", hasRight: true)),
                      TableCell(child: _buildHeaderCell("Created By", hasRight: true)),
                    ],
                  ),
                  // Data Rows
                  ...controller.tickets.map((ticket) {
                    final isSelected = controller.selectedTickets.contains(ticket.id);
                    final isExpanded = controller.expandedSubjectTickets.contains(ticket.id);
                    final isTopPriority = ticket.priorityLabel?.toLowerCase() == "top priority";

                    return TableRow(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.white,
                        border: Border(
                          top: isTopPriority ? const BorderSide(color: Colors.red, width: 1.5) : BorderSide.none,
                          left: isTopPriority ? const BorderSide(color: Colors.red, width: 1.5) : BorderSide.none,
                          right: isTopPriority ? const BorderSide(color: Colors.red, width: 1.5) : BorderSide.none,
                          bottom: _rowBorder(ticket.priorityLabel),
                        ),
                      ),
                      children: [
                        TableCell(
                          child: InkWell(
                            onTap: () => controller.toggleTicketSelection(ticket.id),
                            child: Container(
                              height: isExpanded ? null : 28,
                              decoration: BoxDecoration(
                                border: Border(right: BorderSide(color: Colors.grey.shade300)),
                              ),
                              alignment: Alignment.center,
                              child: IgnorePointer(
                                child: Transform.scale(
                                  scale: 0.85,
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Checkbox(
                                      value: isSelected,
                                      onChanged: (val) {},
                                      activeColor: AppColors.primary,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildDataCell(
                          child: InkWell(
                            onTap: () => Get.toNamed(AppRoutes.ticketDetails, arguments: ticket.id),
                            child: Text(
                              "${ticket.caseId}",
                              style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          priority: ticket.priorityLabel,
                          isCenter: true,
                          isExpanded: isExpanded,
                        ),
                        _buildDataCell(text: ticket.unitNo ?? '', priority: ticket.priorityLabel, isLeft: true, isExpanded: isExpanded),
                        TableCell(
                          child: InkWell(
                            onTap: () => controller.toggleSubjectExpansion(ticket.id),
                            child: Container(
                              height: isExpanded ? null : 28,
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                border: Border(right: BorderSide(color: Colors.grey.shade300)),
                              ),
                              child: Text(
                                ticket.subject ?? '',
                                style: const TextStyle(fontSize: 12),
                                overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                maxLines: isExpanded ? null : 1,
                              ),
                            ),
                          ),
                        ),
                        _buildDataCell(text: ticket.project ?? '', priority: ticket.priorityLabel, isLeft: true, isExpanded: isExpanded),
                        _buildDataCell(text: ticket.mCategory ?? '', priority: ticket.priorityLabel, isLeft: true, isExpanded: isExpanded),
                        _buildDataCell(text: ticket.subCat ?? '', priority: ticket.priorityLabel, isLeft: true, isExpanded: isExpanded),
                        TableCell(
                          child: Container(
                            height: isExpanded ? null : 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: Colors.grey.shade300)),
                            ),
                            child: _statusBlock(ticket.statusLabel ?? ''),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            height: isExpanded ? null : 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1)),
                            ),
                            child: _priorityBlock(ticket.priorityLabel ?? ''),
                          ),
                        ),
                        _buildDataCell(text: ticket.assignedTo ?? '', priority: ticket.priorityLabel, isLeft: true, isExpanded: isExpanded),
                        _buildDataCell(text: ticket.comment ?? '', priority: ticket.priorityLabel, isLeft: true, isExpanded: isExpanded),
                        _buildDataCell(text: ticket.followUp ?? '', priority: ticket.priorityLabel, isCenter: true, isExpanded: isExpanded),
                        _buildDataCell(
                          text: ticket.postedDate ?? '',
                          priority: ticket.priorityLabel,
                          isCenter: true,
                          isExpanded: isExpanded
                        ),
                        _buildDataCell(
                          text: "-",
                          priority: ticket.priorityLabel,
                          isCenter: true,
                          isExpanded: isExpanded
                        ),
                        _buildDataCell(text: ticket.district ?? '', priority: ticket.priorityLabel, isLeft: true, isExpanded: isExpanded),
                        TableCell(
                          child: Container(
                            height: isExpanded ? null : 28,
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              ticket.createdBy ?? '',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeaderCell(String title, {bool hasRight = false}) {
    return Container(
      alignment: Alignment.center,
      height: 28,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        border: Border(
          right: hasRight
              ? BorderSide(color: Colors.grey.shade300)
              : BorderSide.none,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildDataCell({
    String? text,
    Widget? child,
    bool isLeft = false,
    bool isCenter = false,
    String? priority,
    bool isExpanded = false,
  }) {
    return TableCell(
      child: Container(
        height: isExpanded ? null : 28,
        alignment: isLeft
            ? Alignment.centerLeft
            : (isCenter ? Alignment.center : Alignment.center),
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300)),
        ),
        child: child ??
            Text(
              text ?? '',
              style: const TextStyle(fontSize: 12),
              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              maxLines: isExpanded ? null : 1,
            ),
      ),
    );
  }



  Widget _buildSkeletonTable() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 3000.w),
            child: Container(height: 30.h, color: const Color(0xFFC5D5F0)),
          ),
        ),
        Expanded(
          child: Skeletonizer(
            enabled: true,
            child: ListView.builder(
              itemCount: 15,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) => Container(
                height: 30.h,
                margin: EdgeInsets.symmetric(vertical: 1.h),
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  BorderSide _rowBorder(String? priority) {
    if (priority?.toLowerCase() == "top priority") {
      return const BorderSide(color: Colors.red, width: 2.0);
    }
    return BorderSide(color: Colors.grey.shade300, width: 1);
  }

  Widget _statusBlock(String status) {
    Color bgColor;
    Color textColor = Colors.black;
    switch (status) {
      case "New":
        bgColor = Colors.white;
        textColor = Colors.red;
        break;
      case "WIP":
        bgColor = Colors.white;
        textColor = Colors.black;
        break;
      case "Awaited":
        bgColor = const Color(0x96f1ef94);
        textColor = Colors.black;
        break;
      case "Hold":
        bgColor = const Color(0x07b8ff96);
        textColor = Colors.black87;
        break;
      default:
        bgColor = Colors.white;
        textColor = Colors.black;
    }
    return Container(
      alignment: Alignment.center,
      color: bgColor,
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _priorityBlock(String priority) {
    Color bgColor;
    switch (priority) {
      case "Low":
        bgColor = Colors.white;
        break;
      case "Normal":
      case "Medium":
        bgColor = const Color(0xFFFFC107);
        break;
      case "High":
        bgColor = const Color(0xFFF44336);
        break;
      case "Top Priority":
        bgColor = const Color(0xFFB71C1C);
        break;
      default:
        bgColor = Colors.white;
    }
    return Container(
      alignment: Alignment.center,
      color: bgColor,
      child: Text(
        priority,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class MultiSelectDropdownWidget<T> extends StatelessWidget {
  final String label;
  final Set<T> selectedValues;
  final List<DropdownMenuItem<T>> items;
  final Function(Set<T>) onChanged;
  final String? hint;
  final bool showSearch;

  const MultiSelectDropdownWidget({
    super.key,
    required this.label,
    required this.selectedValues,
    required this.items,
    required this.onChanged,
    this.hint,
    this.showSearch = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        final Size size = renderBox.size;
        final Rect buttonRect = offset & size;

        final searchController = TextEditingController();
        Set<T> tempSelected = Set<T>.from(selectedValues);

        await showMenu(
          context: context,
          color: Colors.white,
          position: RelativeRect.fromRect(
            buttonRect,
            Offset.zero & MediaQuery.of(context).size,
          ),
          items: [
            PopupMenuItem(
              enabled: false,
              padding: EdgeInsets.zero,
              child: Container(
                width: size.width,
                constraints: BoxConstraints(maxWidth: 400.w, maxHeight: 400.h),
                color: Colors.white,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    List<DropdownMenuItem<T>> displayedItems = items;
                    if (showSearch && searchController.text.isNotEmpty) {
                      displayedItems = items.where((item) {
                        final text = item.child is Text
                            ? (item.child as Text).data ?? ''
                            : item.child.toString();
                        return text.toLowerCase().contains(
                          searchController.text.toLowerCase(),
                        );
                      }).toList();
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showSearch)
                          Padding(
                            padding: EdgeInsets.all(8.r),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Search ${label.toLowerCase()}...',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 6.h,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                              onChanged: (query) => setState(() {}),
                            ),
                          ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 200.h),
                          child: ListView(
                            shrinkWrap: true,
                            children: displayedItems.map((item) {
                              final value = item.value;
                              return CheckboxListTile(
                                title: item.child,
                                value: tempSelected.contains(value),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      tempSelected.add(value as T);
                                    } else {
                                      tempSelected.remove(value);
                                    }
                                  });
                                  onChanged(Set<T>.from(tempSelected));
                                },
                                dense: true,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 12.sp),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
        child: Text(
          selectedValues.isEmpty
              ? (hint ?? 'Select')
              : '${selectedValues.length} selected',
          style: TextStyle(fontSize: 12.sp),
        ),
      ),
    );
  }
}
