---
trigger: always_on
---

# Engineering & Architecture Rules

> **Applicability:** All AI Agents & Human Developers  
> **Repository:** `magnet_connects` | **Scope:** Apps (`packages/apps/*`) & Shared (`packages/shared/*`)

Mandatory standards and architectural rules that MUST be strictly followed when writing, modifying, or refactoring code.

---

## 1. Code Organization via `// region` and `// endregion`

Every file (Controller, View, Repository, Model, or Utility) must organize its logic into explicit, labeled `// region` and `// endregion` blocks.

### 1.1 Controllers (`GetxController`)
- `// region Dependencies & Repositories` (repositories, services, `Get.find`)
- `// region Observables & State Variables` (`.obs`, rx variables, lists)
- `// region Text Controllers & Focus Nodes` (`TextEditingController`, `FocusNode`)
- `// region Lifecycle Methods` (`onInit`, `onReady`, `onClose` with disposals)
- `// region API & Network Operations` (network calls, async fetches)
- `// region Business Logic & Helpers` (data processing, event handlers, validation)

### 1.2 Views (`StatelessWidget` / `StatefulWidget`)
- `// region Main Build` (`build()` returning Scaffold/Root)
- `// region Header & App Bar` (`_buildAppBar`, title widgets)
- `// region Section Builders` (`_buildBody`, filter bars, content lists, grids)
- `// region Dialogs & Action Handlers` (modals, bottom sheets, tap handlers)

### 1.3 Repositories & Data Models
- Repositories: `// region Dependencies & Services`, `// region API Operations`
- Models: `// region Models`, `// region Factory & Serialization`, `// region CopyWith & Equatable`

---

## 2. Mandatory Usage of Common Widgets (`package:core/core.dart`)

**Never create ad-hoc widgets or use raw framework widgets when a standardized common widget exists.** All components reside in `package:core/widgets/...` (exported by `package:core/core.dart`).

### 2.1 Common Widget Catalog & Mapping

| UI Requirement | Mandatory Widget (`package:core/core.dart`) | Do NOT Use |
|---|---|---|
| **Screen App Bar** | `AppCommonAppBar` | `AppBar(...)` |
| **Buttons (Solid, Outline, Action)** | `AppCommonButton` | `ElevatedButton`, `TextButton`, `MaterialButton` |
| **Input Fields / Text Fields** | `AppCommonTextField` | `TextField`, `TextFormField` |
| **Standard Dropdowns** | `AppCommonDropDown`, `AppCommonDropdownPage` | `DropdownButtonFormField` |
| **Multi-Select Dropdown** | `AppCommonMultiSelectDropdown` | Ad-hoc multi-select or cross-module widget imports |
| **Data Tables** | `AppCommonTable` | `DataTable`, `Table` |
| **Table Pagination** | `AppTablePagination` | Custom page buttons |
| **Excel & PDF Exports** | `AppCommonExportButton` | Custom popup menus |
| **Search Bars** | `AppCommonSearchBar` | Raw text fields for search |
| **Dialogs & Confirmations** | `AppCommonDialogBox` | `AlertDialog` |
| **Bottom Sheets** | `AppCommonBottomSheet` | `showModalBottomSheet` raw sheets |
| **Network & Asset Images** | `AppImageView` | `Image.network`, `CachedNetworkImage` directly |
| **Pull to Refresh** | `AppRefreshIndicator` | `RefreshIndicator` |
| **Loading Spinners** | `CustomAppLoader` | `CircularProgressIndicator` directly |
| **Month / Year Picker** | `MonthYearPickerField` | Custom date pickers for month-year |
| **Date Fields / Date Pickers** | `AppCommonDateField` | Raw text fields with manual `showDatePicker` |
| **Time Fields / Time Pickers** | `AppCommonTimeField` | Raw text fields with manual `showTimePicker` |
| **Connected Tab Bar** | `AppCommonConnectedTabBar` | Ad-hoc tab switchers or raw underline tab rows |
| **Liquid Glass / Glassmorphism** | `AppCommonLiquidGlass` | Raw opacity stacks, ad-hoc frosted containers |
| **Document Viewing** | `AppCommonPdfViewer`, `AppCommonExcelViewer` | Third party viewer embeds |
| **No Internet / Server Error** | `AppCommonNoInternetWidget`, `ServerMaintenanceWidget` | Ad-hoc error screens |
| **Toast Notifications** | `AppCommonToastMessage` | `ScaffoldMessenger.showSnackBar` |
| **Typography & Text Styles** | `AppTextStyle.style_*_*` | Hardcoded `TextStyle(fontSize: ...)` |
| **Color Tokens** | `AppColors.*` | Hardcoded `Colors.grey`, `Colors.blue` |

