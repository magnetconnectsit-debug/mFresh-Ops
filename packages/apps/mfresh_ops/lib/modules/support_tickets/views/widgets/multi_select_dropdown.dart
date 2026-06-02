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
  final bool hasError;
  final TextStyle? selectedTextStyle;

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
    this.height,
    this.hasError = false,
    this.selectedTextStyle,
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
                width: size.width,
              ),
            ),
          ],
        );
      },
      child: height != null
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
                                final matches = items.where(
                                  (item) => item.value == selectedValues.first,
                                );
                                if (matches.isEmpty) return hint ?? 'Select';
                                final item = matches.first;
                                if (item.child is Text) {
                                  return (item.child as Text).data ?? 'Selected';
                                }
                                return 'Selected';
                              })()
                            : '${selectedValues.length} selected',
                    style: selectedTextStyle ?? AppTextStyle.style_12_400(color: AppColors.grey900).copyWith(fontSize: 11.sp),
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
                          final matches = items.where(
                            (item) => item.value == selectedValues.first,
                          );
                          if (matches.isEmpty) return hint ?? 'Select';
                          final item = matches.first;
                          if (item.child is Text) {
                            return (item.child as Text).data ?? 'Selected';
                          }
                          return 'Selected';
                        })()
                      : '${selectedValues.length} selected',
              style: selectedTextStyle ?? AppTextStyle.style_12_400(color: AppColors.grey900),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
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

class _MultiSelectMenuContent<T> extends StatefulWidget {
  final String? label;
  final String? title;
  final Set<T> selectedValues;
  final List<DropdownMenuItem<T>> items;
  final Function(Set<T>) onChanged;
  final bool showSearch;
  final bool isSingleSelect;
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

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      constraints: BoxConstraints(
        minWidth: widget.width,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
        maxHeight: 300.h + MediaQuery.of(context).viewInsets.bottom,
      ),
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
                  children: displayedItems.map((item) {
                    final value = item.value;
                    if (widget.isSingleSelect) {
                      return ListTile(
                        title: item.child,
                        selected: _tempSelected.contains(value),
                        onTap: () {
                          if (_tempSelected.contains(value)) {
                            _tempSelected.remove(value);
                          } else {
                            _tempSelected.clear();
                            _tempSelected.add(value as T);
                          }
                          widget.onChanged(Set<T>.from(_tempSelected));
                          Navigator.pop(context);
                        },
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      );
                    }
                    return CheckboxListTile(
                      title: item.child,
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
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          if (!widget.isSingleSelect)
            Padding(
              padding: EdgeInsets.all(8.r),
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
