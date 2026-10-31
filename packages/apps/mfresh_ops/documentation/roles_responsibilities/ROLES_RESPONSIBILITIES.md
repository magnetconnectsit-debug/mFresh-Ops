# Roles & Responsibilities Module Architecture & Living Documentation

> **Module:** Roles & Responsibilities  
> **Package:** `mfresh_ops` (`packages/apps/mfresh_ops`)  
> **Status:** Active / Production Compliant  
> **Last Updated:** 2026-10-23  

---

## 1. Architectural Overview

The **Roles & Responsibilities** module provides an end-to-end management interface for system user roles, role descriptions, and bilingual operational guidelines (English & Odia). The module allows administrators to define custom roles, attach rich HTML-formatted guidelines and responsibilities, preview formatted guidelines across languages, and govern access with role-based access control (RBAC).

### 1.1 Directory Structure
```
lib/modules/roles_responsibilities/
├── controllers/
│   ├── add_responsibility_controller.dart
│   ├── add_role_controller.dart
│   ├── responsibilities_master_controller.dart
│   ├── roles_master_controller.dart
│   └── view_responsibilities_controller.dart
└── views/
    ├── add_responsibility_screen.dart
    ├── add_role_screen.dart
    ├── responsibilities_master_screen.dart
    ├── roles_master_screen.dart
    ├── view_responsibilities_screen.dart
    └── widgets/
        ├── rich_editor_field.dart
        └── simple_html_renderer.dart
```

---

## 2. Screens & Workflows

### 2.1 Roles Master (`RolesMasterScreen`)
- **Route:** `AppRoutes.rolesMaster`
- **Controller:** `RolesMasterController`
- **Core Features:**
  - Displays list of configured roles in standardized dense table (`AppCommonTable`).
  - Standard row height `24.h`, dense cells (`AppTextStyle.style_11_*`).
  - Sl.No indexation and sortable columns (Role Name, Sl.No).
  - Search bar in `AppCommonAppBar` with 600ms debounced search query.
  - Dialog-based quick Add/Edit role (`_showAddEditRoleDialog`) utilizing `AppCommonTextField` and `AppCommonButton`.
  - Delete confirmation via `AppCommonDialogBox.showConfirm`.
  - Pagination via `AppTablePagination`.
  - Refresh via `AppRefreshIndicator` and non-blocking loading via `CustomAppLoader`.

### 2.2 Responsibilities Master (`ResponsibilitiesMasterScreen`)
- **Route:** `AppRoutes.responsibilitiesMaster`
- **Controller:** `ResponsibilitiesMasterController`
- **Core Features:**
  - Displays role-to-guideline mappings in `AppCommonTable` (`24.h` default height).
  - Columns: `Sl.No`, `Role`, `Guidelines (English)`, `Guidelines (Odia)`, `Action`.
  - Interactive row expansion (`toggleRowExpansion`) rendering formatted HTML preview via `SimpleHtmlRenderer` when expanded.
  - Debounced search query via search bar in `AppCommonAppBar`.
  - Add Responsibility navigates to `AddResponsibilityScreen`.
  - Edit Responsibility passes `ResponsibilityItem` to `AddResponsibilityScreen`.
  - Delete confirmation via `AppCommonDialogBox.showConfirm`.
  - Pagination via `AppTablePagination`.

### 2.3 Add / Edit Role (`AddRoleScreen`)
- **Route:** `AppRoutes.addRole`
- **Controller:** `AddRoleController`
- **Features:**
  - Form validation with `AppCommonTextField`.
  - Handles both creation (`storeRole`) and modification (`updateRole`).
  - Responsive container styling with ScreenUtil sizing tokens.

### 2.4 Add / Edit Responsibility (`AddResponsibilityScreen`)
- **Route:** `AppRoutes.addResponsibility`
- **Controller:** `AddResponsibilityController`
- **Features:**
  - Role selection via `AppCommonMultiSelectDropdown<int>` with single-select mode.
  - Multiline guidelines text entry in English and Odia via `AppCommonTextField`.
  - Automatic bidirectional conversion between plain text/bullet format and HTML tags (`<ul>`, `<li>`, `<p>`, `<h3>`).
  - Handles single and batch responsibility creations across selected roles.

### 2.5 View Responsibility (`ViewResponsibilitiesScreen`)
- **Route:** `AppRoutes.viewResponsibilities`
- **Controller:** `ViewResponsibilitiesController`
- **Features:**
  - Filter container following standardized card pattern (`12.r` radius, elevation shadow).
  - Role dropdown via `AppCommonMultiSelectDropdown<int>`.
  - Language toggle between English and Odia.
  - Formatted guidelines display via `SimpleHtmlRenderer` supporting headings, bullet lists, blockquotes, bold, and italic inline spans.

