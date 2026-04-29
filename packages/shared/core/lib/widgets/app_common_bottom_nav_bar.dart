// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// endregion

// region Data Model
class AppBottomNavItem {
  final IconData icon;
  final String label;

  AppBottomNavItem({required this.icon, required this.label});
}
// endregion

// region AppCommonBottomNavBar
class AppCommonBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<AppBottomNavItem> items;
  final Function(int) onTap;

  const AppCommonBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Height configuration
    final double barHeight = 50.h;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: barHeight + bottomPadding,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          return _NavBarItem(
            icon: items[index].icon,
            label: items[index].label,
            isSelected: currentIndex == index,
            onTap: () => onTap(index),
          );
        }),
      ),
    );
  }
}
// endregion

// region Internal Item Widget
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: isSelected ? -15.h : 6.h,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isSelected ? 42.h : 24.h,
                  height: isSelected ? 42.h : 24.h,
                  padding: EdgeInsets.all(isSelected ? 10.r : 0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : AppColors.transparent,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    icon,
                    size: isSelected ? 26.sp : 24.sp,
                    color: isSelected ? AppColors.white : AppColors.grey200,
                  ),
                ),
              ),

              // Animated Label (Positioned at a consistent bottom)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: 6.h, // Fixed bottom for better alignment
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: isSelected
                      ? AppTextStyle.style_11_600(color: AppColors.primary)
                      : AppTextStyle.style_11_500(color: AppColors.grey100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// endregion