### 2.2 Rules for Responsive Sizing
* **Always use ScreenUtil extensions**: Use `.w`, `.h`, `.r`, and `.sp` from `package:flutter_screenutil/flutter_screenutil.dart`.
* Example: `padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)`, `borderRadius: BorderRadius.circular(8.r)`, `fontSize: 14.sp`.

### 2.3 Standardized Filter Container Pattern
All filter panels across modules (Inventory, Collections, Deposits, Tasks, Attendance, Selfie Attendance, etc.) **MUST** strictly follow the standardized card container architecture:
1. **Container Styling**:
   ```dart
   Container(
     padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
     decoration: BoxDecoration(
       color: AppColors.white,
       borderRadius: BorderRadius.circular(12.r),
       boxShadow: [
         BoxShadow(
           color: Colors.black.withValues(alpha: 0.05),
           blurRadius: 10,
           offset: const Offset(0, 4),
         ),
       ],
     ),
     child: Column(...),
   )
   ```
2. **Header & Reset Action**:
   - Header: `Text('Filters', style: AppTextStyle.style_14_600(color: AppColors.black))`
   - Reset Trigger: If active filters exist, show `'Reset All'` action link in `Color(0xFFF15A24)` or an explicit Reset button.
3. **Responsive Field Layout**:
   - Wrap filter fields in `LayoutBuilder` with responsive `Row`s using `crossAxisAlignment: CrossAxisAlignment.end` (or `GridView` with `crossAxisCount: isMobile ? 2 : 4`, `mainAxisSpacing: 8.h`, `crossAxisSpacing: 6.w`).
4. **Standard Field Components**:
   - **Dropdowns**: Mandatory use of `AppCommonMultiSelectDropdown<T>` with `label: 'Select ...'` (renders floating label), `hint: '...'`, `aliceBlue` background, and compact padding.
   - **Date Range / Pickers**: Use `InputDecorator` with `labelText: 'Select Date Range'`, `floatingLabelBehavior: FloatingLabelBehavior.always`, `fillColor: AppColors.aliceBlue`, inner height `18.h`, and `Icons.calendar_today_outlined`.
   - **Action Buttons**: `AppCommonButton` with height `24.h`, `width: double.infinity`, `padding: EdgeInsets.symmetric(horizontal: 4.w)`, `borderRadius: 4.r`, `textSize: 11.sp` (bottom-aligned via `CrossAxisAlignment.end` to match floating label input boxes).
5. **Active Filter Chips**:
   - When filters are selected, display horizontal scrollable active filter chips with remove (`X`) icons below the grid.

### 2.4 Default Table Row Height & Dense Presentation Standards
1. **Default Row Height (`24.h`)**:
   - All data tables created using `AppCommonTable` **MUST rely on the default row height of `24.h`** (omit `headingRowHeight` or set to `24.h`).
   - Do **NOT** use tall or oversized rows (`38.h`, `48.h`, `50.h`) unless explicitly displaying multiline expandable notes/descriptions.
   - Custom table views must also standardize on:
     - Header row height: `24.h`
     - Data row height: `24.h` (or max `26.h`)
     - Divider / break rows: `20.h`
     - Footer / daily total rows: `24.h`
