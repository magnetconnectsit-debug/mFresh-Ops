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
        
        return Container(
          key: ValueKey(item.title),
          child: card,
        );
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
    final bool showWideTopPill = item.subActions.length < 3;
    final bool isCompact = item.subActions.length > 2 || !showWideTopPill;
    
    List<Widget> gridItems = [];
    if (!showWideTopPill) {
      gridItems.add(_buildCompactActionBtn(
        title: item.title,
        icon: item.icon,
        route: item.route,
        isCompact: isCompact,
        controller: controller,
      ));
    }
    for (int i = 0; i < item.subActions.length; i++) {
      final action = item.subActions[i];
      gridItems.add(_buildCompactActionBtn(
        title: action.title,
        icon: action.icon,
        route: action.route,
        arguments: action.arguments,
        isCompact: isCompact,
        isSolidIcon: action.isSolidIcon,
        controller: controller,
        fallbackRoute: item.route,
      ));
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
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                child: Column(
                  mainAxisAlignment: showWideTopPill ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showWideTopPill)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () {
                            if (controller.isEditMode.value) return;
                            if (item.route != null) {
                              Get.toNamed(item.route!);
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: 12.h,
                              horizontal: 10.w,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBEBEB),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                item.title,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: AppTextStyle.style_14_600(
                                  color: AppColors.black,
                                ).copyWith(fontSize: 13.5.sp),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (gridItems.isNotEmpty)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: showWideTopPill ? 8.h : 0),
                          child: _buildSubActionsGrid(gridItems),
                        ),
                      ),
                  ],
                ),
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
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: 18.r,
                  color: AppColors.primaryOrange,
                ),
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
    
    return Container(
      key: ValueKey(item.title),
      child: card,
    );
  }

  Widget _buildSubActionsGrid(List<Widget> gridItems) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Row 1
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              gridItems.isNotEmpty ? gridItems[0] : const Expanded(child: SizedBox()),
              SizedBox(width: 8.w),
              gridItems.length > 1 ? gridItems[1] : const Expanded(child: SizedBox()),
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
                gridItems.length > 3 ? gridItems[3] : const Expanded(child: SizedBox()),
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
    required HomeGridController controller,
    String? fallbackRoute,
  }) {
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
              vertical: isCompact ? 2.h : 6.h,
              horizontal: 4.w,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isSolidIcon
                    ? Container(
                        padding: EdgeInsets.all(isCompact ? 1.r : 2.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4A4A4A),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: isCompact ? 14.r : 16.r,
                        ),
                      )
                    : Icon(
                        icon,
                        color: AppColors.black,
                        size: isCompact ? 16.r : 20.r,
                      ),
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
