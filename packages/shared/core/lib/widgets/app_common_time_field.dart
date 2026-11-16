// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// endregion

// region AppCommonTimeField Class
/// A standardized, reusable time picker field compliant with Magnet Connects design standards.
///
/// Wraps [AppCommonTextField] with a tap-to-pick modal [showTimePicker], automatic
/// time formatting (e.g. '09:30 AM'), clear icon handling, and validation.
class AppCommonTimeField extends StatefulWidget {
  // region Properties
  /// The label displayed on the text field or floating label.
  final String? labelText;

  /// Placeholder hint text when empty (defaults to 'Select time').
  final String hintText;

  /// Current selected time.
  final TimeOfDay? selectedTime;

  /// Callback when a new time is selected by the user.
  final ValueChanged<TimeOfDay>? onTimeSelected;

  /// Optional external controller. If omitted, an internal controller is maintained.
  final TextEditingController? controller;

  /// Custom time formatter function. Defaults to `H:mm a`.
  final String? Function(TimeOfDay)? timeFormatter;

  /// Whether the field is mandatory (displays required asterisk).
  final bool isRequired;

  /// Whether the field is enabled for user interaction.
  final bool enabled;

  /// Whether the field is read-only (prevents time picker modal from opening).
  final bool readOnly;

  /// Background fill color.
  final Color? fillColor;

  /// Optional custom prefix widget or icon.
  final Widget? prefixWidget;

  /// Optional custom suffix widget or icon. Defaults to clock outline icon.
  final Widget? suffixIcon;

  /// Optional focus node.
  final FocusNode? focusNode;

  /// Optional form validator.
  final FormFieldValidator<String>? validator;

  /// Picker dialog help text (title in time picker modal).
  final String? helpText;

  /// Custom width constraint.
  final double? width;

  /// Custom height constraint.
  final double? height;

  /// Whether to use 24-hour format in picker dialog.
  final bool alwaysUse24HourFormat;
  // endregion

  // region Constructor
  const AppCommonTimeField({
    super.key,
    this.labelText,
    this.hintText = 'Select time',
    this.selectedTime,
    this.onTimeSelected,
    this.controller,
    this.timeFormatter,
    this.isRequired = false,
    this.enabled = true,
    this.readOnly = false,
    this.fillColor,
    this.prefixWidget,
    this.suffixIcon,
    this.focusNode,
    this.validator,
    this.helpText,
    this.width,
    this.height,
    this.alwaysUse24HourFormat = false,
  });
  // endregion

  @override
  State<AppCommonTimeField> createState() => _AppCommonTimeFieldState();
}
// endregion

// region _AppCommonTimeFieldState Class
class _AppCommonTimeFieldState extends State<AppCommonTimeField> {
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
  void didUpdateWidget(covariant AppCommonTimeField oldWidget) {
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
    if (widget.selectedTime != oldWidget.selectedTime) {
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

  // region Time Formatting & Helpers
  void _syncText() {
    if (widget.selectedTime != null) {
      final formatted = _formatTime(widget.selectedTime!);
      if (_effectiveController.text != formatted) {
        _effectiveController.text = formatted;
      }
    } else {
      if (_effectiveController.text.isNotEmpty && widget.controller == null) {
        _effectiveController.text = '';
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    if (widget.timeFormatter != null) {
      final custom = widget.timeFormatter!(time);
      if (custom != null) return custom;
    }
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
  // endregion

  // region Time Picker Interaction
  Future<void> _handleTap() async {
    final isInteractive = widget.enabled && !widget.readOnly;
    if (!isInteractive) return;

    final initial = widget.selectedTime ?? TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: widget.helpText ?? widget.labelText ?? 'Select Time',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: widget.alwaysUse24HourFormat,
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: AppColors.white,
                onSurface: AppColors.black,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      final formatted = _formatTime(picked);
      _effectiveController.text = formatted;
      widget.onTimeSelected?.call(picked);
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
              Icons.access_time_rounded,
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
