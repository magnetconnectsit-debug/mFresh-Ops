// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// endregion

// region AppCommonDateField Class
/// A standardized, reusable date picker field compliant with Magnet Connects design standards.
///
/// Wraps [AppCommonTextField] with a tap-to-pick modal [showDatePicker], automatic
/// date formatting, clear icon handling, and validation.
class AppCommonDateField extends StatefulWidget {
  // region Properties
  /// The label displayed on the text field or floating label.
  final String? labelText;

  /// Placeholder hint text when empty (defaults to 'Select date').
  final String hintText;

  /// Current selected date.
  final DateTime? selectedDate;

  /// Callback when a new date is selected by the user.
  final ValueChanged<DateTime>? onDateSelected;

  /// Optional external controller. If omitted, an internal controller is maintained.
  final TextEditingController? controller;

  /// Earliest selectable date in the picker (defaults to 2000-01-01).
  final DateTime? firstDate;

  /// Latest selectable date in the picker (defaults to 2100-12-31).
  final DateTime? lastDate;

  /// Custom date formatter function. Defaults to `YYYY-MM-DD`.
  final String Function(DateTime)? dateFormatter;

  /// Whether the field is mandatory (displays required asterisk).
  final bool isRequired;

  /// Whether the field is enabled for user interaction.
  final bool enabled;

  /// Whether the field is read-only (prevents date picker modal from opening).
  final bool readOnly;

  /// Background fill color.
  final Color? fillColor;

  /// Optional custom prefix widget or icon.
  final Widget? prefixWidget;

  /// Optional custom suffix widget or icon. Defaults to calendar outline icon.
  final Widget? suffixIcon;

  /// Optional focus node.
  final FocusNode? focusNode;

  /// Optional form validator.
  final FormFieldValidator<String>? validator;

  /// Picker dialog help text (title in date picker modal).
  final String? helpText;

  /// Date picker display mode (calendar or input).
  final DatePickerEntryMode initialEntryMode;

  /// Custom width constraint.
  final double? width;

  /// Custom height constraint.
  final double? height;
  // endregion

  // region Constructor
  const AppCommonDateField({
    super.key,
    this.labelText,
    this.hintText = 'Select date',
    this.selectedDate,
    this.onDateSelected,
    this.controller,
    this.firstDate,
    this.lastDate,
    this.dateFormatter,
    this.isRequired = false,
    this.enabled = true,
    this.readOnly = false,
    this.fillColor,
    this.prefixWidget,
    this.suffixIcon,
    this.focusNode,
    this.validator,
    this.helpText,
    this.initialEntryMode = DatePickerEntryMode.calendar,
    this.width,
    this.height,
  });
  // endregion

  @override
  State<AppCommonDateField> createState() => AppCommonDateFieldState();
}
// endregion

// region AppCommonDateFieldState Class
class AppCommonDateFieldState extends State<AppCommonDateField> {
  // region State Variables
  late TextEditingController _effectiveController;
  bool _isInternalController = false;
  // endregion

  // region Lifecycle Methods
  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _effectiveController = TextEditingController();
      _isInternalController = true;
    } else {
      _effectiveController = widget.controller!;
    }
    _syncText();
  }

  @override
  void didUpdateWidget(covariant AppCommonDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_isInternalController) {
        _effectiveController.dispose();
      }
      if (widget.controller == null) {
        _effectiveController = TextEditingController();
        _isInternalController = true;
      } else {
        _effectiveController = widget.controller!;
        _isInternalController = false;
      }
    }
    if (widget.selectedDate != oldWidget.selectedDate) {
      _syncText();
    }
  }

  @override
  void dispose() {
    if (_isInternalController) {
      _effectiveController.dispose();
    }
    super.dispose();
  }
  // endregion

  // region Date Formatting & Helpers
  void _syncText() {
    if (widget.selectedDate != null) {
      final formatted = _formatDate(widget.selectedDate!);
      if (_effectiveController.text != formatted) {
        _effectiveController.text = formatted;
      }
    }
  }

  String _formatDate(DateTime date) {
    if (widget.dateFormatter != null) {
      return widget.dateFormatter!(date);
    }
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
  // endregion

  // region Date Picker Interaction
  Future<void> openDatePicker() => _handleTap();

  Future<void> _handleTap() async {
    final isInteractive = widget.enabled && !widget.readOnly;
    if (!isInteractive) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = widget.selectedDate ?? today;
    final first = widget.firstDate ?? DateTime(2000);
    final last = widget.lastDate ?? DateTime(2100);

    final clampedInitial = initial.isBefore(first)
        ? first
        : (initial.isAfter(last) ? last : initial);

    final picked = await showDatePicker(
      context: context,
      initialDate: clampedInitial,
      firstDate: first,
      lastDate: last,
      helpText: widget.helpText ?? widget.labelText ?? 'Select Date',
      initialEntryMode: widget.initialEntryMode,
    );

    if (picked != null) {
      final formatted = _formatDate(picked);
      _effectiveController.text = formatted;
      widget.onDateSelected?.call(picked);
    }
  }
  // endregion

  // region Build Method
  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.enabled && !widget.readOnly;
    final defaultBgColor =
        isInteractive ? AppColors.aliceBlue : const Color(0xFFF1F3F5);

    final cleanLabel =
        widget.labelText?.replaceAll(' *', '').replaceAll('*', '').trim();

    return AppCommonTextField(
      controller: _effectiveController,
      labelText: cleanLabel,
      hintText: widget.hintText,
      isRequired: widget.isRequired ||
          (widget.labelText != null && widget.labelText!.contains('*')),
      readOnly: true,
      enabled: isInteractive,
      onTap: isInteractive ? _handleTap : null,
      fillColor: widget.fillColor ?? defaultBgColor,
      focusNode: widget.focusNode,
      validator: widget.validator,
      width: widget.width,
      height: widget.height,
      prefixIcon: widget.prefixWidget,
      suffixIcon: widget.suffixIcon ??
          Padding(
            padding: EdgeInsets.only(right: 6.w),
            child: Icon(
              Icons.calendar_today_outlined,
              color: AppColors.grey300,
              size: 14.r,
            ),
          ),
      suffixIconConstraints: BoxConstraints(minWidth: 20.w, minHeight: 0),
    );
  }
  // endregion
}
// endregion