2. **Dense Cell Styling**:
   - Cell vertical padding: `2.h`.
   - Typography: `AppTextStyle.style_11_700` for headers and `AppTextStyle.style_11_400` / `style_11_500` for data cells.
   - Action icons / thumbnails: keep compact (`13.sp` icon size, `16.r` thumbnail size) to ensure vertical alignment without stretching row height.

---

## 3. Role-Based Permissions (RBAC) Standards

Every screen, action button, edit icon, delete icon, or filter element representing restricted functionality **MUST check permissions** against `AuthRepository.rxUserPermissions`.

### 3.1 Dual-Level Permission Enforcement
1. **Visual Layer (UI Rendering)**: Hide/omit restricted components if permission is absent:
   ```dart
   if (Get.find<AuthRepository>().rxUserPermissions.contains('permission_key'))
     AppCommonButton(...),
   ```
2. **Execution Layer (Tap Guard)**: Prevent action dispatch if triggered mistakenly:
   ```dart
   if (!Get.find<AuthRepository>().rxUserPermissions.contains('permission_key')) {
     AppCommonToastMessage.show(message: 'You do not have permission to perform this action.', type: ToastType.warning);
     return;
   }
   ```
3. **Consistency Rule**: Never leave an action button visible in a sub-view (e.g., month view or card) if it is guarded in the primary view.

---

## 4. State Management & GetX Guidelines

1. **Focused Controllers**: Controllers should not exceed ~600-800 lines. Separate complex wizard forms into dedicated `*FormController`.
2. **Granular Reactivity (`Obx`)**: Wrap only the specific leaf widget that depends on the observable, rather than the entire `Scaffold` or large scrolling containers.
3. **Timer & Stream Cleanup**: Any `Timer.periodic`, `StreamSubscription`, or `ScrollController` created in a controller or stateful widget must be cancelled/disposed in `onClose()` or `dispose()`.
4. **No Controller Leaks in `build()`**: Never instantiate `TextEditingController()`, `FocusNode()`, or `ScrollController()` inside `build()`. Manage them in controller/state lifecycle.

---

## 5. Documentation & Living Specification Rule

Whenever any modification, addition, or bug fix is applied to a module:
1. **Document First / Sync Always**: Review and update the module's master documentation file (`documentation/<module>/<MODULE>.md`):
   * Changes in API payloads or parameters.
   * New or modified permission keys.
   * UI workflow or state machine changes.
   * Additions to the Change Log table (Date, Author, Description).
2. **Single Source of Truth**: All developer notes, known issues, and architecture mappings live in the module's markdown file.

---

## 6. Retrofitting Existing Code (Mandatory Compliance on Modification)

Whenever touching, refactoring, fixing bugs, or adding functionality to **ANY existing file** across the codebase:

1. **Zero Legacy Exception**: Do NOT leave modified files in a non-compliant state. The entire file being edited must be brought into full compliance.
2. **Mandatory Region Structuring**: Organize all classes, properties, constructors, lifecycle hooks, build methods, and helpers into explicit, labeled `// region` and `// endregion` blocks.
3. **Common Widget & Token Migration**:
   * Replace raw Flutter widgets (`TextField`, `ElevatedButton`, `TextButton`, `AppBar`, `AlertDialog`, etc.) with mandatory `AppCommon*` equivalents from `package:core/core.dart`.
   * Replace hardcoded colors with `AppColors.*` tokens.
   * Replace hardcoded `TextStyle(...)` with `AppTextStyle.style_*_*`.
   * Replace custom glass containers with `AppCommonLiquidGlass`.
4. **Responsive Sizing**: Retrofit all pixel measurements (paddings, margins, dimensions, border radii, icon sizes, font sizes) to use ScreenUtil extensions (`.w`, `.h`, `.r`, `.sp`).
5. **Clean State & Disposal**: Ensure any newly touched or existing controllers, focus nodes, animations, or subscriptions are cleanly initialized and disposed of in `dispose()` or `onClose()`.
6. **Filter Container & Table Standards**: Bring any filter section into compliance with the Standard Filter Container (Section 2.3) and ensure tables use the default `24.h` row height (Section 2.4).