import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/inventory/controllers/allotment_controller.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'widgets/allotment_filters.dart';
import 'widgets/allotment_table.dart';

class AllotmentScreen extends StatefulWidget {
  const AllotmentScreen({super.key});

  @override
  State<AllotmentScreen> createState() => _AllotmentScreenState();
}

class _AllotmentScreenState extends State<AllotmentScreen> {
  late final AllotmentController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AllotmentController());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      final userPermissions = authRepo.rxUserPermissions;

      if (!userPermissions.contains('allotments_report')) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppCommonAppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            showAppDrawer: true,
            hasBackButton: false,
            topHeader: const CommonShortcutHeader(),
            toolbarHeight: 45.h,
            title: Text(
              'All Transfers',
              style: AppTextStyle.style_18_700(color: AppColors.black),
            ),
          ),
          drawer: const CommonSidebar(),
          body: Center(
            child: Text(
              'You do not have permission to view this page.',
              style: AppTextStyle.style_14_400(color: AppColors.grey500),
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppCommonAppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          showAppDrawer: true,
          hasBackButton: false,
          topHeader: const CommonShortcutHeader(),
          toolbarHeight: 45.h,
          title: Row(
            children: [
              Text(
                'All Transfer',
                style: AppTextStyle.style_18_700(color: AppColors.black),
              ),
              const Spacer(),
              AppCommonSearchBar(
                width: 140.w,
                controller: controller.searchController,
                hintText: 'Search',
                onChanged: (v) => controller.applyFilters(),
              ),
            ],
          ),
        ),
        drawer: const CommonSidebar(),
        body: AppRefreshIndicator(
          onRefresh: () async {
            controller.fromDateController.clear();
            controller.toDateController.clear();
            await controller.onRefresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AllotmentFilters(),
                const AllotmentTable(),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 32.h),
              ],
            ),
          ),
        ),
      );
    });
  }
}
