import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/data/models/roles_responsibilities/roles_responsibilities_model.dart';
import 'package:mfresh_ops/modules/roles_responsibilities/controllers/roles_master_controller.dart';

import 'package:core/widgets/app_common_search_bar.dart';

class RolesMasterScreen extends StatelessWidget {
  const RolesMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RolesMasterController());

    return Scaffold(
      backgroundColor: AppColors.white,
      drawer: const CommonSidebar(),
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        showAppDrawer: true,
        hasBackButton: false,
        topHeader: const CommonShortcutHeader(),
        toolbarHeight: 45.h,
        title: Obx(
          () => controller.isSearching.value
              ? Padding(
                  padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
                  child: AppCommonSearchBar(
                    controller: controller.searchCtrl,
                    hintText: 'Search role name...',
                    onChanged: (v) => controller.searchQuery.value = v,
                  ),
                )
              : Text(
                  'Roles Master',
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
                size: 24.sp,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => controller.fetchRoles(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 0, bottom: 4.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Action Bar Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppCommonButton(
                              text: 'Add Role',
                              variant: ButtonVariant.primary,
                              buttonColor: const Color(0xFF16A3B8),
                              height: 24.h,
                              textSize: 11.sp,
                              isSmall: true,
                              borderRadius: 4.r,
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              onPressed: () => _showAddEditRoleDialog(context, controller),
                            ),
                            Text(
                              'Roles Master',
                              style: AppTextStyle.style_11_400(color: AppColors.grey400),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),

                        // Table
                        Obx(() {
                          final rolesList = controller.paginatedRoles;

                          if (rolesList.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.h),
                              child: Center(
                                child: Text(
                                  'No roles found',
                                  style: AppTextStyle.style_14_500(color: AppColors.grey300),
                                ),
                              ),
                            );
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: Table(
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                border: TableBorder.symmetric(
                                  inside: BorderSide(color: Colors.grey.shade300),
                                ),
                                columnWidths: {
                                  0: FixedColumnWidth(80.w),
                                  1: const FlexColumnWidth(),
                                  2: FixedColumnWidth(90.w),
                                },
                                children: [
                                  // Header Row
                                  TableRow(
                                    decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                                    children: [
                                      _buildSortableHeaderCell('Sl.No', 'id', controller),
                                      _buildSortableHeaderCell('Role Name', 'roleName', controller),
                                      _buildHeaderCell('Action', align: Alignment.center),
                                    ],
                                  ),
                                  // Data Rows
                                  ...rolesList.asMap().entries.map((entry) {
                                    final role = entry.value;
                                    final originalIdx = controller.roles.indexOf(role);
                                    final slNo = originalIdx != -1
                                        ? originalIdx + 1
                                        : (controller.currentPage.value - 1) * controller.perPage.value + entry.key + 1;

                                    return TableRow(
                                      children: [
                                        _buildDataCell('$slNo'),
                                        _buildDataCell(role.roleName),
                                        _buildActionCell(
                                          onEdit: () => _showAddEditRoleDialog(context, controller, roleItem: role),
                                          onDelete: () => _confirmDelete(context, controller, role),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 12.h),

                        // Pagination Footer
                        Obx(() {
                          final totalItems = controller.filteredRoles.length;
                          final startItem = totalItems == 0 ? 0 : ((controller.currentPage.value - 1) * controller.perPage.value) + 1;
                          final endItem = (startItem + controller.perPage.value - 1).clamp(0, totalItems);

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Showing $startItem to $endItem of $totalItems entries',
                                style: AppTextStyle.style_12_400(color: AppColors.black),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildPaginationButton('←', false, controller.previousPage),
                                  ...List.generate(controller.totalPages, (idx) {
                                    final pageNum = idx + 1;
                                    return _buildPaginationButton(
                                      '$pageNum',
                                      controller.currentPage.value == pageNum,
                                      () => controller.goToPage(pageNum),
                                    );
                                  }),
                                  _buildPaginationButton('→', false, controller.nextPage),
                                ],
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSortableHeaderCell(String text, String columnKey, RolesMasterController controller) {
    return Obx(() {
      final isSorted = controller.sortColumn.value == columnKey;
      final sortAscending = controller.sortAscending.value;

      return InkWell(
        onTap: () => controller.toggleSort(columnKey),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: AppTextStyle.style_12_700(color: AppColors.black),
              ),
              if (isSorted) ...[
                SizedBox(width: 3.w),
                Icon(
                  sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 13.sp,
                  color: AppColors.black,
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeaderCell(String text, {Alignment align = Alignment.centerLeft}) {
    return Container(
      alignment: align,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_700(color: AppColors.black),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_400(color: AppColors.black),
      ),
    );
  }

  Widget _buildActionCell({required VoidCallback onEdit, required VoidCallback onDelete}) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(4.r),
            child: Container(
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(Icons.edit_outlined, size: 13.r, color: const Color(0xFF64748B)),
            ),
          ),
          SizedBox(width: 6.w),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(4.r),
            child: Container(
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(Icons.delete_outline, size: 13.r, color: const Color(0xFFDC3545)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton(String text, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        margin: EdgeInsets.only(left: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade600 : const Color(0xFFF1F5F9),
          border: Border.all(color: isActive ? Colors.blue.shade600 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          text,
          style: AppTextStyle.style_12_500(color: isActive ? Colors.white : Colors.blue.shade600),
        ),
      ),
    );
  }

  void _showAddEditRoleDialog(BuildContext context, RolesMasterController controller, {RoleItem? roleItem}) {
    controller.roleNameCtrl.text = roleItem?.roleName ?? '';
    final isEdit = roleItem != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        title: Text(isEdit ? 'Edit Role' : 'Add Role', style: AppTextStyle.style_16_700(color: AppColors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppCommonTextField(
              controller: controller.roleNameCtrl,
              titleText: 'Role Name *',
              hintText: 'Enter role name',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyle.style_14_500(color: AppColors.grey300)),
          ),
          AppCommonButton(
            text: isEdit ? 'Update' : 'Save',
            variant: ButtonVariant.primary,
            buttonColor: const Color(0xFFF2562B),
            onPressed: () async {
              final name = controller.roleNameCtrl.text;
              final bool success = isEdit
                  ? await controller.updateRole(roleItem.id, name)
                  : await controller.addRole(name);
              if (success && ctx.mounted) {
                Navigator.pop(ctx);
              }
            },
            width: 90.w,
            height: 36.h,
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, RolesMasterController controller, RoleItem role) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        title: Text('Delete Role', style: AppTextStyle.style_16_700(color: AppColors.black)),
        content: Text('Are you sure you want to delete role "${role.roleName}"?', style: AppTextStyle.style_14_400(color: AppColors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyle.style_14_500(color: AppColors.grey300)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              controller.deleteRole(role.id);
            },
            child: Text('Delete', style: AppTextStyle.style_14_600(color: const Color(0xFFDC3545))),
          ),
        ],
      ),
    );
  }
}
