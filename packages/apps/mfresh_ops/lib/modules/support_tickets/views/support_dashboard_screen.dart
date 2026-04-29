import 'package:flutter/material.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:core/widgets/app_common_app_bar.dart';

class SupportDashboardScreen extends StatelessWidget {
  const SupportDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppCommonAppBar(
        title: Text('Support Dashboard'),
        showAppDrawer: true,
        hasBackButton: false,
      ),
      drawer: const CommonSidebar(),
      body: Center(
        child: Text(
          'Support Dashboard Coming Soon',
          style: AppTextStyle.style_16_600(color: AppColors.grey300),
        ),
      ),
    );
  }
}
