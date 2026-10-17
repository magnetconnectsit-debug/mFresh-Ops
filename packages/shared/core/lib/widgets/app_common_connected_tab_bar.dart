// region Imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
// endregion

// region AppCommonConnectedTabBar Widget
/// A modern, high-performance connected tab bar and segmented tab switch component.
/// Features a fluid sliding active indicator with cubic physics, seamless connected card
/// integration, interactive hover effects, smart count badge pills, and optional pill mode.
class AppCommonConnectedTabBar extends StatefulWidget {
  // region Properties
  final List<String> tabs;
  final List<IconData>? icons;
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
  final bool isPillStyle;
  // endregion

  // region Constructor
  const AppCommonConnectedTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.icons,
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
    this.isPillStyle = false,
  });
  // endregion

  @override
  State<AppCommonConnectedTabBar> createState() =>
      _AppCommonConnectedTabBarState();
}
// endregion

// region _AppCommonConnectedTabBarState Implementation
class _AppCommonConnectedTabBarState extends State<AppCommonConnectedTabBar> {
  // region State Variables
  int? _hoveredIndex;
  // endregion

  // region Action Handlers & Helpers
  void _handleTabTap(int index) {
    if (widget.readOnly) return;
    if (index == widget.selectedIndex) return;
    HapticFeedback.selectionClick();
    widget.onTabChanged?.call(index);
  }

  BorderRadius _getTabBorderRadius({
    required int index,
    required int totalCount,
    required BorderRadius outerRadius,
  }) {
    if (widget.isPillStyle) {
      return BorderRadius.circular(6.r);
    }
    // Connected mode: smooth rounding on outer boundary tabs
    return BorderRadius.only(
      topLeft: index == 0 ? outerRadius.topLeft : Radius.zero,
      topRight: index == totalCount - 1 ? outerRadius.topRight : Radius.zero,
      bottomLeft: Radius.zero,
      bottomRight: Radius.zero,
    );
  }

