// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// endregion

// region AppCommonMultiSelectDropdown Class
/// A standardized, reusable multi-select and single-select popup dropdown widget.
///
/// Features:
/// - Floating label with required asterisk support
/// - Search filter inside menu with clean item capitalization
/// - "Select All" option for multi-select mode
/// - Single-select mode with auto-close and checkmark indicator
/// - Compact responsive height and customizable vertical padding
class AppCommonMultiSelectDropdown<T> extends StatefulWidget {
  // region Properties
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
  final double? menuMaxHeight;
  final bool hasError;
  final bool isLoading;
  final TextStyle? selectedTextStyle;
  final Widget? customChild;

  /// Controls the dropdown box height across all modules.
  static const double _defaultVerticalPadding = 2.0;
  // endregion

  // region Constructor
  const AppCommonMultiSelectDropdown({
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
    this.menuMaxHeight,
    this.hasError = false,
    this.isLoading = false,
    this.selectedTextStyle,
    this.customChild,
  });
  // endregion

  @override
  State<AppCommonMultiSelectDropdown<T>> createState() =>
      AppCommonMultiSelectDropdownState<T>();
}
// endregion

// region Type Alias for Backward Compatibility
/// Backward-compatible alias for [AppCommonMultiSelectDropdown].
typedef MultiSelectDropdownWidget<T> = AppCommonMultiSelectDropdown<T>;
typedef MultiSelectDropdownWidgetState<T> = AppCommonMultiSelectDropdownState<T>;
// endregion

// region AppCommonMultiSelectDropdownState Class
class AppCommonMultiSelectDropdownState<T>
    extends State<AppCommonMultiSelectDropdown<T>> {
  // region Menu Interaction
  Future<void> openMenu() async {
    if (!mounted || widget.isLoading) return;
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
            label: widget.label,
            title: widget.title,
            selectedValues: widget.selectedValues,
            items: widget.items,
            onChanged: widget.onChanged,
            showSearch: widget.showSearch,
            isSingleSelect: widget.isSingleSelect,
            showSelectAll: !widget.isSingleSelect && widget.showSelectAll,
            width: size.width,
            menuMaxHeight: widget.menuMaxHeight,
          ),
        ),
      ],
    );
  }
  // endregion

  // region Build Method
  @override
  Widget build(BuildContext context) {
    final effectiveLabel = widget.label ?? widget.title;

    Widget inputChild = InputDecorator(
      decoration: InputDecoration(
        label: effectiveLabel != null
            ? RichText(
                text: TextSpan(
                  text: _capitalizeText(effectiveLabel.replaceAll('*', '')),
                  style: AppTextStyle.style_11_500(
                    color: AppColors.grey300,
                  ),
                  children: effectiveLabel.contains('*')
                      ? [
                          TextSpan(
                            text: '*',
                            style: AppTextStyle.style_11_500(
                              color: AppColors.red,
                            ),
                          ),
                        ]
                      : [],
                ),
              )
            : null,
        floatingLabelBehavior: effectiveLabel != null
            ? FloatingLabelBehavior.always
            : FloatingLabelBehavior.never,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 6.w,
          vertical: widget.height != null
              ? ((widget.height! - 18.h) / 2).clamp(2.0, 12.0)
              : AppCommonMultiSelectDropdown._defaultVerticalPadding.h,
        ),
        filled: true,
        fillColor: AppColors.aliceBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(
            color: widget.hasError ? AppColors.red : AppColors.fieldBorderColor,
            width: widget.hasError ? 1.5 : 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(
            color: widget.hasError ? AppColors.red : AppColors.fieldBorderColor,
            width: widget.hasError ? 1.5 : 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(
            color: widget.hasError ? AppColors.red : AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
      child: SizedBox(
        height: 18.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.selectedValues.isEmpty
                    ? (widget.isLoading
                        ? (widget.hint ?? 'Loading...')
                        : (widget.hint ?? 'Select'))
                    : widget.isSingleSelect
                        ? (() {
                            if (widget.items.isEmpty) {
                              return widget.hint ?? 'Select';
                            }
                            final matches = widget.items.where((item) {
                              if (item.value == widget.selectedValues.first) {
                                return true;
                              }
                              if (item.value is String || item.value is num) {
                                return item.value.toString().trim().toLowerCase() ==
                                    widget.selectedValues.first
                                        .toString()
                                        .trim()
                                        .toLowerCase();
                              }
                              return false;
                            });
                            if (matches.isEmpty) return widget.hint ?? 'Select';
                            final item = matches.first;
                            if (item.child is Text) {
                              return (item.child as Text).data ?? 'Selected';
                            }
                            return 'Selected';
                          })()
                        : (() {
                            if (widget.items.isEmpty) {
                              return '${widget.selectedValues.length} selected';
                            }
                            final matchedNames = <String>[];
                            for (final val in widget.selectedValues) {
                              final matches = widget.items.where((item) {
                                if (item.value == val) return true;
                                if (item.value is String || item.value is num) {
                                  return item.value.toString().trim().toLowerCase() ==
                                      val.toString().trim().toLowerCase();
                                }
                                return false;
                              });
                              if (matches.isNotEmpty) {
                                final item = matches.first;
                                if (item.child is Text) {
                                  final textData = (item.child as Text).data;
                                  if (textData != null && textData.isNotEmpty) {
                                    matchedNames.add(textData);
                                  }
                                }
                              }
                            }
                            if (matchedNames.isEmpty) {
                              return '${widget.selectedValues.length} selected';
                            }
                            if (matchedNames.length == widget.items.length &&
                                widget.items.length > 1) {
                              return 'All Selected (${widget.items.length})';
                            }
                            return matchedNames.join(', ');
                          })(),
                style: widget.selectedValues.isEmpty
                    ? AppTextStyle.style_12_400(
                        color: AppColors.grey300,
                      )
                    : (widget.selectedTextStyle ??
                        AppTextStyle.style_12_400(
                          color: AppColors.grey900,
                        )),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(width: 4.w),
            widget.isLoading
                ? SizedBox(
                    height: 12.r,
                    width: 12.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.grey300,
                    size: 16.r,
                  ),
          ],
        ),
      ),
    );

    if (widget.height != null) {
      inputChild = SizedBox(
        height: widget.height,
        child: inputChild,
      );
    }

    return InkWell(
      onTap: openMenu,
      child: widget.customChild ?? inputChild,
    );
  }

  String? _capitalizeText(String? text) {
    if (text == null || text.trim().isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      if (word.contains('-')) {
        return word.split('-').map((part) {
          if (part.isEmpty) return part;
          return '${part[0].toUpperCase()}${part.substring(1)}';
        }).join('-');
      }
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }
  // endregion
}
// endregion

// region _MultiSelectMenuContent Class
class _MultiSelectMenuContent<T> extends StatefulWidget {
  // region Properties
  final String? label;
  final String? title;
  final Set<T> selectedValues;
  final List<DropdownMenuItem<T>> items;
  final Function(Set<T>) onChanged;
  final bool showSearch;
  final bool isSingleSelect;
  final bool showSelectAll;
  final double width;
  final double? menuMaxHeight;
  // endregion

  // region Constructor
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
    this.menuMaxHeight,
  });
  // endregion

  @override
  State<_MultiSelectMenuContent<T>> createState() =>
      _MultiSelectMenuContentState<T>();
}
// endregion

