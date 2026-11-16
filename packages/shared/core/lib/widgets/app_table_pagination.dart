import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';

class AppTablePagination extends StatelessWidget {
  final int startItem;
  final int endItem;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final String itemUnitName;

  const AppTablePagination({
    super.key,
    required this.startItem,
    required this.endItem,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.onPreviousPage,
    this.onNextPage,
    this.itemUnitName = 'entries',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 450;

        Widget paginationButtons = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Previous Page Button
              _buildNavButton(
                icon: Icons.chevron_left,
                isDisabled: currentPage <= 1,
                onTap: onPreviousPage ??
                    (currentPage > 1 ? () => onPageChanged(currentPage - 1) : null),
              ),
              SizedBox(width: 4.w),
              // Page Numbers
              ..._buildPageItems(),
              // Next Page Button
              _buildNavButton(
                icon: Icons.chevron_right,
                isDisabled: totalPages <= 0 || currentPage >= totalPages,
                onTap: onNextPage ??
                    (currentPage < totalPages
                        ? () => onPageChanged(currentPage + 1)
                        : null),
              ),
            ],
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Showing $startItem to $endItem of $totalItems $itemUnitName',
                style: AppTextStyle.style_12_400(
                  color: AppColors.grey700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Center(child: paginationButtons),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left text: "Showing X to Y of Z entries"
            Flexible(
              child: Text(
                'Showing $startItem to $endItem of $totalItems $itemUnitName',
                style: AppTextStyle.style_12_400(
                  color: AppColors.grey700,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(width: 8.w),
            // Right side: Pagination buttons
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: paginationButtons,
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildPageItems() {
    final pageCount = totalPages <= 0 ? 1 : totalPages;
    List<Widget> buttons = [];

    if (pageCount <= 7) {
      for (int i = 1; i <= pageCount; i++) {
        buttons.add(_buildPageBtn(i));
      }
    } else {
      buttons.add(_buildPageBtn(1));

      if (currentPage > 3) {
        buttons.add(_buildEllipsis());
      }

      int start = (currentPage - 1).clamp(2, pageCount - 1);
      int end = (currentPage + 1).clamp(2, pageCount - 1);

      if (currentPage <= 3) {
        start = 2;
        end = 4;
      } else if (currentPage >= pageCount - 2) {
        start = pageCount - 3;
        end = pageCount - 1;
      }

      for (int i = start; i <= end; i++) {
        buttons.add(_buildPageBtn(i));
      }

      if (currentPage < pageCount - 2) {
        buttons.add(_buildEllipsis());
      }

      buttons.add(_buildPageBtn(pageCount));
    }

    return buttons;
  }

  Widget _buildPageBtn(int page) {
    final bool isActive = (page == currentPage);
    return Padding(
      padding: EdgeInsets.only(right: 4.w),
      child: _buildPageNumberButton(
        page: page,
        isActive: isActive,
        onTap: () => onPageChanged(page),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Padding(
      padding: EdgeInsets.only(right: 4.w),
      child: Container(
        width: 24.w,
        height: 30.h,
        alignment: Alignment.center,
        child: Text(
          '...',
          style: AppTextStyle.style_12_500(color: AppColors.grey600),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool isDisabled,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          width: 30.w,
          height: 30.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDisabled ? AppColors.grey100 : AppColors.white,
            border: Border.all(
              color: isDisabled ? AppColors.grey200 : AppColors.grey300,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(
            icon,
            size: 18.r,
            color: isDisabled ? AppColors.grey400 : AppColors.grey700,
          ),
        ),
      ),
    );
  }

  Widget _buildPageNumberButton({
    required int page,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          constraints: BoxConstraints(minWidth: 30.w),
          height: 30.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [
                      Color(0xFF0D25B9),
                      Color(0xFF071987),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: isActive ? null : AppColors.white,
            border: Border.all(
              color: isActive ? AppColors.blue : AppColors.grey300,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6.r),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.blue.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            '$page',
            style: isActive
                ? AppTextStyle.style_12_600(color: AppColors.white)
                : AppTextStyle.style_12_500(color: AppColors.grey800),
          ),
        ),
      ),
    );
  }
}
