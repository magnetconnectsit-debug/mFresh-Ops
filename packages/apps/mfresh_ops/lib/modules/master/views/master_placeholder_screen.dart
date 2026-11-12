// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
// endregion

// region Generic Master Placeholder Screen
class MasterPlaceholderScreen extends StatelessWidget {
  final String title;

  const MasterPlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          title,
          style: AppTextStyle.style_16_700(color: AppColors.black),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Container(
          color: AppColors.white,
          alignment: Alignment.center,
          child: Text(
            '$title screen coming soon',
            style: AppTextStyle.style_13_400(color: AppColors.grey400),
          ),
        ),
      ),
    );
  }
}
// endregion

