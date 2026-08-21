import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mfresh_ops/modules/home/controllers/home_grid_controller.dart';
import 'package:mfresh_ops/modules/home/views/widgets/sub_action_editor_sheet.dart';

class HomeGrid extends StatelessWidget {
  const HomeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeGridController());

    return Obx(() {
      final items = controller.gridItems;

      final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14.r,
        mainAxisSpacing: 8.r,
        childAspectRatio: 1.15,
      );

      Widget buildItem(BuildContext context, int index) {
        final item = items[index];
        Widget card = _buildGridCard(context, item, controller);

        if (controller.isEditMode.value) {
          card = card
              .animate(onPlay: (c) => c.repeat())
              .shake(hz: 1.5, curve: Curves.easeInOutCubic, rotation: 0.02);
        }

        return Container(key: ValueKey(item.title), child: card);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (controller.isEditMode.value) ...[
            ElevatedButton.icon(
              onPressed: () => controller.toggleEditMode(),
              icon: Icon(Icons.check, color: Colors.white, size: 20.r),
              label: Text(
                'Done Customizing',
                style: AppTextStyle.style_14_600(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.h),
              ),
            ),
            SizedBox(height: 12.h),
          ],
          GestureDetector(
            onLongPress: () {
              if (!controller.isEditMode.value) {
                controller.toggleEditMode();
              }
            },
            child: controller.isEditMode.value
                ? ReorderableGridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    onReorder: controller.onReorder,
                    gridDelegate: gridDelegate,
                    itemBuilder: buildItem,
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: gridDelegate,
                    itemBuilder: buildItem,
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildGridCard(
    BuildContext context,
    GridItemData item,
    HomeGridController controller,
  ) {
    final bool isCompact = true;
    final int totalItems = item.subActions.length;

    List<Widget> gridItems = [];
    for (int i = 0; i < item.subActions.length; i++) {
      final action = item.subActions[i];
      gridItems.add(
        _buildCompactActionBtn(
          title: action.title,
          icon: action.icon,
          route: action.route,
          arguments: action.arguments,
          isCompact: isCompact,
          isSolidIcon: action.isSolidIcon,
          isRowLayout: totalItems == 1 ? true : (totalItems == 2 ? true : (totalItems == 3 && i == 0)),
          controller: controller,
          fallbackRoute: item.route,
        ),
      );
    }

    Widget card = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFff895b),
            borderRadius: BorderRadius.circular(25.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(25.r),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.r),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 4.h,
                      horizontal: 10.w,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 14.r,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            (item.headerTitle ?? item.title).toUpperCase(),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            // overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.style_10_600(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Fading gradient line
                  Container(
                    height: 1,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 6.h,
                        horizontal: 10.w,
                      ),
                      child: gridItems.isNotEmpty
                          ? _buildSubActionsGrid(gridItems)
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (controller.isEditMode.value)
          Positioned(
            top: -4,
            right: -4,
            child: GestureDetector(
              onTap: () => SubActionEditorSheet.show(context, item, controller),
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(Icons.edit, size: 16.r, color: AppColors.black),
              ),
            ),
          ),
      ],
    );

    if (controller.isEditMode.value) {
      card = card
          .animate(onPlay: (c) => c.repeat())
          .shake(hz: 1.5, curve: Curves.easeInOutCubic, rotation: 0.02);
    }

    return Container(key: ValueKey(item.title), child: card);
  }

  Widget _buildSubActionsGrid(List<Widget> gridItems) {
    final int totalItems = gridItems.length;

    if (totalItems == 1) {
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: 35.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [gridItems[0]],
          ),
        ),
      );
    } else if (totalItems == 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [gridItems[0]],
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [gridItems[1]],
            ),
          ),
        ],
      );
    } else if (totalItems == 3) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [gridItems[0]],
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                gridItems[1],
                SizedBox(width: 8.w),
                gridItems[2],
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Row 1
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              gridItems.isNotEmpty
                  ? gridItems[0]
                  : const Expanded(child: SizedBox()),
              SizedBox(width: 8.w),
              gridItems.length > 1
                  ? gridItems[1]
                  : const Expanded(child: SizedBox()),
            ],
          ),
        ),
        // Row 2
        if (gridItems.length > 2) ...[
          SizedBox(height: 8.h),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                gridItems[2],
                SizedBox(width: 8.w),
                gridItems.length > 3
                    ? gridItems[3]
                    : const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactActionBtn({
    required String title,
    required IconData icon,
    String? route,
    Map<String, dynamic>? arguments,
    required bool isCompact,
    bool isSolidIcon = false,
    bool isRowLayout = false,
    required HomeGridController controller,
    String? fallbackRoute,
  }) {
    Widget iconWidget = isSolidIcon
        ? Container(
            padding: EdgeInsets.all((isCompact && !isRowLayout) ? 1.r : 2.r),
            decoration: const BoxDecoration(
              color: Color(0xFF4A4A4A),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: (isCompact && !isRowLayout) ? 14.r : 16.r,
            ),
          )
        : Icon(
            icon,
            color: AppColors.black,
            size: (isCompact && !isRowLayout) ? 16.r : 20.r,
          );

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            if (controller.isEditMode.value) return;
            if (route != null) {
              Get.toNamed(route, arguments: arguments);
            } else if (fallbackRoute != null) {
              Get.toNamed(fallbackRoute);
            } else {
              AppCommonToastMessage.show(
                message: '$title is coming soon....',
                type: ToastType.info,
              );
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: (isCompact && !isRowLayout) ? 2.h : 6.h,
              horizontal: 4.w,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: isRowLayout
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconWidget,
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.style_10_500(
                            color: AppColors.grey700,
                          ).copyWith(fontSize: 10.sp),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconWidget,
                      SizedBox(height: isCompact ? 1.h : 2.h),
                      Text(
                        title.split(' ').first,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.style_10_500(
                          color: AppColors.grey700,
                        ).copyWith(fontSize: isCompact ? 8.sp : 9.sp),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
