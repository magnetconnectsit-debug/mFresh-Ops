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
  final bool showSelectAll;
  final double? height;
  final bool hasError;
  final TextStyle? selectedTextStyle;
  final Widget? customChild;

  const MultiSelectDropdownWidget({
    super.key,
    this.label,
    this.title,
    required this.selectedValues,
    required this.items,
    required this.onChanged,
    this.hint,
    this.showSearch = true,
    this.isSingleSelect = false,
    this.showSelectAll = false,
    this.height,
    this.hasError = false,
    this.selectedTextStyle,
    this.customChild,
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

        await showMenu(
          context: context,
          color: AppColors.white,
          constraints: BoxConstraints(
            minWidth: size.width < 240.w ? 240.w : size.width,
            maxWidth: size.width < 240.w ? 240.w : size.width,
          ),
          position: RelativeRect.fromRect(
            buttonRect,
            Offset.zero & MediaQuery.of(context).size,
          ),
          items: [
            PopupMenuItem(
              enabled: false,
              padding: EdgeInsets.zero,
              child: _MultiSelectMenuContent<T>(
                label: label,
                title: title,
                selectedValues: selectedValues,
                items: items,
                onChanged: onChanged,
                showSearch: showSearch,
                isSingleSelect: isSingleSelect,
                showSelectAll: !isSingleSelect && showSelectAll,
                width: size.width,
              ),
            ),
          ],
        );
      },
      child: customChild ?? (height != null
        ? Container(
            height: height,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(
                color: hasError ? Colors.red : AppColors.borderColor,
                width: hasError ? 1.5 : 1.0,
              ),
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
                                if (items.isEmpty) return hint ?? 'Select';
                                final matches = items.where((item) {
                                  if (item.value == selectedValues.first) return true;
                                  if (item.value is String || item.value is num) {
                                    return item.value.toString().trim().toLowerCase() ==
                                        selectedValues.first.toString().trim().toLowerCase();
                                  }
                                  return false;
                                });
                                if (matches.isEmpty) return hint ?? 'Select';
                                final item = matches.first;
                                if (item.child is Text) {
                                  return (item.child as Text).data ?? 'Selected';
                                }
                                return 'Selected';
                              })()
                            : '${selectedValues.length} selected',
                    style: selectedValues.isEmpty 
                        ? AppTextStyle.style_12_400(color: AppColors.grey300).copyWith(fontSize: 11.sp)
                        : (selectedTextStyle ?? AppTextStyle.style_12_400(color: AppColors.grey900).copyWith(fontSize: 11.sp)),
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
              label: label != null
                  ? RichText(
                      text: TextSpan(
                        text: label!.replaceAll('*', ''),
                        style: AppTextStyle.style_12_400(color: AppColors.grey200),
                        children: label!.contains('*')
                            ? [
                                const TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                )
                              ]
                            : [],
                      ),
                    )
                  : null,
              floatingLabelBehavior: label != null ? FloatingLabelBehavior.always : FloatingLabelBehavior.never,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: label != null ? 4.h : 8.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : AppColors.borderColor,
                  width: hasError ? 1.5 : 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : AppColors.borderColor,
                  width: hasError ? 1.5 : 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : const Color(0xffF15A24),
                  width: 1.5,
                ),
              ),
            ),
            child: Text(
              selectedValues.isEmpty
                  ? (hint ?? 'Select')
                  : isSingleSelect
                      ? (() {
                          if (items.isEmpty) return hint ?? 'Select';
                          final matches = items.where((item) {
                            if (item.value == selectedValues.first) return true;
                            if (item.value is String || item.value is num) {
                              return item.value.toString().trim().toLowerCase() ==
                                  selectedValues.first.toString().trim().toLowerCase();
                            }
                            return false;
                          });
                          if (matches.isEmpty) return hint ?? 'Select';
                          final item = matches.first;
                          if (item.child is Text) {
                            return (item.child as Text).data ?? 'Selected';
                          }
                          return 'Selected';
                        })()
                      : '${selectedValues.length} selected',
              style: selectedValues.isEmpty 
                  ? AppTextStyle.style_12_400(color: AppColors.grey300).copyWith(fontSize: 11.sp)
                  : (selectedTextStyle ?? AppTextStyle.style_12_400(color: AppColors.grey900)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          )),
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

class _MultiSelectMenuContent<T> extends StatefulWidget {
  final String? label;
  final String? title;
  final Set<T> selectedValues;
  final List<DropdownMenuItem<T>> items;
  final Function(Set<T>) onChanged;
  final bool showSearch;
  final bool isSingleSelect;
  final bool showSelectAll;
  final double width;

