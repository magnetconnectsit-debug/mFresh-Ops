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
```dart
class SampleController extends GetxController {
  // region Dependencies & Repositories
  final SampleRepository _repository = Get.find<SampleRepository>();
  // endregion

  // region Observables & State Variables
  final isLoading = false.obs;
  final items = <SampleItem>[].obs;
  // endregion

  // region Text Controllers & Focus Nodes
  final titleController = TextEditingController();
  final titleFocusNode = FocusNode();
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() { super.onInit(); fetchData(); }

  @override
  void onClose() {
    titleController.dispose();
    titleFocusNode.dispose();
    super.onClose();
  }
  // endregion

  // region API & Network Operations
  Future<void> fetchData() async { /* ... */ }
  // endregion

  // region Business Logic & Helpers
  void updateItem(...) { /* ... */ }
  // endregion
}
```

### 1.2 Views (`StatelessWidget` / `StatefulWidget`)
```dart
class SampleScreen extends StatelessWidget {
  const SampleScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SampleController>();
    return Scaffold(
      appBar: _buildAppBar(context, controller),
      body: _buildBody(context, controller),
    );
  }
  // endregion

  // region Header & App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context, SampleController controller) => AppCommonAppBar(...);
  // endregion

  // region Section Builders
  Widget _buildBody(BuildContext context, SampleController controller) {
    return Column(children: [_buildFilterBar(controller), _buildContentList(controller)]);
  }
  Widget _buildFilterBar(SampleController controller) => ...;
  Widget _buildContentList(SampleController controller) => ...;
  // endregion

  // region Dialogs & Action Handlers
  void _showConfirmDialog(BuildContext context, SampleController controller) => ...;
  // endregion
}
```

### 1.3 Data Models
```dart
// region Models
class SampleItem {
  final int id;
  SampleItem({required this.id});

  // region Factory & Serialization
  factory SampleItem.fromJson(Map<String, dynamic> json) => ...;
  Map<String, dynamic> toJson() => ...;
  // endregion

  // region CopyWith & Equatable
  SampleItem copyWith({...}) => ...;
  // endregion
}
// endregion
```

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