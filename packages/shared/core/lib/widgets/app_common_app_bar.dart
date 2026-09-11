import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppCommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppCommonAppBar({
    super.key,
    this.title,
    this.actions,
    this.hasBackButton = true,
    this.showAppDrawer = false,
    this.backgroundColor = AppColors.white,
    this.iconColor = AppColors.black,
    this.elevation = 0,
    this.onBackButtonPressed,
    this.toolbarHeight,
    this.titleSpacing,
    this.topHeader,
  });

  final Widget? title;
  final List<Widget>? actions;
  final bool hasBackButton;
  final bool showAppDrawer;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? elevation;
  final VoidCallback? onBackButtonPressed;
  final double? toolbarHeight;
  final double? titleSpacing;
  final PreferredSizeWidget? topHeader;

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: title,
      primary: topHeader == null,
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: false,
      scrolledUnderElevation: 0,
      toolbarHeight: toolbarHeight ?? 35.h,
      titleSpacing: titleSpacing,
      titleTextStyle:
          AppTextStyle.style_18_600(color: iconColor ?? AppColors.black),
      leading: hasBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios, size: 18.sp, color: iconColor),
              onPressed:
                  onBackButtonPressed ?? () => Navigator.of(context).pop(),
            )
          : (showAppDrawer && topHeader == null
              ? Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.menu, color: iconColor),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              : null),
      actions: actions,
      automaticallyImplyLeading: false,
    );

    if (topHeader == null) {
      return appBar;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: AppColors.white,
          child: SafeArea(
            bottom: false,
            child: topHeader!,
          ),
        ),
        appBar,
      ],
    );
  }

  @override
  Size get preferredSize {
    final topHeight = topHeader?.preferredSize.height ?? 0.0;
    return Size.fromHeight((toolbarHeight ?? 35.h) + topHeight);
  }
}