// region _MultiSelectMenuContentState Class
class _MultiSelectMenuContentState<T>
    extends State<_MultiSelectMenuContent<T>> {
  // region State Variables
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late Set<T> _tempSelected;
  // endregion

  // region Lifecycle Methods
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
  // endregion

  // region Helpers
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

  String _cleanAndCapitalize(String text) {
    final clean = text.replaceAll('*', '').trim();
    if (clean.isEmpty) return '';
    return clean.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
  // endregion

  // region Build Method
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
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  TextField(
                    controller: _searchController,
                    style: AppTextStyle.style_12_400(color: AppColors.black),
                    decoration: InputDecoration(
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
                  if (_searchController.text.isEmpty)
                    IgnorePointer(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text.rich(
                          TextSpan(
                            text: 'Search ',
                            style: AppTextStyle.style_12_400(
                              color: AppColors.grey300,
                            ),
                            children: [
                              TextSpan(
                                text: _cleanAndCapitalize(
                                  widget.label ?? widget.title ?? '',
                                ),
                                style: AppTextStyle.style_12_700(
                                  color: AppColors.grey900,
                                ),
                              ),
                              TextSpan(
                                text: '...',
                                style: AppTextStyle.style_12_400(
                                  color: AppColors.grey300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: widget.menuMaxHeight ?? 220.h),
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
                            horizontal: 8,
                            vertical: 2,
                          ),
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
                            if (isSelected) {
                              _tempSelected.clear();
                            } else {
                              _tempSelected.clear();
                              if (value != null) {
                                _tempSelected.add(value as T);
                              }
                            }
                            final selectedSet = Set<T>.from(_tempSelected);
                            Navigator.of(context).pop();
                            widget.onChanged(selectedSet);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 3.h,
                            ),
                            color: isSelected
                                ? AppColors.secondaryOrange
                                : AppColors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: item.child is Text
                                      ? Text(
                                          (item.child as Text).data ?? '',
                                          style: isSelected
                                              ? AppTextStyle.style_12_600(
                                                  color:
                                                      AppColors.primaryOrange,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
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
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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
              child: AppCommonButton(
                text: 'Done',
                height: 30.h,
                width: double.infinity,
                borderRadius: 4.r,
                onPressed: () {
                  widget.onChanged(Set<T>.from(_tempSelected));
                  Navigator.pop(context);
                },
              ),
            ),
        ],
      ),
    );
  }
  // endregion
}
// endregion
