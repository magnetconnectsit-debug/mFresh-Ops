import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/home/controllers/home_grid_controller.dart';

class SubActionEditorSheet extends StatefulWidget {
  final GridItemData item;
  final HomeGridController controller;

  const SubActionEditorSheet({
    super.key,
    required this.item,
    required this.controller,
  });

  static void show(BuildContext context, GridItemData item, HomeGridController controller) {
    Get.bottomSheet(
      SubActionEditorSheet(item: item, controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
    );
  }

  @override
  State<SubActionEditorSheet> createState() => _SubActionEditorSheetState();
}

class _SubActionEditorSheetState extends State<SubActionEditorSheet> {
  late List<GridSubAction> availableActions;
  late List<GridSubAction> selectedActions;

  @override
  void initState() {
    super.initState();
    availableActions = widget.controller.getAvailableSubActionsFor(widget.item.title);
    selectedActions = List.from(widget.item.subActions);
  }

  void _toggleAction(GridSubAction action, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (selectedActions.length < 3) {
          selectedActions.add(action);
        } else {
          Get.snackbar(
            'Limit Reached',
            'You can only have up to 4 items per card (including the title).',
            snackPosition: SnackPosition.BOTTOM,
            margin: EdgeInsets.all(16.r),
          );
        }
      } else {
        selectedActions.removeWhere((a) => a.title == action.title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customize ${widget.item.title}',
                style: AppTextStyle.style_16_700(color: AppColors.black),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'Select up to 3 actions. Drag selected actions to reorder them.',
            style: AppTextStyle.style_12_400(color: AppColors.grey700),
          ),
          SizedBox(height: 20.h),
          
          if (selectedActions.isNotEmpty) ...[
            Text(
              'Selected Actions',
              style: AppTextStyle.style_14_600(color: AppColors.black),
            ),
            SizedBox(height: 10.h),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = selectedActions.removeAt(oldIndex);
                    selectedActions.insert(newIndex, item);
                  });
                },
                children: [
                  for (final action in selectedActions)
                    ListTile(
                      key: ValueKey(action.title),
                      leading: Icon(action.icon, color: AppColors.primaryOrange),
                      title: Text(
                        action.title,
                        style: AppTextStyle.style_14_500(color: AppColors.black),
                      ),
                      trailing: const Icon(Icons.drag_handle, color: Colors.grey),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],

          Text(
            'Available Actions',
            style: AppTextStyle.style_14_600(color: AppColors.black),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: availableActions.map((action) {
              final isSelected = selectedActions.any((a) => a.title == action.title);
              return FilterChip(
                label: Text(action.title),
                selected: isSelected,
                selectedColor: AppColors.primaryOrange.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primaryOrange,
                onSelected: (val) => _toggleAction(action, val),
              );
            }).toList(),
          ),
          
          SizedBox(height: 30.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () {
                widget.controller.updateSubActionsFor(widget.item.title, selectedActions);
                Get.back();
              },
              child: Text(
                'Save Changes',
                style: AppTextStyle.style_14_600(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
