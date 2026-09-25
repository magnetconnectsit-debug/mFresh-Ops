import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/mcontact_companies_controller.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/mcontact_companies_table.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/mcontact_company_dialog.dart';

class MContactCompaniesScreen extends StatelessWidget {
  const MContactCompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MContactCompaniesController());

    return Scaffold(
      backgroundColor: AppColors.white,
      drawer: const CommonSidebar(),
      body: SafeArea(
        child: Column(
          children: [
          const CommonShortcutHeader(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Companies',
                        style: AppTextStyle.style_15_700(color: AppColors.black),
                      ),
                      SizedBox(
                        height: 28.h,
                        child: ElevatedButton(
                          onPressed: () async {
                            await showMContactCompanyDialog(context, controller);
                            controller.fetchCompanies();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A3B8),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                            elevation: 1,
                          ),
                          child: Text('Create Company', style: AppTextStyle.style_12_500(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: MContactCompaniesTable(controller: controller),
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