  const _MultiSelectMenuContent({
    super.key,
    this.label,
    this.title,
    required this.selectedValues,
    required this.items,
    required this.onChanged,
    required this.showSearch,
    required this.isSingleSelect,
    required this.showSelectAll,
    required this.width,
  });

  @override
  State<_MultiSelectMenuContent<T>> createState() => _MultiSelectMenuContentState<T>();
}

class _MultiSelectMenuContentState<T> extends State<_MultiSelectMenuContent<T>> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late Set<T> _tempSelected;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _tempSelected = Set<T>.from(widget.selectedValues);
  }

  bool _isItemSelected(T? value) {
    if (value == null) return false;
    if (_tempSelected.contains(value)) return true;
    if (value is String || value is num) {
      return _tempSelected.any(
        (sel) =>
            sel != null &&
            sel.toString().trim().toLowerCase() ==
                value.toString().trim().toLowerCase(),
      );
    }
    return false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<T>> displayedItems = widget.items;
    if (widget.showSearch && _searchController.text.isNotEmpty) {
      displayedItems = widget.items.where((item) {
        final text = item.child is Text
            ? (item.child as Text).data ?? ''
            : item.child.toString();
        return text.toLowerCase().contains(
          _searchController.text.toLowerCase(),
        );
      }).toList();
    }

    final allItemValues = widget.items
        .map((e) => e.value)
        .where((val) => val != null)
        .cast<T>()
        .toSet();
    final bool isAllSelected =
        allItemValues.isNotEmpty && _tempSelected.containsAll(allItemValues);

    return Container(
      color: AppColors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showSearch)
            Padding(
              padding: EdgeInsets.all(4.r),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search ${(widget.label ?? widget.title ?? '').toLowerCase()}...',
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
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.showSelectAll &&
                        !widget.isSingleSelect &&
                        widget.items.isNotEmpty) ...[
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (isAllSelected) {
                              _tempSelected.removeAll(allItemValues);
                            } else {
                              _tempSelected.addAll(allItemValues);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: Checkbox(
                                  value: isAllSelected,
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        _tempSelected.addAll(allItemValues);
                                      } else {
                                        _tempSelected.removeAll(allItemValues);
                                      }
                                    });
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'Select All',
                                  style: AppTextStyle.style_12_600(
                                    color: AppColors.grey900,
                                  ).copyWith(fontSize: 13.sp),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1, thickness: 1),
                    ],
                    ...displayedItems.map((item) {
                    final value = item.value;
                    final isSelected = _isItemSelected(value);
                    if (widget.isSingleSelect) {
                      return InkWell(
                        onTap: () {
                          _tempSelected.clear();
                          if (value != null) {
                            _tempSelected.add(value as T);
                          }
                          final selectedSet = Set<T>.from(_tempSelected);
                          Navigator.of(context).pop();
                          widget.onChanged(selectedSet);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          color: isSelected
                              ? const Color(0xFFFFF3E0)
                              : Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: item.child is Text
                                    ? Text(
                                        (item.child as Text).data ?? '',
                                        style: isSelected
                                            ? AppTextStyle.style_12_600(
                                                color: AppColors.primaryOrange,
                                              ).copyWith(fontSize: 13.sp)
                                            : AppTextStyle.style_12_400(
                                                color: AppColors.grey900,
                                              ).copyWith(fontSize: 13.sp),
                                      )
                                    : item.child,
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primaryOrange,
                                  size: 16.r,
                                ),
                            ],
                          ),
                        ),
                      );
                    }
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (_tempSelected.contains(value)) {
                            _tempSelected.remove(value);
                          } else {
                            _tempSelected.add(value as T);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: Checkbox(
                                value: _tempSelected.contains(value),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _tempSelected.add(value as T);
                                    } else {
                                      _tempSelected.remove(value);
                                    }
                                  });
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: item.child is Text
                                  ? Text(
                                      (item.child as Text).data ?? '',
                                      style: AppTextStyle.style_12_400(
                                        color: AppColors.grey900,
                                      ).copyWith(fontSize: 13.sp),
                                    )
                                  : item.child,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        if (!widget.isSingleSelect)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF15A24),
                  minimumSize: Size(double.infinity, 30.h),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                onPressed: () {
                  widget.onChanged(Set<T>.from(_tempSelected));
                  Navigator.pop(context);
                },
                child: Text(
                  'Done',
                  style: AppTextStyle.style_12_500(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
