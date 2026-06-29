import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/modules/collections/controllers/admin_collections_controller.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'widgets/admin_collections_filters.dart';
import 'widgets/admin_collections_table.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';

class AdminCollectionsScreen extends StatelessWidget {
  const AdminCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller here
    final controller = Get.put(AdminCollectionsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        showAppDrawer: true,
        hasBackButton: false,
        topHeader: const CommonShortcutHeader(),
        title: Text(
          'Admin Collection',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
      ),
      drawer: const CommonSidebar(),
      body: RefreshIndicator(
        onRefresh: () => controller.onRefresh(),
        color: AppColors.blue500,
        child: Obx(() {
          final authRepo = Get.find<AuthRepository>();
          final permissions = authRepo.rxUserPermissions;

          return Column(
            children: [
              const AdminCollectionsFilters(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24.h,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.exportToExcel();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF389D6A), // Greenish
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                          elevation: 1,
                        ),
                        child: Text('Export Excel', style: AppTextStyle.style_12_500(color: AppColors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              const Expanded(child: AdminCollectionsTable()),
              SizedBox(height: 16.h), // Bottom padding
            ],
          );
        }),
      ),
    );
  }
}
