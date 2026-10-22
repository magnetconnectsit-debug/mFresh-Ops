// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/core/constants/app_permissions.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/info_directory_controller.dart';
import 'package:mfresh_ops/data/models/info_directory/contact_model.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
// endregion

// region InfoDirectoryTable Widget
class InfoDirectoryTable extends StatelessWidget {
  // region Properties
  final InfoDirectoryController controller;
  // endregion

  // region Constructor
  const InfoDirectoryTable({super.key, required this.controller});
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value && !controller.isRefreshing.value;
      final items = controller.contacts.toList();

      final startItem = controller.totalRecords.value == 0
          ? 0
          : (controller.currentPage.value - 1) * controller.perPage.value + 1;
      final endItem = (controller.currentPage.value * controller.perPage.value)
          .clamp(0, controller.totalRecords.value);

      final permissions = Get.find<AuthRepository>().rxUserPermissions;
      final canEdit = permissions.contains(AppPermissions.contactEdit);
      final canDelete = permissions.contains(AppPermissions.contactDelete);
      final showAction = canEdit || canDelete;

      final columns = _buildColumns(context, showAction, canEdit, canDelete);

      return AppRefreshIndicator(
        onRefresh: () => controller.resetFiltersAndRefresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCommonTable<ContactModel>(
                items: items,
                columns: columns,
                currentSortColumn: controller.sortColumn.value,
                currentSortOrder: controller.currentSortOrder,
                onSort: (columnKey, sortOrder) =>
                    controller.sortBy(columnKey, sortOrder),
                isLoading: isLoading,
                headingRowColor: AppColors.aliceBlue,
                headingTextStyle: AppTextStyle.style_12_700(
                  color: AppColors.black,
                ),
                dataTextStyle: AppTextStyle.style_12_500(
                  color: AppColors.black,
                ),
                borderColor: AppColors.borderColor,
                headingRowHeight: 28.h,
                cellVerticalPadding: 4.h,
                cellHorizontalPadding: 8.w,
                enableColumnResizing: false,
                emptyText: 'No contacts found.',
              ),
              if (!isLoading && controller.totalRecords.value > 0) ...[
                SizedBox(height: 10.h),
                AppTablePagination(
                  startItem: startItem,
                  endItem: endItem,
                  totalItems: controller.totalRecords.value,
                  currentPage: controller.currentPage.value,
                  totalPages: controller.totalPages.value,
                  onPageChanged: (page) => controller.goToPage(page),
                  onPreviousPage: () => controller.previousPage(),
                  onNextPage: () => controller.nextPage(),
                ),
                SizedBox(height: 20.h),
              ],
            ],
          ),
        ),
      );
    });
  }
  // endregion

  // region Columns Definition
  List<AppTableColumn<ContactModel>> _buildColumns(
    BuildContext context,
    bool showAction,
    bool canEdit,
    bool canDelete,
  ) {
    return [
      if (showAction)
        AppTableColumn<ContactModel>(
          key: 'action',
          title: 'Action',
          width: 70.w,
          sortable: false,
          alignment: Alignment.center,
          cellBuilder: (context, contact, index, isExpanded) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canEdit)
                  InkWell(
                    onTap: () async {
                      if (!Get.find<AuthRepository>().rxUserPermissions.contains(AppPermissions.contactEdit)) {
                        AppCommonToastMessage.show(
                          message: 'You do not have permission to perform this action.',
                          type: ToastType.warning,
                        );
                        return;
                      }
                      final result = await Get.toNamed(
                        AppRoutes.createContact,
                        arguments: contact,
                      );
                      if (result == true) {
                        controller.fetchContacts(showFullScreenLoader: false);
                      }
                    },
                    borderRadius: BorderRadius.circular(4.r),
                    child: Padding(
                      padding: EdgeInsets.all(3.r),
                      child: Icon(
                        Icons.edit_square,
                        size: 16.r,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                if (canEdit && canDelete) SizedBox(width: 4.w),
                if (canDelete)
                  InkWell(
                    onTap: () => _confirmDeleteContact(context, contact),
                    borderRadius: BorderRadius.circular(4.r),
                    child: Padding(
                      padding: EdgeInsets.all(3.r),
                      child: Icon(
                        Icons.delete,
                        size: 16.r,
                        color: AppColors.red,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      AppTableColumn<ContactModel>(
        key: 'name',
        title: 'Name',
        width: 135.w,
        sortable: true,
        valueGetter: (c) => c.name,
        cellBuilder: (context, c, index, isExpanded) => Text(
          c.name.isNotEmpty ? c.name : '-',
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<ContactModel>(
        key: 'contact_type',
        title: 'Contact Type',
        width: 100.w,
        sortable: true,
        valueGetter: (c) => c.contactType,
        cellBuilder: (context, c, index, isExpanded) => Text(
          c.contactType.isNotEmpty ? c.contactType : '-',
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<ContactModel>(
        key: 'brand',
        title: 'Brand',
        width: 120.w,
        sortable: true,
        valueGetter: (c) => c.brand,
        cellBuilder: (context, c, index, isExpanded) => Text(
          c.brand.isNotEmpty ? c.brand : '-',
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<ContactModel>(
        key: 'company',
        title: 'Company',
        width: 130.w,
        sortable: true,
        valueGetter: (c) => c.company,
        cellBuilder: (context, c, index, isExpanded) => Text(
          c.company.isNotEmpty ? c.company : '-',
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<ContactModel>(
        key: 'mobile1',
        title: 'Mobile 1',
        width: 125.w,
        sortable: true,
        valueGetter: (c) => c.mobile1,
        cellBuilder: (context, c, index, isExpanded) => _buildPhoneCell(
          c.mobile1,
          isExpanded,
        ),
      ),
      AppTableColumn<ContactModel>(
        key: 'mobile2',
        title: 'Mobile 2',
        width: 125.w,
        sortable: true,
        valueGetter: (c) => c.mobile2,
        cellBuilder: (context, c, index, isExpanded) => _buildPhoneCell(
          c.mobile2,
          isExpanded,
        ),
      ),
      AppTableColumn<ContactModel>(
        key: 'services',
        title: 'Services',
        width: 180.w,
        sortable: true,
        valueGetter: (c) => c.services,
        cellBuilder: (context, c, index, isExpanded) => Text(
          c.services.isNotEmpty ? c.services : '-',
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<ContactModel>(
        key: 'description',
        title: 'Description',
        width: 200.w,
        sortable: true,
        valueGetter: (c) => c.description,
        cellBuilder: (context, c, index, isExpanded) => Text(
          c.description.isNotEmpty ? c.description : '-',
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<ContactModel>(
        key: 'worked_on',
        title: 'Worked On',
        width: 140.w,
        sortable: true,
        valueGetter: (c) => c.workedOn,
        cellBuilder: (context, c, index, isExpanded) => Text(
          c.workedOn.isNotEmpty ? c.workedOn : '-',
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<ContactModel>(
        key: 'location',
        title: 'Location',
        width: 130.w,
        sortable: true,
        valueGetter: (c) => c.location,
        cellBuilder: (context, c, index, isExpanded) => Text(
          c.location.isNotEmpty ? c.location : '-',
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<ContactModel>(
        key: 'department',
        title: 'Department',
        width: 130.w,
        sortable: true,
        valueGetter: (c) => c.department,
        cellBuilder: (context, c, index, isExpanded) => Text(
          c.department.isNotEmpty ? c.department : '-',
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<ContactModel>(
        key: 'designation',
        title: 'Designation',
        width: 130.w,
        sortable: true,
        valueGetter: (c) => c.designation,
        cellBuilder: (context, c, index, isExpanded) => Text(
          c.designation.isNotEmpty ? c.designation : '-',
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<ContactModel>(
        key: 'email',
        title: 'Email',
        width: 170.w,
        sortable: true,
        valueGetter: (c) => c.email,
        cellBuilder: (context, c, index, isExpanded) => Text(
          c.email.isNotEmpty ? c.email : '-',
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<ContactModel>(
        key: 'weblinks',
        title: 'Weblinks',
        width: 140.w,
        sortable: true,
        valueGetter: (c) => c.weblinks,
        cellBuilder: (context, c, index, isExpanded) => _buildWeblinkCell(
          c.weblinks,
          isExpanded,
        ),
      ),
      AppTableColumn<ContactModel>(
        key: 'gstin',
        title: 'GSTIN',
        width: 130.w,
        sortable: true,
        valueGetter: (c) => c.gstin,
        cellBuilder: (context, c, index, isExpanded) => Text(
          c.gstin.isNotEmpty ? c.gstin : '-',
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<ContactModel>(
        key: 'address',
        title: 'Address',
        width: 160.w,
        sortable: true,
        valueGetter: (c) => c.address,
        cellBuilder: (context, c, index, isExpanded) => Text(
          c.address.isNotEmpty ? c.address : '-',
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
    ];
  }
  // endregion

  // region Cell Builders
  Widget _buildPhoneCell(String text, bool isExpanded) {
    if (text.isEmpty || text == '-') {
      return Text(
        '-',
        style: AppTextStyle.style_12_500(color: AppColors.black),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            style: AppTextStyle.style_12_500(color: AppColors.black),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 4.w),
        InkWell(
          onTap: () => _makePhoneCall(text),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(2.r),
            child: Icon(Icons.call, size: 14.sp, color: AppColors.success),
          ),
        ),
      ],
    );
  }

  Widget _buildWeblinkCell(String text, bool isExpanded) {
    if (text.isEmpty || text == '-') {
      return Text(
        '-',
        style: AppTextStyle.style_12_500(color: AppColors.black),
      );
    }

    return InkWell(
      onTap: () => _openWeblink(text),
      child: Text(
        text,
        style: AppTextStyle.style_12_500(
          color: AppColors.primary,
        ).copyWith(decoration: TextDecoration.underline),
        maxLines: isExpanded ? null : 1,
        overflow: isExpanded ? null : TextOverflow.ellipsis,
      ),
    );
  }
  // endregion

  // region Actions & Handlers
  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _openWeblink(String url) {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty || cleanUrl == '-') return;

    String finalUrl = cleanUrl;
    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      finalUrl = 'https://$finalUrl';
    }

    Get.to(() => AppCommonWebView(url: finalUrl, title: 'Weblink'));
  }

  Future<void> _confirmDeleteContact(
    BuildContext context,
    ContactModel contact,
  ) async {
    if (!Get.find<AuthRepository>().rxUserPermissions.contains(AppPermissions.contactDelete)) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to perform this action.',
        type: ToastType.warning,
      );
      return;
    }

    final confirmed = await AppCommonDialogBox.showConfirm(
      context,
      title: 'Delete Contact',
      message:
          'Are you sure you want to delete "${contact.name}"? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );

    if (confirmed) {
      controller.deleteContact(contact.id);
    }
  }
  // endregion
}
// endregion
