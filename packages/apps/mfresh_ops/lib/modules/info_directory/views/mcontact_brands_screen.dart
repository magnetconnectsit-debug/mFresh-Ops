import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/mcontact_brands_controller.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/mcontact_brands_table.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/mcontact_brand_dialog.dart';

class MContactBrandsScreen extends StatelessWidget {
  const MContactBrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MContactBrandsController());

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
                        'All Brands',
                        style: AppTextStyle.style_15_700(color: AppColors.black),
                      ),
                      SizedBox(
                        height: 28.h,
                        child: ElevatedButton(
                          onPressed: () async {
                            await showMContactBrandDialog(context, controller);
                            controller.fetchBrands();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A3B8),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                            elevation: 1,
                          ),
                          child: Text('Create Brands', style: AppTextStyle.style_12_500(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: MContactBrandsTable(controller: controller),
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
