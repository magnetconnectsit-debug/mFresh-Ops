import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/mcontact_companies_controller.dart';

Future<void> showMContactCompanyDialog(BuildContext context, MContactCompaniesController controller, {Map<String, dynamic>? company}) async {
  if (company != null) {
    controller.companyNameCtrl.text = company['company_name']?.toString() ?? company['name']?.toString() ?? '';
  } else {
    controller.companyNameCtrl.clear();
  }

  await showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: AppColors.borderColor, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Form(
          key: controller.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                company != null ? 'Edit Company' : 'Create Company',
                style: AppTextStyle.style_16_700(color: AppColors.black),
              ),
              SizedBox(height: 20.h),
              TextFormField(
                controller: controller.companyNameCtrl,
                style: AppTextStyle.style_14_400(color: AppColors.black),
                decoration: InputDecoration(
                  hintText: 'Enter company name',
                  hintStyle: AppTextStyle.style_14_400(color: AppColors.grey500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Company name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.style_14_600(
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              final success = await controller.submitCompany(companyId: company?['id'] as int?);
                              if (success && dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        minimumSize: Size(80.w, 36.h),
                      ),
                      child: controller.isLoading.value
                          ? SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: const CustomAppLoader())
                          : Text(company != null ? 'Update' : 'Submit', style: AppTextStyle.style_14_600(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