  Widget _buildTabContent({
    required String label,
    required bool isSelected,
    required bool isHovered,
    required TextStyle selectedStyle,
    required TextStyle unselectedStyle,
    IconData? icon,
  }) {
    final titleColor = isSelected
        ? (selectedStyle.color ?? widget.activeTextColor)
        : (isHovered
            ? widget.activeTextColor.withValues(alpha: 0.75)
            : (unselectedStyle.color ?? widget.inactiveTextColor));

    // Check if label has format "Title (Count)" e.g. "Active (12)"
    final match = RegExp(r'^(.*?)\s*\((.*?)\)$').firstMatch(label.trim());

    if (match != null) {
      final title = match.group(1)?.trim() ?? label;
      final count = match.group(2)?.trim() ?? '';

      final badgeBgColor = isSelected
          ? widget.activeTextColor.withValues(alpha: 0.12)
          : const Color(0xFFE2E8F0);

      final badgeTextColor = isSelected
          ? widget.activeTextColor
          : (unselectedStyle.color ?? widget.inactiveTextColor);

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14.r, color: titleColor),
            SizedBox(width: 5.w),
          ],
          Flexible(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: (isSelected ? selectedStyle : unselectedStyle).copyWith(
                color: titleColor,
              ),
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          if (count.isNotEmpty) ...[
            SizedBox(width: 6.w),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: 5.w,
                vertical: (widget.height != null && widget.height! < 32.h)
                    ? 1.h
                    : 1.5.h,
              ),
              decoration: BoxDecoration(
                color: badgeBgColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                count,
                style: (widget.height != null && widget.height! < 32.h)
                    ? AppTextStyle.style_10_600(color: badgeTextColor)
                    : AppTextStyle.style_11_600(color: badgeTextColor),
              ),
            ),
          ],
        ],
      );
    }

    // Default clean single label
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14.r, color: titleColor),
          SizedBox(width: 5.w),
        ],
        Flexible(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            style: isSelected
                ? selectedStyle
                : (isHovered
                    ? unselectedStyle.copyWith(
                        color: (selectedStyle.color ?? widget.activeTextColor)
                            .withValues(alpha: 0.75),
                      )
                    : unselectedStyle),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final tabCount = widget.tabs.length;
    if (tabCount == 0) return const SizedBox.shrink();

    final effectiveHeight = widget.height ?? 34.h;
    final effectiveBorderRadius = widget.borderRadius ??
        BorderRadius.only(
          topLeft: Radius.circular(8.r),
          topRight: Radius.circular(8.r),
        );

    final selectedStyle = widget.activeTextStyle ??
        AppTextStyle.style_13_600(color: widget.activeTextColor);
    final unselectedStyle = widget.inactiveTextStyle ??
        AppTextStyle.style_13_500(color: widget.inactiveTextColor);

    final safeSelectedIndex = widget.selectedIndex.clamp(0, tabCount - 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final tabWidth = totalWidth / tabCount;

        return ClipRRect(
          borderRadius: effectiveBorderRadius,
          child: Container(
            height: effectiveHeight,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              border: widget.isPillStyle
                  ? Border.all(color: widget.borderColor, width: 1)
                  : Border(
                      bottom: BorderSide(color: widget.borderColor, width: 1),
                    ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── 1. SUBTLE INACTIVE TAB DIVIDERS ──
                if (!widget.isPillStyle)
                  Positioned.fill(
                    child: Row(
                      children: List.generate(tabCount, (i) {
                        return Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                right: i < tabCount - 1
                                    ? BorderSide(
                                        color: widget.borderColor.withValues(alpha: 0.45),
                                        width: 0.5,
                                      )
                                    : BorderSide.none,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                // ── 2. FLUID SLIDING ACTIVE TAB INDICATOR ──
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOutCubic,
                  left: safeSelectedIndex * tabWidth + (widget.isPillStyle ? 2.w : 0),
                  top: widget.isPillStyle ? 2.h : 0,
                  width: tabWidth - (widget.isPillStyle ? 4.w : 0),
                  height: widget.isPillStyle
                      ? (effectiveHeight - 4.h)
                      : (effectiveHeight + 1.2), // Overlays bottom line for seamless card connection
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: widget.activeTabColor,
                      borderRadius: _getTabBorderRadius(
                        index: safeSelectedIndex,
                        totalCount: tabCount,
                        outerRadius: effectiveBorderRadius,
                      ),
                      border: widget.isPillStyle
                          ? Border.all(
                              color: widget.borderColor.withValues(alpha: 0.3),
                              width: 0.5,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: widget.isPillStyle ? 0.08 : 0.04,
                          ),
                          blurRadius: widget.isPillStyle ? 4 : 3,
                          offset: widget.isPillStyle
                              ? const Offset(0, 1.5)
                              : const Offset(0, -1),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── 3. INTERACTIVE TAB FOREGROUND & LABELS ──
                Positioned.fill(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(tabCount, (index) {
                      final label = widget.tabs[index];
                      final isSelected = index == safeSelectedIndex;
                      final isHovered = _hoveredIndex == index && !isSelected;
                      final icon = (widget.icons != null &&
                              widget.icons!.length > index)
                          ? widget.icons![index]
                          : null;

                      return Expanded(
                        child: MouseRegion(
                          cursor: widget.readOnly
                              ? SystemMouseCursors.basic
                              : SystemMouseCursors.click,
                          onEnter: (_) {
                            if (!widget.readOnly) {
                              setState(() => _hoveredIndex = index);
                            }
                          },
                          onExit: (_) {
                            if (!widget.readOnly) {
                              setState(() => _hoveredIndex = null);
                            }
                          },
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.readOnly
                                ? null
                                : () => _handleTabTap(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: isHovered
                                    ? Colors.black.withValues(alpha: 0.03)
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                                  child: _buildTabContent(
                                    label: label,
                                    isSelected: isSelected,
                                    isHovered: isHovered,
                                    selectedStyle: selectedStyle,
                                    unselectedStyle: unselectedStyle,
                                    icon: icon,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // endregion
}
// endregion

// region Typedefs
/// Alias for [AppCommonConnectedTabBar] providing alternative naming for general tab switching.
typedef AppCommonTabSwitch = AppCommonConnectedTabBar;
// endregion