---

## 3. RBAC Permissions Enforcement

Dual-level permission enforcement guarantees that restricted actions are guarded on both UI rendering and execution layers:

| Action / View | Permission Key | Visual Layer Guard | Execution Layer Guard |
|---|---|---|---|
| Sidebar Menu Group | `AppPermissions.rolesResponsibilityPanel` | Omitted if unauthorized | Tap returns early with toast |
| Roles Master View / Nav | `AppPermissions.rolesMaster` | Omitted in sidebar if unauthorized | Toast warning & navigation blocked |
| Add / Edit / Delete Role | `AppPermissions.rolesMaster` | Action buttons hidden | Execution blocked with toast warning |
| Responsibilities Master | `AppPermissions.responsibilitiesMaster` | Omitted in sidebar if unauthorized | Toast warning & navigation blocked |
| Add / Edit / Delete Responsibility | `AppPermissions.responsibilitiesMaster` | Action buttons hidden | Execution blocked with toast warning |
| View Responsibility Screen | `AppPermissions.viewResponsibilities` | Omitted in sidebar if unauthorized | Toast warning & navigation blocked |

---

## 4. API Endpoints & Payloads

The repository `RolesResponsibilitiesRepository` communicates via `ApiService`:

### 4.1 Roles Endpoints
- **Index:** `GET` `AppConstants.rolesIndex` (`search`, `page`, `per_page`)
- **Store:** `POST` `AppConstants.rolesStore` (`role_name`)
- **Update:** `POST` `AppConstants.rolesUpdate` (`id`, `role_name`)
- **Delete:** `POST` `AppConstants.rolesDelete` (`id`)

### 4.2 Responsibilities Endpoints
- **Index:** `GET` `AppConstants.responsibilitiesIndex` (`search`, `page`, `per_page`)
- **Store:** `POST` `AppConstants.responsibilitiesStore` (`role_id`, `guidelines_english`, `guidelines_odia`)
- **Update:** `POST` `AppConstants.responsibilitiesUpdate` (`id`, `role_id`, `guidelines_english`, `guidelines_odia`)
- **Delete:** `POST` `AppConstants.responsibilitiesDelete` (`id`)
- **View:** `GET` `AppConstants.responsibilitiesView` (`role_id`, `language`)

---

## 5. Architectural Standards Compliance Checklist

- [x] **Region Structuring:** Explicit labeled `// region` and `// endregion` blocks in all 9 module files.
- [x] **Common Widgets:** 100% adherence to `package:core/core.dart` widgets (`AppCommonAppBar`, `AppCommonTable`, `AppCommonButton`, `AppCommonTextField`, `AppCommonMultiSelectDropdown`, `AppCommonDialogBox`, `AppRefreshIndicator`, `CustomAppLoader`, `AppTablePagination`).
- [x] **Default Table Row Height:** Standard default `24.h` row height, dense cells (`2.h` padding), compact action icons (`13.sp`).
- [x] **Color Tokens:** Zero hardcoded colors; all styling uses `AppColors.*`.
- [x] **Responsive Dimensions:** Full ScreenUtil integration (`.w`, `.h`, `.r`, `.sp`).
- [x] **State Management:** Controllers dispose worker subscriptions (`_searchWorker?.dispose()`) and text controllers in `onClose()`.
- [x] **RBAC Permissions:** Visual omission and tap execution guards on all actions.

---

## 6. Change Log

| Date | Author | Description |
|---|---|---|
| 2026-10-23 | Antigravity AI | Full architectural compliance refactor: structured all 9 files into mandatory labeled regions (`// region`), migrated tables to `AppCommonTable` with dense `24.h` rows, replaced raw `TextFormField` with `AppCommonTextField`, replaced custom dropdowns with `AppCommonMultiSelectDropdown`, replaced raw dialogs with `AppCommonDialogBox`, migrated all hardcoded colors to `AppColors.*`, enforced RBAC visual/execution guards, and instituted module master documentation. |
| 2026-10-23 | Antigravity AI | Mobile UI enhancement: moved `Total: <count>` badge out of `AppCommonAppBar` actions and positioned it into `_buildActionBar` opposite the Add action button. This eliminates title truncation (`Roles Mast...` -> `Roles Master`) on compact mobile viewports while giving global search optimal width. |
| 2026-10-23 | Antigravity AI | View Responsibilities UI enhancement: set dropdown height to `30.h` with dynamic centering and expanded popup menu maxHeight to `320.h`. Reduced top filter section spacing by consolidating language selector into an inline row with shrink-wrap radio buttons and tightening card and body padding. |
