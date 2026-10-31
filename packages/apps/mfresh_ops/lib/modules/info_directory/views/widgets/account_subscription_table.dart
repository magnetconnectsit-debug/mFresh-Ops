// region Imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/core/constants/app_permissions.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/account_subscription_controller.dart';
import 'package:mfresh_ops/data/models/info_directory/account_subscription_model.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
// endregion

// region AccountSubscriptionTable Widget
class AccountSubscriptionTable extends StatelessWidget {
  // region Properties
  final AccountSubscriptionController controller;
  final RxSet<int> _visiblePasswords = <int>{}.obs;
  // endregion

  // region Constructor
  AccountSubscriptionTable({super.key, required this.controller});
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value && controller.subscriptions.isEmpty;
      final items = controller.subscriptions.toList();

      final startItem = controller.totalRecords.value == 0
          ? 0
          : (controller.currentPage.value - 1) * controller.perPage.value + 1;
      final endItem = (controller.currentPage.value * controller.perPage.value)
          .clamp(0, controller.totalRecords.value);

      final permissions = Get.find<AuthRepository>().rxUserPermissions;
      final canEdit = permissions.contains(AppPermissions.accountSubscriptionEdit);
      final canDelete = permissions.contains(AppPermissions.accountSubscriptionDelete);
      final showAction = canEdit || canDelete;

      final columns = _buildColumns(context, showAction, canEdit, canDelete);

