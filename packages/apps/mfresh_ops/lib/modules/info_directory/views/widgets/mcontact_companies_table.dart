// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/core/constants/app_permissions.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/mcontact_companies_controller.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/mcontact_company_dialog.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
// endregion

// region MContactCompaniesTable Widget
class MContactCompaniesTable extends StatelessWidget {
  // region Properties
  final MContactCompaniesController controller;
  // endregion

  // region Constructor
  const MContactCompaniesTable({super.key, required this.controller});
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value && controller.companies.isEmpty;
      final items = controller.companies.toList();

      final userPermissions = Get.find<AuthRepository>().rxUserPermissions;
      final canManage = userPermissions.contains(AppPermissions.companyDetails);

      final columns = <AppTableColumn<Map<String, dynamic>>>[
        AppTableColumn<Map<String, dynamic>>(
          key: 'id',
          title: '#',
          width: 60.w,
          sortable: false,
          alignment: Alignment.center,
          valueGetter: (c) => c['id']?.toString() ?? '',
          cellBuilder: (context, c, index, isExpanded) => Text(
            '${index + 1}',
            style: AppTextStyle.style_12_500(color: AppColors.black),
          ),
        ),
        AppTableColumn<Map<String, dynamic>>(
          key: 'name',
          title: 'Company Name',
          width: 300.w,
          sortable: false,
          valueGetter: (c) => c['company_name']?.toString() ?? c['name']?.toString() ?? '',
          cellBuilder: (context, c, index, isExpanded) {
            final name = c['company_name']?.toString() ?? c['name']?.toString() ?? '-';
            return Text(
              name,
              style: AppTextStyle.style_12_500(color: AppColors.black),
              maxLines: isExpanded ? null : 1,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
            );
          },
        ),
        if (canManage)
          AppTableColumn<Map<String, dynamic>>(
            key: 'action',
            title: 'Action',
            width: 80.w,
            sortable: false,
            alignment: Alignment.center,
            cellBuilder: (context, company, index, isExpanded) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () async {
                      if (!Get.find<AuthRepository>().rxUserPermissions.contains(AppPermissions.companyDetails)) {
                        AppCommonToastMessage.show(
                          message: 'You do not have permission to perform this action.',
                          type: ToastType.warning,
                        );
                        return;
                      }
                      await showMContactCompanyDialog(
                        context,
                        controller,
                        company: company,
                      );
                      controller.fetchCompanies();
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
                  SizedBox(width: 4.w),
                  InkWell(
                    onTap: () => _confirmDelete(context, company),
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
      ];

      return AppRefreshIndicator(
        onRefresh: () async => controller.fetchCompanies(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: AppCommonTable<Map<String, dynamic>>(
            items: items,
            columns: columns,
            isLoading: isLoading,
            headingRowColor: AppColors.aliceBlue,
            headingTextStyle: AppTextStyle.style_12_700(color: AppColors.black),
            dataTextStyle: AppTextStyle.style_12_500(color: AppColors.black),
            borderColor: AppColors.borderColor,
            headingRowHeight: 28.h,
            cellVerticalPadding: 6.h,
            cellHorizontalPadding: 8.w,
            enableColumnResizing: false,
            emptyText: 'No companies found.',
          ),
        ),
      );
    });
  }
  // endregion

  // region Actions & Confirmation
  Future<void> _confirmDelete(
    BuildContext context,
    Map<String, dynamic> company,
  ) async {
    if (!Get.find<AuthRepository>().rxUserPermissions.contains(AppPermissions.companyDetails)) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to perform this action.',
        type: ToastType.warning,
      );
      return;
    }

    final companyId = company['id'] as int?;
    final companyName =
        company['company_name']?.toString() ?? company['name']?.toString() ?? 'this company';

    if (companyId == null) return;

    final confirmed = await AppCommonDialogBox.showConfirm(
      context,
      title: 'Delete Company',
      message: 'Are you sure you want to delete "$companyName"?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );

    if (confirmed) {
      await controller.deleteCompany(companyId);
    }
  }
  // endregion
}
// endregion
