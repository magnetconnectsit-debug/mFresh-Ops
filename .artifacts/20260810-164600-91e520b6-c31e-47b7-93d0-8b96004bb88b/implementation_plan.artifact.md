# Implementation Plan - Use `MonthYearPickerField` for Dashboard Month Filter

The user wants to use the `MonthYearPickerField` widget in the dashboard filter for selecting a custom month range.

## Proposed Changes

### Dashboard Widgets

#### [dashboard_filters.dart](file:///D:/Flutter%20Projects/magnet_connects/packages/apps/mfresh_ops/lib/modules/dashboard/views/widgets/dashboard_filters.dart)

- Import `MonthYearPickerField` from `core`.
- Update the "Months" filter section to show the custom month range fields when "Custom" is tapped (or replace the "Custom" text with the actual fields).
- According to the user request "use that in custom for month conatiner filter", I will add two `MonthYearPickerField` widgets (From/To) inside the "Months" filter card when a custom range is being used, or simply replace the dialog-based approach with inline pickers if appropriate.
- However, looking at the current UI structure, I will replace the "Custom" text action with an expandable section or keep it as an action that opens the picker but uses the specific widget.
- Actually, the best way to "use that in custom for month container filter" is to replace the current `showCustomMonthRangePicker` logic or integrate it into the filter card.

I will:
1.  Update `_buildFilterHeaderRow` or create a new row for custom month selection.
2.  Add `MonthYearPickerField` widgets for `From` and `To` months.

```dart
// In DashboardFilters
import 'package:core/widgets/month_year_picker_field.dart';

// ... in building the Months card ...
_buildFilterHeaderRow(
  'Months',
  '', // Hide the "Custom" text
),
SizedBox(height: 6.h),
Row(
  children: [
    Expanded(
      child: MonthYearPickerField(
        value: controller.rxFromMonth.value,
        label: 'From',
        onChanged: (v) => controller.setCustomFromMonth(v),
      ),
    ),
    SizedBox(width: 8.w),
    Expanded(
      child: MonthYearPickerField(
        value: controller.rxToMonth.value,
        label: 'To',
        onChanged: (v) => controller.setCustomToMonth(v),
      ),
    ),
  ],
),
```

### Dashboard Controller

#### [dashboard_controller.dart](file:///D:/Flutter%20Projects/magnet_connects/packages/apps/mfresh_ops/lib/modules/dashboard/controllers/dashboard_controller.dart)

- Add `setCustomFromMonth` and `setCustomToMonth` methods.
- These methods will clear other conflicting filters and trigger `fetchDashboardData`.
- Ensure they handle the 'MMM-yyyy' format used by `MonthYearPickerField` if needed, but the API seems to expect 'yyyy-MM'. I will need to convert the format.

## Verification Plan

### Automated Tests
- None.

### Manual Verification
- Verify that the `MonthYearPickerField` appears in the dashboard filter under "Months".
- Verify that selecting a month triggers a dashboard refresh with the correct filters.
- Verify that clearing the month (via the 'X' in the field) also refreshes the data.