      return AppRefreshIndicator(
        onRefresh: () => controller.resetFiltersAndRefresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCommonTable<AccountSubscriptionModel>(
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
                emptyText: 'No account subscriptions found.',
              ),
              if (!isLoading && controller.totalRecords.value > 0) ...[
                SizedBox(height: 10.h),
                AppTablePagination(
                  startItem: startItem,
                  endItem: endItem,
                  totalItems: controller.totalRecords.value,
                  currentPage: controller.currentPage.value,
                  totalPages: controller.lastPage.value,
                  onPageChanged: (page) => controller.goToPage(page),
                  onPreviousPage: () => controller.goToPage(controller.currentPage.value - 1),
                  onNextPage: () => controller.goToPage(controller.currentPage.value + 1),
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
  List<AppTableColumn<AccountSubscriptionModel>> _buildColumns(
    BuildContext context,
    bool showAction,
    bool canEdit,
    bool canDelete,
  ) {
    return [
      if (showAction)
        AppTableColumn<AccountSubscriptionModel>(
          key: 'action',
          title: 'Action',
          width: 65.w,
          sortable: false,
          alignment: Alignment.center,
          cellBuilder: (context, item, index, isExpanded) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canEdit)
                  InkWell(
                    onTap: () async {
                      if (!Get.find<AuthRepository>().rxUserPermissions.contains(AppPermissions.accountSubscriptionEdit)) {
                        AppCommonToastMessage.show(
                          message: 'You do not have permission to perform this action.',
                          type: ToastType.warning,
                        );
                        return;
                      }
                      final result = await Get.toNamed(
                        AppRoutes.createAccountSubscription,
                        arguments: item,
                      );
                      if (result == true) {
                        controller.fetchSubscriptions();
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
                if (canEdit && canDelete) SizedBox(width: 2.w),
                if (canDelete)
                  InkWell(
                    onTap: () => _confirmDelete(context, item),
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
      AppTableColumn<AccountSubscriptionModel>(
        key: 'account',
        title: 'Account',
        width: 80.w,
        sortable: true,
        valueGetter: (m) => m.accountName,
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.accountName,
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'company',
        title: 'Company',
        width: 90.w,
        sortable: true,
        valueGetter: (m) => m.company,
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.company,
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'brand',
        title: 'Brand',
        width: 90.w,
        sortable: true,
        valueGetter: (m) => m.brand,
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.brand,
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'service',
        title: 'Service',
        width: 100.w,
        sortable: true,
        valueGetter: (m) => m.service,
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.service,
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'unit',
        title: 'Unit',
        width: 90.w,
        sortable: true,
        valueGetter: (m) => m.unit,
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.unit,
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'city',
        title: 'City',
        width: 90.w,
        sortable: true,
        valueGetter: (m) => m.city,
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.city,
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'location',
        title: 'Location',
        width: 90.w,
        sortable: true,
        valueGetter: (m) => m.location,
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.location,
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'customerId',
        title: 'Customer ID',
        width: 100.w,
        sortable: true,
        valueGetter: (m) => m.customerID,
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.customerID,
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'mobileNo',
        title: 'Reg. Mob No',
        width: 120.w,
        sortable: true,
        valueGetter: (m) => m.mobileNo,
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.mobileNo,
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'email',
        title: 'Reg. Email',
        width: 130.w,
        sortable: true,
        valueGetter: (m) => m.email,
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.email,
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'username',
        title: 'User Name',
        width: 100.w,
        sortable: true,
        valueGetter: (m) => m.username,
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.username,
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'password',
        title: 'Password',
        width: 130.w,
        sortable: true,
        valueGetter: (m) => m.password,
        cellBuilder: (context, m, index, isExpanded) => _buildPasswordCell(m),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'urls',
        title: 'URLs',
        width: 110.w,
        sortable: true,
        valueGetter: (m) => m.urls ?? '',
        cellBuilder: (context, m, index, isExpanded) => _buildWeblinkCell(
          m.urls ?? '',
          isExpanded,
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'remarks',
        title: 'Remarks',
        width: 90.w,
        sortable: true,
        valueGetter: (m) => m.remarks ?? '',
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.remarks ?? '-',
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'planName',
        title: 'Plan Name',
        width: 90.w,
        sortable: true,
        valueGetter: (m) => m.planName,
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.planName,
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'payment',
        title: 'Payment',
        width: 80.w,
        sortable: true,
        valueGetter: (m) => m.paymentText,
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.paymentText,
          style: AppTextStyle.style_12_500(
            color: m.payment == '1' ? AppColors.success : AppColors.red,
          ),
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'billingCycle',
        title: 'Billing cycle & Due',
        width: 130.w,
        sortable: true,
        valueGetter: (m) => m.billingCycleDue,
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.billingCycleDue,
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'nextDue',
        title: 'Next Due On',
        width: 110.w,
        sortable: true,
        valueGetter: (m) => m.nextDue,
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.nextDue.isNotEmpty && m.nextDue != 'NA' && m.nextDue != '-'
              ? AppDateUtils.formatToOrdinalDate(m.nextDue)
              : '-',
          style: AppTextStyle.style_12_500(color: AppColors.black),
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'lastPayment',
        title: 'Last Payment',
        width: 110.w,
        sortable: true,
        valueGetter: (m) => m.lastPayment,
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.lastPayment.isNotEmpty && m.lastPayment != 'NA' && m.lastPayment != '-'
              ? AppDateUtils.formatToOrdinalDate(m.lastPayment)
              : '-',
          style: AppTextStyle.style_12_500(color: AppColors.black),
        ),
      ),
      AppTableColumn<AccountSubscriptionModel>(
        key: 'paymentDetails',
        title: 'Payment Details',
        width: 120.w,
        sortable: true,
        valueGetter: (m) => m.paymentDetails ?? '',
        cellBuilder: (context, m, index, isExpanded) => Text(
          m.paymentDetails ?? '-',
          style: AppTextStyle.style_12_500(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
    ];
  }
  // endregion

  // region Cell Builders
  Widget _buildPasswordCell(AccountSubscriptionModel model) {
    if (model.password.isEmpty || model.password == 'NA' || model.password == '-') {
      return Text('-', style: AppTextStyle.style_12_500(color: AppColors.black));
    }

    return Obx(() {
      final isVisible = _visiblePasswords.contains(model.id);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              isVisible ? model.password : '••••••••',
              style: AppTextStyle.style_12_500(color: AppColors.black),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 4.w),
          InkWell(
            onTap: () {
              if (isVisible) {
                _visiblePasswords.remove(model.id);
              } else {
                _visiblePasswords.add(model.id);
              }
            },
            child: Padding(
              padding: EdgeInsets.all(2.r),
              child: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                size: 14.sp,
                color: AppColors.grey500,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: model.password));
              AppCommonToastMessage.show(
                message: 'Password copied to clipboard',
                type: ToastType.success,
              );
            },
            child: Padding(
              padding: EdgeInsets.all(2.r),
              child: Icon(
                Icons.copy,
                size: 13.sp,
                color: AppColors.grey500,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildWeblinkCell(String text, bool isExpanded) {
    if (text.isEmpty || text == '-') {
      return Text('-', style: AppTextStyle.style_12_500(color: AppColors.black));
    }

    return InkWell(
      onTap: () {
        String finalUrl = text.trim();
        if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
          finalUrl = 'https://$finalUrl';
        }
        Get.to(() => AppCommonWebView(url: finalUrl, title: 'Weblink'));
      },
      child: Text(
        text,
        style: AppTextStyle.style_12_500(color: AppColors.primary)
            .copyWith(decoration: TextDecoration.underline),
        maxLines: isExpanded ? null : 1,
        overflow: isExpanded ? null : TextOverflow.ellipsis,
      ),
    );
  }
  // endregion

  // region Actions & Handlers
  Future<void> _confirmDelete(
    BuildContext context,
    AccountSubscriptionModel item,
  ) async {
    if (!Get.find<AuthRepository>().rxUserPermissions.contains(AppPermissions.accountSubscriptionDelete)) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to perform this action.',
        type: ToastType.warning,
      );
      return;
    }

    final confirmed = await AppCommonDialogBox.showConfirm(
      context,
      title: 'Delete Subscription',
      message: 'Are you sure you want to delete this subscription? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );

    if (confirmed) {
      controller.deleteSubscription(item.id);
    }
  }
  // endregion
}
// endregion
