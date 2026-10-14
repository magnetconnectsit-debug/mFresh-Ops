// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
// endregion

// region AppCommonConnectedTabBar Widget
/// Clean, robust connected tab bar component with pixel-perfect rounded corners
/// that seamlessly transitions the active tab into the content card below.
class AppCommonConnectedTabBar extends StatefulWidget {
  // region Properties
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTabChanged;
  final double? height;
  final Color backgroundColor;
  final Color activeTabColor;
  final Color borderColor;
  final Color activeTextColor;
  final Color inactiveTextColor;
  final TextStyle? activeTextStyle;
  final TextStyle? inactiveTextStyle;
  final bool readOnly;
  final BorderRadius? borderRadius;
  // endregion

  // region Constructor
  const AppCommonConnectedTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTabChanged,
    this.height,
    this.backgroundColor = const Color(0xFFF1F5F9),
    this.activeTabColor = AppColors.white,
    this.borderColor = AppColors.borderColor,
    this.activeTextColor = const Color(0xFFF15A24),
    this.inactiveTextColor = const Color(0xFF64748B),
    this.activeTextStyle,
    this.inactiveTextStyle,
    this.readOnly = false,
    this.borderRadius,
  });
  // endregion

  @override
  State<AppCommonConnectedTabBar> createState() =>
      _AppCommonConnectedTabBarState();
}
// endregion

// region _AppCommonConnectedTabBarState Implementation
class _AppCommonConnectedTabBarState extends State<AppCommonConnectedTabBar> {
  // region Action Handlers
  void _handleTabTap(int index) {
    if (widget.readOnly) return;
    if (index == widget.selectedIndex) return;
    widget.onTabChanged?.call(index);
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final tabCount = widget.tabs.length;
    if (tabCount == 0) return const SizedBox.shrink();

    final effectiveHeight = widget.height ?? 32.h;
    final effectiveBorderRadius = widget.borderRadius ??
        BorderRadius.only(
          topLeft: Radius.circular(10.r),
          topRight: Radius.circular(10.r),
        );

    final selectedStyle = widget.activeTextStyle ??
        AppTextStyle.style_13_600(color: widget.activeTextColor);
    final unselectedStyle = widget.inactiveTextStyle ??
        AppTextStyle.style_13_500(color: widget.inactiveTextColor);

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: Container(
        height: effectiveHeight,
        color: widget.backgroundColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(tabCount, (index) {
            final label = widget.tabs[index];
            final isSelected = index == widget.selectedIndex;

            // Border logic:
            // - Inactive tabs have a 1px bottom border to separate from the content card.
            // - Active tab has NO bottom border so it seamlessly connects to the content below.
            // - Vertical dividers: 1px divider between active and inactive tabs, and subtle divider between inactive tabs.
            final bool hasLeftBorder = index > 0 &&
                (isSelected || widget.selectedIndex == index - 1);
            final bool hasSubtleDivider = index > 0 && !hasLeftBorder;

            return Expanded(
              child: InkWell(
                onTap: widget.readOnly ? null : () => _handleTabTap(index),
                splashColor: AppColors.transparent,
                highlightColor: AppColors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.activeTabColor
                        : widget.backgroundColor,
                    border: Border(
                      left: hasLeftBorder
                          ? BorderSide(color: widget.borderColor, width: 1)
                          : hasSubtleDivider
                              ? BorderSide(
                                  color: widget.borderColor.withValues(alpha: 0.5),
                                  width: 0.5,
                                )
                              : BorderSide.none,
                      bottom: isSelected
                          ? BorderSide.none
                          : BorderSide(color: widget.borderColor, width: 1),
                    ),
                  ),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      style: isSelected ? selectedStyle : unselectedStyle,
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
  // endregion
}
// endregion
