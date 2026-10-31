// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/mcontact_companies_controller.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/mcontact_companies_table.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/mcontact_company_dialog.dart';
// endregion

// region MContactCompaniesScreen Class
class MContactCompaniesScreen extends StatelessWidget {
  const MContactCompaniesScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MContactCompaniesController());

    return Scaffold(
      backgroundColor: AppColors.white,
      drawer: const CommonSidebar(),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, controller),
              SizedBox(height: 10.h),
              Expanded(
                child: MContactCompaniesTable(controller: controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // endregion

  // region App Bar
  PreferredSizeWidget _buildAppBar() {
    return const AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      showAppDrawer: true,
      hasBackButton: false,
      topHeader: CommonShortcutHeader(),
    );
  }
  // endregion

  // region Header & Action Button
  Widget _buildHeader(
    BuildContext context,
    MContactCompaniesController controller,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'All Companies',
          style: AppTextStyle.style_15_700(color: AppColors.black),
        ),
        AppCommonButton(
          text: 'Create Company',
          buttonColor: AppColors.primary,
          textColor: AppColors.white,
          height: 28.h,
          textSize: 12.sp,
          borderRadius: 4.r,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          onPressed: () async {
            await showMContactCompanyDialog(context, controller);
            controller.fetchCompanies();
          },
        ),
      ],
    );
  }
  // endregion
}
// endregion
