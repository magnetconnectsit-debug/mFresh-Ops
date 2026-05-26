import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MultiSelectDropdownWidget<T> extends StatelessWidget {
  final String? label;
  final String? title;
  final Set<T> selectedValues;
  final List<DropdownMenuItem<T>> items;
  final Function(Set<T>) onChanged;
  final String? hint;
  final bool showSearch;
  final bool isSingleSelect;
  final double? height;

  const MultiSelectDropdownWidget({
    super.key,
    this.label,
    this.title,
    required this.selectedValues,
    required this.items,
    required this.onChanged,
    this.hint,
    this.showSearch = false,
    this.isSingleSelect = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget dropdownContent = InkWell(
      onTap: () async {
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        final Size size = renderBox.size;
        final Rect buttonRect = offset & size;

        final searchController = TextEditingController();
        final scrollController = ScrollController();
        Set<T> tempSelected = Set<T>.from(selectedValues);

        await showMenu(
          context: context,
          color: AppColors.white,
          position: RelativeRect.fromRect(
            buttonRect,
            Offset.zero & MediaQuery.of(context).size,
          ),
          items: [
            PopupMenuItem(
              enabled: false,
              padding: EdgeInsets.zero,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: size.width,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: 300.h,
                ),
                color: AppColors.white,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    List<DropdownMenuItem<T>> displayedItems = items;
                    if (showSearch && searchController.text.isNotEmpty) {
                      displayedItems = items.where((item) {
                        final text = item.child is Text
                            ? (item.child as Text).data ?? ''
                            : item.child.toString();
                        return text.toLowerCase().contains(
                          searchController.text.toLowerCase(),
                        );
                      }).toList();
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showSearch)
                          Padding(
                            padding: EdgeInsets.all(4.r),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Search ${(label ?? title ?? '').toLowerCase()}...',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 150.h),
                          child: Scrollbar(
                            controller: scrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: displayedItems.map((item) {
                                  final value = item.value;
                                  if (isSingleSelect) {
                                    return ListTile(
                                      title: item.child,
                                      selected: tempSelected.contains(value),
                                      onTap: () {
                                        setState(() {
                                          tempSelected.clear();
                                          tempSelected.add(value as T);
                                        });
                                        onChanged(Set<T>.from(tempSelected));
                                        Navigator.pop(context);
                                      },
                                      dense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                                    );
                                  }
                                  return CheckboxListTile(
                                    title: item.child,
                                    value: tempSelected.contains(value),
                                    onChanged: (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          tempSelected.add(value as T);
                                        } else {
                                          tempSelected.remove(value);
                                        }
                                      });
                                      onChanged(Set<T>.from(tempSelected));
                                    },
                                    dense: true,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        );

        searchController.dispose();
        scrollController.dispose();
      },
      child: height != null
        ? Container(
            height: height,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedValues.isEmpty
                        ? (hint ?? 'Select')
                        : isSingleSelect
                            ? (() {
                                final item = items.firstWhere(
                                  (item) => item.value == selectedValues.first,
                                  orElse: () => items.first,
                                );
                                if (item.child is Text) {
                                  return (item.child as Text).data ?? 'Selected';
                                }
                                return 'Selected';
                              })()
                            : '${selectedValues.length} selected',
                    style: AppTextStyle.style_12_400(color: AppColors.grey900).copyWith(fontSize: 11.sp),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.grey300,
                  size: 16.r,
                ),
              ],
            ),
          )
        : InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              floatingLabelBehavior: label != null ? FloatingLabelBehavior.always : FloatingLabelBehavior.never,
              labelStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: label != null ? 4.h : 8.h),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.r), borderSide: const BorderSide(color: AppColors.borderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.r), borderSide: const BorderSide(color: AppColors.borderColor)),
            ),
            child: Text(
              selectedValues.isEmpty
                  ? (hint ?? 'Select')
                  : isSingleSelect
                      ? (() {
                          final item = items.firstWhere(
                            (item) => item.value == selectedValues.first,
                            orElse: () => items.first,
                          );
                          if (item.child is Text) {
                            return (item.child as Text).data ?? 'Selected';
                          }
                          return 'Selected';
                        })()
                      : '${selectedValues.length} selected',
              style: AppTextStyle.style_12_400(color: AppColors.grey900),
            ),
          ),
    );

    if (title != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(
              title!,
              style: AppTextStyle.style_12_500(color: AppColors.black300),
            ),
          ),
          dropdownContent,
        ],
      );
    }
    return dropdownContent;
  }
}
