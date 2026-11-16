// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// endregion

// region AppCommonSearchBar Class
class AppCommonSearchBar extends StatefulWidget {
  // region Properties
  final String? hintText;
  final String? label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Color? borderColor;
  final Color? fillColor;
  final bool autofocus;
  final VoidCallback? onClose;
  final FocusNode? focusNode;
  final double? width;
  final double? height;

  // endregion

  // region Constructor
  const AppCommonSearchBar({
    super.key,
    this.hintText,
    this.label,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.borderColor,
    this.fillColor,
    this.autofocus = false,
    this.onClose,
    this.focusNode,
    this.width,
    this.height,
  });

  @override
  State<AppCommonSearchBar> createState() => _AppCommonSearchBarState();
}

class _AppCommonSearchBarState extends State<AppCommonSearchBar> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  // region Build Method
  @override
  Widget build(BuildContext context) {
    final searchInput = InputDecorator(
      isFocused: _isFocused,
      decoration: InputDecoration(
        label: RichText(
          text: TextSpan(
            text: widget.label ?? "Global Search",
            style: AppTextStyle.style_11_500(
              color: AppColors.grey700,
            ),
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 6.w,
          vertical: 3.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(
            color: widget.borderColor ?? AppColors.grey400,
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(
            color: widget.borderColor ?? AppColors.grey400,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(
            color: AppColors.black,
            width: 1.8,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              controller: widget.controller,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: AppTextStyle.style_12_500(
                color: AppColors.black,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: widget.hintText ?? 'Select',
                hintStyle: AppTextStyle.style_12_400(
                  color: AppColors.grey300,
                ).copyWith(fontSize: 11.sp),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          widget.controller != null && widget.controller!.text.isNotEmpty
              ? InkWell(
            onTap: () {
              widget.controller?.clear();
              widget.onChanged?.call('');
              widget.onClose?.call();
            },
            child: Icon(
              Icons.close,
              color: AppColors.black,
              size: 16.r,
            ),
          )
              : Icon(
            Icons.search_rounded,
            color: AppColors.grey700,
            size: 16.r,
          ),
        ],
      ),
    );

    if (widget.width != null) {
      return SizedBox(width: widget.width, child: searchInput);
    }
    return searchInput;
  }

// endregion
}
// endregion
