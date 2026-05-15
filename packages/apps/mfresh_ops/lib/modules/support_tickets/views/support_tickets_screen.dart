import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_tickets_controller.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/data/models/models.dart';

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
          if (controller.isLoading.value && controller.tickets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () async => controller.fetchTickets(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total tickets
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      "Total Tickets: ${controller.totalTickets.value}",
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Unit summary chips
                  if (controller.unitCounts.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: controller.unitCounts.asMap().entries.map((entry) {
                          int index = entry.key;
                          var unitData = entry.value;
                          Color color = [
                            Colors.blue,
                            Colors.green,
                            Colors.red,
                            Colors.orange,
                            Colors.teal,
                          ][index % 5];

                          return Container(
                            margin: EdgeInsets.only(right: 8.w),
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: color),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              "${unitData.unit} - ${unitData.totalTickets}",
                              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12.sp),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  SizedBox(height: 20.h),

                  _buildFilterSection(controller),

                  SizedBox(height: 15.h),

                  _buildActionButtons(controller),

                  SizedBox(height: 20.h),

                  _buildTicketsTable(controller),
                ],
              ),
            ),
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
      child: LayoutBuilder(builder: (context, constraints) {
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
              items: controller.unitOptions.map((opt) => DropdownMenuItem(
                value: opt.value,
                child: Text(opt.label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp)),
              )).toList(),
              onChanged: (values) => controller.selectedUnits.assignAll(values.toList()),
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
                contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
            ),

            // CATEGORY
            _buildSingleDropdown<SupportCategory>(
              "Category",
              controller.selectedCategories.isNotEmpty ? controller.selectedCategories.first : null,
              controller.categoryOptions.map((opt) => DropdownMenuItem(
                value: opt.value,
                child: Text(opt.label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp)),
              )).toList(),
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
              controller.subCategoryOptions.map((opt) => DropdownMenuItem(
                value: opt.value,
                child: Text(opt.label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp)),
              )).toList(),
              (val) => controller.selectedSubCategory.value = val,
            ),

            // STATUS (multi-select)
            _buildMultiSelectDropdown<String>(
              label: "Status",
              selectedValues: controller.selectedStatuses.toSet(),
              items: [
                DropdownMenuItem(value: "0", child: Text("New", style: TextStyle(fontSize: 12.sp))),
                DropdownMenuItem(value: "1", child: Text("WIP", style: TextStyle(fontSize: 12.sp))),
                DropdownMenuItem(value: "4", child: Text("Hold", style: TextStyle(fontSize: 12.sp))),
                DropdownMenuItem(value: "5", child: Text("Awaited", style: TextStyle(fontSize: 12.sp))),
                DropdownMenuItem(value: "2", child: Text("Resolved", style: TextStyle(fontSize: 12.sp))),
                DropdownMenuItem(value: "3", child: Text("Closed", style: TextStyle(fontSize: 12.sp))),
              ],
              onChanged: (values) => controller.selectedStatuses.assignAll(values.toList()),
            ),

            // PROJECT (multi-select)
            _buildMultiSelectDropdown<SupportProject>(
              label: "Project",
              selectedValues: controller.selectedProjects.toSet(),
              items: controller.projectOptions.map((opt) => DropdownMenuItem(
                value: opt.value,
                child: Text(opt.label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp)),
              )).toList(),
              onChanged: (values) => controller.selectedProjects.assignAll(values.toList()),
            ),

            // ASSIGNEE (multi-select)
            _buildMultiSelectDropdown<AssigneeModel>(
              label: "Assignee",
              selectedValues: controller.selectedAssignees.toSet(),
              items: controller.assigneeOptions.map((opt) => DropdownMenuItem(
                value: opt.value,
                child: Text(opt.label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp)),
              )).toList(),
              onChanged: (values) => controller.selectedAssignees.assignAll(values.toList()),
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
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        );
      }),
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

  Widget _buildSingleDropdown<T>(String label, T? value, List<DropdownMenuItem<T>> items, Function(T?) onChanged) {
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
          SizedBox(width: 4.w),
          _actionButton(
            label: "Reset Filter",
            colors: const [Color(0xFF9E9E9E), Color(0xFF757575)],
            onTap: () => controller.resetFilters(),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({required String label, required List<Color> colors, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topCenter, end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildTicketsTable(SupportTicketsController controller) {
    if (controller.tickets.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Text('No tickets found', style: AppTextStyle.style_14_400(color: AppColors.grey400)),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 2000.w),
        child: DataTable(
          showCheckboxColumn: true,
          border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey.shade300, width: 1)),
          columnSpacing: 0,
          horizontalMargin: 0,
          dataRowMinHeight: 25.h,
          dataRowMaxHeight: 25.h,
          dividerThickness: 1,
          headingRowHeight: 30.h,
          headingRowColor: WidgetStateProperty.all(const Color(0xFFC5D5F0)),
          headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          columns: [
            _buildHeader("Ticket", isLeftAligned: true),
            _buildHeader("Unit No", isLeftAligned: true),
            _buildHeader("Subject", isLeftAligned: true),
            _buildHeader("Project", isLeftAligned: true),
            _buildHeader("Category", isLeftAligned: true),
            _buildHeader("Sub-Category", isLeftAligned: true),
            _buildHeader("Status"),
            _buildHeader("Priority"),
            _buildHeader("Assignee", isLeftAligned: true),
            _buildHeader("Comment", isLeftAligned: true),
            _buildHeader("Follow-up-on", isLeftAligned: true),
            _buildHeader("Date/Time Open", isLeftAligned: true),
            _buildHeader("Date/Time Close", isLeftAligned: true),
            _buildHeader("District", isLeftAligned: true),
            _buildHeader("Created By", isLeftAligned: true),
          ],
          rows: controller.tickets.map((ticket) {
            return DataRow(
              onSelectChanged: (_) => Get.toNamed(AppRoutes.ticketDetails, arguments: ticket.id),
              cells: [
                _buildCell(ticket.caseId ?? ticket.id.toString(), priority: ticket.priorityLabel, isLeft: true, textColor: Colors.blue),
                _buildCell(ticket.unitNo ?? '', priority: ticket.priorityLabel),
                _buildCell(ticket.subject ?? '', priority: ticket.priorityLabel),
                _buildCell(ticket.project ?? '', priority: ticket.priorityLabel),
                _buildCell(ticket.mCategory ?? '', priority: ticket.priorityLabel),
                _buildCell(ticket.subCat ?? '', priority: ticket.priorityLabel),
                DataCell(Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(border: Border(top: _rowBorder(ticket.priorityLabel), bottom: _rowBorder(ticket.priorityLabel))),
                  child: _statusBlock(ticket.statusLabel ?? ''),
                )),
                DataCell(Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(border: Border(top: _rowBorder(ticket.priorityLabel), bottom: _rowBorder(ticket.priorityLabel))),
                  child: _priorityBlock(ticket.priorityLabel ?? ''),
                )),
                _buildCell(ticket.assignedTo ?? '', priority: ticket.priorityLabel, fontWeight: FontWeight.bold),
                _buildCell(ticket.comment ?? '', priority: ticket.priorityLabel),
                _buildCell(ticket.followUp ?? '', priority: ticket.priorityLabel),
                _buildCell(ticket.postedDate ?? '', priority: ticket.priorityLabel),
                _buildCell("-", priority: ticket.priorityLabel),
                _buildCell(ticket.district ?? '', priority: ticket.priorityLabel),
                _buildCell(ticket.createdBy ?? '', priority: ticket.priorityLabel, isRight: true),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  DataColumn _buildHeader(String label, {bool isLeftAligned = false}) {
    return DataColumn(
      label: Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: isLeftAligned ? 6.0 : 0),
          alignment: isLeftAligned ? Alignment.centerLeft : Alignment.center,
          child: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  DataCell _buildCell(String text, {required String? priority, bool isLeft = false, bool isRight = false, Color? textColor, FontWeight? fontWeight}) {
    final border = _rowBorder(priority);
    return DataCell(
      Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            left: isLeft ? border : BorderSide.none,
            right: isRight ? border : BorderSide.none,
            top: border,
            bottom: border,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Text(
          text,
          style: TextStyle(color: textColor ?? Colors.black, fontWeight: fontWeight ?? FontWeight.normal, fontSize: 12.sp),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
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
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      color: bgColor,
      child: Text(status, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13.sp)),
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
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      color: bgColor,
      child: Text(priority, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13.sp)),
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
                        final text = item.child is Text ? (item.child as Text).data ?? '' : item.child.toString();
                        return text.toLowerCase().contains(searchController.text.toLowerCase());
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
                                contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.r)),
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
                                controlAffinity: ListTileControlAffinity.leading,
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
          selectedValues.isEmpty ? (hint ?? 'Select') : '${selectedValues.length} selected',
          style: TextStyle(fontSize: 12.sp),
        ),
      ),
    );
  }
}
