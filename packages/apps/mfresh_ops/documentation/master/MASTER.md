# Master Setup Module Architecture & Living Documentation

> **Module:** Master Setup (Zone, State, District, Service & Amenity Masters)  
> **Package:** `mfresh_ops` (`packages/apps/mfresh_ops`)  
> **Status:** Active / Production Compliant  
> **Last Updated:** 2026-11-14  
> **Maintainer:** Banamali Nayak

---

## 1. Architectural Overview

The **Master Setup** module provides centralized administrative governance over geographical divisions, operational services, amenities, and organizational topologies across the mFresh Ops ecosystem. It manages foundational data entities including **Zones**, **States**, **Districts**, **Services**, **Amenities**, and **Units**, which underpin all operational routing, asset assignment, support ticket allocation, and regional reporting.

### 1.1 Directory Structure
```
packages/apps/mfresh_ops/
├── lib/
│   ├── data/
│   │   ├── models/
│   │   │   └── master/
│   │   │       ├── zone_model.dart
│   │   │       ├── state_model.dart
│   │   │       ├── district_model.dart
│   │   │       ├── service_model.dart
│   │   │       ├── amenity_model.dart
│   │   │       └── unit_master_model.dart
│   │   └── repositories/
│   │       └── master_repository.dart
│   └── modules/
│       └── master/
│           ├── controllers/
│           │   ├── zone_controller.dart
│           │   ├── state_controller.dart
│           │   ├── district_controller.dart
│           │   ├── service_controller.dart
│           │   ├── amenity_controller.dart
│           │   └── unit_controller.dart
│           └── views/
│               ├── master_placeholder_screen.dart
│               ├── zone_screen.dart
│               ├── state_screen.dart
│               ├── district_screen.dart
│               ├── service_screen.dart
│               ├── amenity_screen.dart
│               ├── unit_screen.dart
│               ├── unit_edit_screen.dart
│               └── widgets/
│                   └── edit_unit_manager_dialog.dart
└── documentation/
    └── master/
        └── MASTER.md
```

---

## 2. Screens & Workflows

### 2.1 Zone Master (`ZoneScreen`)
- **Route:** `AppRoutes.masterZone` (`/master-zone`)
- **Controller:** `ZoneController`
- **Core Features:**
  - Standardized dense data table (`AppCommonTable<ZoneItem>`) adhering to default `24.h` row height and compact cell padding (`2.h`).
  - Columns: `SI No.` (`55.w`), `Zone` (`110.w`, sortable), `Status` (`95.w`, non-sortable), `Action` (`75.w`, non-sortable).
  - Search integrated into `AppCommonAppBar` (`showSearchBar: true`, debounced).
  - Quick Add/Edit dialog (`_showAddEditZoneDialog`) with `AppCommonTextField` (default styling, `aliceBlue` fill, `fieldBorderColor`), active status toggle switch, and button loader.
  - Interactive status toggle with confirmation guard: deactivating an active zone prompts confirmation via `AppCommonDialogBox.showConfirm`. Activating directly toggles.
  - Delete operation guarded with destructive confirmation dialog (`isDanger: true`).
  - Table pagination powered by `AppTablePagination`.
  - Excel report export via `AppCommonExportButton` utilizing `AppExportUtils.exportToExcel`.
  - Full loading state overlays: semi-transparent backdrop with centered `CustomAppLoader` during asynchronous operations (create, update, toggle on/off, delete).

### 2.2 State Master (`StateScreen`)
- **Route:** `AppRoutes.masterState` (`/master-state`)
- **Controller:** `StateController`
- **Core Features:**
  - Standardized dense data table (`AppCommonTable<StateItem>`) with `24.h` row height and dense padding.
  - Columns: `SI No.` (`55.w`, sortable), `Zone` (`100.w`, sortable), `State` (`120.w`, sortable), `Status` (`95.w`, non-sortable), `Action` (`75.w`, non-sortable).
  - App bar search query filtering states by state name, parent zone name, or active/inactive status.
  - Add/Edit State dialog (`_showAddEditStateDialog`):
    - **First input:** State Name field using default `AppCommonTextField` (`labelText: 'State Name'`, `isRequired: true`).
    - **Second input row:** Horizontal layout containing:
      - `Expanded` Zone selection using `AppCommonMultiSelectDropdown<int>` (`isSingleSelect: true`, `showSearch: true`, `label: 'Select Zone *'`, default height).
      - Inline Status switch (`Status: [Switch] Active/Inactive`) bottom-aligned via `CrossAxisAlignment.end` and `Padding(bottom: 6.h)` to match dropdown input box baseline.
  - Status toggle deactivation confirmation guard via `AppCommonDialogBox.showConfirm`.
  - Delete state operation guarded with destructive confirmation dialog (`isDanger: true`).
  - Table pagination powered by `AppTablePagination`.
  - Asynchronous loading feedback: full screen loader overlay (`CustomAppLoader`) during toggle, delete, create, and update.
  - Excel export via `AppCommonExportButton`.

### 2.3 District Master (`DistrictScreen`)
- **Route:** `AppRoutes.masterDistrict` (`/master-district`)
- **Controller:** `DistrictController`
- **Core Features:**
  - Standardized dense data table (`AppCommonTable<DistrictItem>`) with default `24.h` row height and compact cell padding (`2.h`).
  - Columns: `SI No.` (`50.w`, sortable), `Zone` (`85.w`, sortable), `State` (`95.w`, sortable), `District` (`110.w`, sortable), `Status` (`95.w`, non-sortable), `Action` (`75.w`, non-sortable).
  - Search integrated into `AppCommonAppBar` (`showSearchBar: true`, search by district, state, zone, or status).
  - Add/Edit District dialog (`_showAddEditDistrictDialog`):
    - **First input:** District Name field using default `AppCommonTextField` (`labelText: 'District Name'`, `isRequired: true`).
    - **Second input row:** Horizontal layout containing:
      - `Expanded` State selection using `AppCommonMultiSelectDropdown<int>` (`isSingleSelect: true`, `showSearch: true`, `label: 'Select State *'`, default height).
      - Inline Status switch (`Status: [Switch] Active/Inactive`) bottom-aligned via `CrossAxisAlignment.end` and `Padding(bottom: 6.h)` to match dropdown input box baseline.
  - Status toggle deactivation confirmation guard via `AppCommonDialogBox.showConfirm`.
  - Delete district operation guarded with destructive confirmation dialog (`isDanger: true`).
  - Table pagination powered by `AppTablePagination`.
  - Full loading state overlays: semi-transparent backdrop with centered `CustomAppLoader` during asynchronous operations (create, update, toggle on/off, delete).
  - Excel report export via `AppCommonExportButton` utilizing `AppExportUtils.exportToExcel`.

### 2.4 Services Master (`ServiceScreen`)
- **Route:** `AppRoutes.masterServices` (`/master-services`)
- **Controller:** `ServiceController`
- **Core Features:**
  - Standardized dense data table (`AppCommonTable<ServiceItem>`) with default `24.h` row height and compact cell padding (`2.h`).
  - Columns:
    - `Icon` (`50.w`, non-sortable): renders `AppImageView` with compact `20.r` dimensions and fallback icon `Icons.miscellaneous_services_outlined`.
    - `Created Date` (`110.w`, sortable): displays formatted creation date (`formattedCreatedDate`, `dd-MMM-yyyy`).
    - `Service Name` (`180.w`, sortable)
    - `Action` (`75.w`, non-sortable): Edit and Delete action icons.
  - Search integrated into `AppCommonAppBar` (`showSearchBar: true`, search by service name, created date, or ID).
  - Add/Edit Service dialog (`_showAddEditServiceDialog`):
    - **Service Name:** `AppCommonTextField` (`labelText: 'Service Name'`, `isRequired: true`).
    - **Service Icon:** Image picker supporting gallery upload or camera capture, image preview via `AppImageView` / `Image.file`, and clear button.
  - Delete service operation guarded with destructive confirmation dialog (`isDanger: true`).
  - Table pagination powered by `AppTablePagination`.
  - Full loading state overlays: semi-transparent backdrop with centered `CustomAppLoader` during asynchronous operations.
  - Excel report export via `AppCommonExportButton` utilizing `AppExportUtils.exportToExcel`.

### 2.5 Amenities Master (`AmenityScreen`)
- **Route:** `AppRoutes.masterAmenities` (`/master-amenities`)
- **Controller:** `AmenityController`
- **Core Features:**
  - Standardized dense data table (`AppCommonTable<AmenityItem>`) with default `24.h` row height and compact cell padding (`2.h`).
  - Columns:
    - `Icon` (`50.w`, non-sortable): renders `AppImageView` with compact `20.r` dimensions and fallback icon `Icons.category_outlined`.
    - `Amenity Name` (`180.w`, sortable)
    - `Action` (`75.w`, non-sortable): Edit and Delete action icons.
  - Search integrated into `AppCommonAppBar` (`showSearchBar: true`, search by amenity name or ID).
  - Add/Edit Amenity dialog (`_showAddEditAmenityDialog`):
    - **Amenity Name:** `AppCommonTextField` (`labelText: 'Amenity Name'`, `isRequired: true`).
    - **Amenity Icon:** Image picker supporting gallery upload or camera capture via `AppCommonBottomSheet.showModal`, image preview via `AppImageView` / `Image.file`, and clear button.
  - Delete amenity operation guarded with destructive confirmation dialog (`isDanger: true`).
  - Table pagination powered by `AppTablePagination`.
  - Full loading state overlays: semi-transparent backdrop with centered `CustomAppLoader` during asynchronous operations.
  - Excel report export via `AppCommonExportButton` utilizing `AppExportUtils.exportToExcel`.

### 2.6 Units Master (`UnitScreen`), Unit Manager Details (`EditUnitManagerDialog`) & Unit Edit (`UnitEditScreen`)
- **Routes:**
  - Index: `AppRoutes.masterUnits` (`/master-units`) -> `UnitScreen`
  - Edit: `AppRoutes.masterUnitEdit` (`/master-unit-edit`) -> `UnitEditScreen`
- **Controller:** `UnitController`
- **Core Features:**
  - Standardized dense data table (`AppCommonTable<UnitMasterItem>`) adhering to default `24.h` row height and compact cell padding (`2.h`).
  - Action Bar: includes `+ Create Unit` button (`AppCommonButton`) guarded by `AppPermissions.masterPanel`, Excel export button (`AppCommonExportButton`), and total units badge.
  - Columns:
    - `Unit Image` (`65.w`, non-sortable): renders `AppImageView` with compact `20.r` dimensions and fallback icon `Icons.bathroom_outlined`.
    - `Unit` (`95.w`, sortable): displays QR code ID / unit name (`qrcodeId`).
    - `Model` (`140.w`, sortable): displays vehicle/cabin model category (`unitcategory`).
    - `City` (`75.w`, sortable): displays location city (`unitLocation`).
    - `Operating Hrs` (`110.w`, sortable): displays daily operational timings (`openTiming`).
    - `Inauguration Date` (`115.w`, sortable): displays formatted date (`dd-MMM-yyyy`).
    - `Action` (`95.w`, non-sortable):
      - **1st Action Button (Icon Button):** Compact bordered button (`22.h x 22.w`) with `Icons.edit_note_outlined`. Opens `EditUnitManagerDialog`.
      - **2nd Action Button (Edit Button):** Compact bordered button (`22.h`) with `Icons.edit_outlined` and `Edit` text. Navigates to `UnitEditScreen`.
  - **Edit Unit Manager Details Dialog (`EditUnitManagerDialog`):**
    - Modal popup with title and close ('X') icon, styled with 2 fields in a row across mobile and tablet.
    - Fields (2 per row):
      - Row 1: `Highly Preferred` (`AppCommonMultiSelectDropdown<String>`) | `Timing` (`AppCommonTextField`).
      - Row 2: `Unit Address` (`AppCommonTextField`) | `Full Address` (`AppCommonTextField`).
      - Row 3: `Latitude` (`AppCommonTextField`) | `Longitude` (`AppCommonTextField`).
      - `Get Current Location` button powered by `Geolocator` to capture high-accuracy device GPS coordinates and prefill latitude/longitude.
      - `Cancel` and `Update` buttons calling `POST /public/api/unit-details-update`.
  - **Full Unit Create / Edit Screen (`UnitEditScreen`):**
    - Dynamic title and breadcrumb (`All Unit / Create Unit` or `All Unit / Edit Unit`).
    - Full-page responsive form with single/multi-image upload, dropdowns, amenities toggle with quantities, and multiline text areas.
    - `Cancel` and `Submit` / `Update` buttons calling `POST /public/api/unit-create` or `POST /public/api/unit-update` via multipart form data.
  - Search integrated into `AppCommonAppBar` (`showSearchBar: true`, debounced).
  - Table pagination powered by `AppTablePagination`.
  - Excel report export via `AppCommonExportButton` utilizing `AppExportUtils.exportToExcel`.
  - Full loading state overlays with `CustomAppLoader`.

### 2.7 Placeholder Screens (`MasterPlaceholderScreen`)
- Placeholders registered for upcoming master sub-modules:
  - **Assign Services:** `AppRoutes.masterAssignServices` (`/master-assign-services`)
  - **All Assign Services:** `AppRoutes.masterAllAssignServices` (`/master-all-assign-services`)

---

## 3. RBAC Permissions Enforcement

Dual-level permission enforcement guarantees that restricted master features are guarded on both visual rendering and execution layers:

| Action / View | Permission Key | Visual Layer Guard | Execution Layer Guard |
|---|---|---|---|
| Master Home Grid Card | `AppPermissions.masterPanel` | Omitted if unauthorized | Tap blocked |
| Master Sidebar Group | `AppPermissions.masterPanel` | Omitted if unauthorized | Tap returns early with toast |
| Zone Master View / Nav | `AppPermissions.masterPanel` | Navigation omitted | Navigation guarded |
| Add / Edit / Delete Zone | `AppPermissions.masterPanel` | Action controls hidden | Action blocked with toast warning |
| State Master View / Nav | `AppPermissions.masterPanel` | Navigation omitted | Navigation guarded |
| Add / Edit / Delete State | `AppPermissions.masterPanel` | Action controls hidden | Action blocked with toast warning |
| District Master View / Nav | `AppPermissions.masterPanel` | Navigation omitted | Navigation guarded |
| Add / Edit / Delete District | `AppPermissions.masterPanel` | Action controls hidden | Action blocked with toast warning |
| Services Master View / Nav | `AppPermissions.masterPanel` | Navigation omitted | Navigation guarded |
| Add / Edit / Delete Service | `AppPermissions.masterPanel` | Action controls hidden | Action blocked with toast warning |
| Amenities Master View / Nav | `AppPermissions.masterPanel` | Navigation omitted | Navigation guarded |
| Add / Edit / Delete Amenity | `AppPermissions.masterPanel` | Action controls hidden | Action blocked with toast warning |

---

## 4. API Endpoints & Payloads

The repository `MasterRepository` communicates with backend endpoints through `ApiService`:

### 4.1 Zone Endpoints
- **Index:** `GET` `AppConstants.zoneIndex` (`public/api/zone-index`)
- **Create:** `POST` `AppConstants.zoneCreate` (`public/api/zone-create`)
- **Update:** `PUT` `AppConstants.zoneUpdate` (`public/api/zone-update`)
- **Delete:** `POST` `AppConstants.zoneDelete` (`public/api/zone-delete`)

### 4.2 State Endpoints
- **Index:** `GET` `AppConstants.stateIndex` (`public/api/state-index`)
- **Create:** `POST` `AppConstants.stateCreate` (`public/api/state-create`)
- **Update:** `PUT` `AppConstants.stateUpdate` (`public/api/state-update`)
- **Delete:** `POST` `AppConstants.stateDelete` (`public/api/state-delete`)

### 4.3 District Endpoints
- **Index:** `GET` `AppConstants.districtIndex` (`public/api/district-index`)
- **Create:** `POST` `AppConstants.districtCreate` (`public/api/district-create`)
- **Update:** `PUT` `AppConstants.districtUpdate` (`public/api/district-update`)
- **Delete:** `POST` `AppConstants.districtDelete` (`public/api/district-delete`)

### 4.4 Service Endpoints
- **Index:** `GET` `AppConstants.serviceIndex` (`public/api/service-index`)
  - Response: List of services with `id`, `services_name`, `img_icon`, `created_date`, `created_at`, `updated_at`, `img_icon_url`.
- **Create:** `POST` `AppConstants.serviceCreate` (`public/api/service-create`)
  - Content-Type: `multipart/form-data`
  - Form Fields: `serviceNm`, `serviceIcon` (optional)
- **Update:** `POST` `AppConstants.serviceUpdate` (`public/api/service-update`)
  - Content-Type: `multipart/form-data`
  - Form Fields: `id`, `serviceNm`, `serviceIcon` (optional)
- **Delete:** `POST` `AppConstants.serviceDelete` (`public/api/service-delete`)
  - Content-Type: `application/json`
  - Payload: `{"id": 1}`

### 4.5 Amenity Endpoints
- **Index:** `GET` `AppConstants.amenityIndex` (`public/api/amenity-index`)
  - Response: List of amenities with `id`, `amenity_name`, `icon`, `created_at`, `updated_at`, `icon_url`.
- **Create:** `POST` `AppConstants.amenityCreate` (`public/api/amenity-create`)
  - Content-Type: `multipart/form-data`
  - Form Fields: `amenitynm`, `amenity_img` (optional)
- **Update:** `POST` `AppConstants.amenityUpdate` (`public/api/amenity-update`)
  - Content-Type: `multipart/form-data`
  - Form Fields: `id`, `amenitynm`, `amenity_img` (optional)
- **Delete:** `POST` `AppConstants.amenityDelete` (`public/api/amenity-delete`)
  - Content-Type: `application/json`
  - Payload:
    ```json
    {
      "id": 23
    }
    ```

### 4.6 Unit Endpoints
- **Index:** `GET` `AppConstants.unitIndex` (`public/api/unit-index`)
  - Response: Units list with `id`, `servicetype`, `unitcategory`, `year_of_delivery`, `qrcodeId`, `latitude`, `longitude`, `unit_location`, `open_timing`, `full_add`, `highly_prefered`, `status`, `amenities`, `unit_img_url`, `gallery_urls`, etc.
- **Options:** `GET` `AppConstants.unitOptions` (`public/api/unit-options`)
  - Response: Option dictionaries containing `states`, `districts`, `unit_categories`, `service_types`, and `amenities`.
- **Unit Create:** `POST` `AppConstants.unitCreate` (`public/api/unit-create`)
  - Content-Type: `multipart/form-data`
  - Form Fields: `unitcategory`, `unittype`, `servicetype`, `year_of_delivery`, `unit_state`, `unit_dist`, `unit_location`, `oprntiming`, `full_Address`, `unit_desc`, `unit_spec`, `ingd`, `amenities[]`, `amenity_qty[]`, `unit_img`, `multi_img[]`.
- **Unit Details Quick Update:** `POST` `AppConstants.unitDetailsUpdate` (`public/api/unit-details-update`)
  - Content-Type: `multipart/form-data`
  - Form Fields: `id`, `highprefer`, `opentime`, `fulluAddress`, `uadd`, `uptunitlatitude`, `uptunitlongitude`.
- **Unit Full Update:** `POST` `AppConstants.unitUpdate` (`public/api/unit-update`)
  - Content-Type: `multipart/form-data`
  - Form Fields: `id`, `unitcategory`, `unittype`, `servicetype`, `year_of_delivery`, `unit_state`, `unit_dist`, `unit_location`, `oprntiming`, `full_Address`, `unit_desc`, `unit_spec`, `ingd`, `amenities[]`, `amenity_qty[]`, `unit_img`, `multi_img[]`.

---

## 5. Architectural Standards Compliance Checklist

- [x] **Region Structuring:** Explicit labeled `// region` and `// endregion` blocks in all models, repositories, controllers, and views.
- [x] **Common Widgets:** 100% adherence to `package:core/core.dart` widgets (`AppCommonAppBar`, `AppCommonTable`, `AppCommonButton`, `AppCommonTextField`, `AppCommonMultiSelectDropdown`, `AppCommonDialogBox`, `AppRefreshIndicator`, `CustomAppLoader`, `AppTablePagination`, `AppCommonExportButton`, `AppImageView`, `AppCommonBottomSheet`).
- [x] **Default Table Row Height:** Standard default `24.h` row height, dense cells (`2.h` vertical padding), compact action icons (`14.sp`).
- [x] **Color Tokens:** Zero hardcoded colors; all styling references `AppColors.*`.
- [x] **Typography Tokens:** Zero raw `TextStyle(...)`; all typography references `AppTextStyle.style_*_*`.
- [x] **Responsive Dimensions:** Full ScreenUtil integration (`.w`, `.h`, `.r`, `.sp`).
- [x] **State Management:** Controllers cleanly dispose all `TextEditingController` instances and cancel ongoing tasks in `onClose()`.
- [x] **RBAC Enforcement:** Dual-layer visual omission and tap execution guards on all actions.
- [x] **Dialog Layout Consistency:** Form fields match project-wide default UI with floating labels, `aliceBlue` background, `fieldBorderColor`, default widget heights, and responsive baseline-aligned rows.

---

## 6. Change Log

| Date | Author | Description |
|---|---|---|
| 2026-11-18 | Antigravity AI | Fixed Units Master & Unit Create/Edit form: added `+ Create Unit` button in `UnitScreen` action bar wired to `initCreateUnit()` and `AppRoutes.masterUnitEdit`; added `createUnit` API method and `createUnitSubmit()` / `submitUnit()` in `UnitController`; refined `UnitEditScreen` by adding `topHeader: const CommonShortcutHeader()` to `AppCommonAppBar`, removing the redundant inner breadcrumb and outer card wrapper, enforcing strict 2-in-a-row layout for all form rows, and miniaturizing the Amenities toggles (`26.w x 15.h`) and Qty boxes (`36.w x 24.h`) to prevent text truncation; updated `EditUnitManagerDialog` to strictly render 2 fields in a row. |
| 2026-11-18 | Antigravity AI | Updated Services Master (`ServiceScreen`, `ServiceItem`, `ServiceController`) to support `created_date` field from `service-index` API: added `createdDate` property and `formattedCreatedDate` getter (`dd-MMM-yyyy`) to `ServiceItem`; inserted sortable `Created Date` column after `Icon` column in `ServiceScreen` table; updated search filtering, column sorting, and Excel export in `ServiceController`. |
| 2026-11-18 | Antigravity AI | Implemented Units Master module: created `UnitMasterItem`, `UnitMasterListResponse`, and `UnitOptionsResponse` models; added repository methods for `unit-index`, `unit-options`, `unit-details-update`, and `unit-update`; developed `UnitController` with GPS geolocation via `Geolocator`, reactive filtering, sorting, pagination, and Excel export; built `UnitScreen` with dense `24.h` table and dual action buttons (1st: icon button for `EditUnitManagerDialog` quick updates; 2nd: `Edit` button for full `UnitEditScreen` form with single/multi-image upload and amenities configuration); registered routes `AppRoutes.masterUnits` and `AppRoutes.masterUnitEdit` in `app_pages.dart`. |
| 2026-11-12 | Antigravity AI | Initial module bootstrap: created `MasterRepository`, `ZoneItem` model, `ZoneController`, and `ZoneScreen` with dense data table, search in `AppCommonAppBar`, and Excel export. |
| 2026-11-12 | Antigravity AI | Integrated Master navigation into Home Grid (`HomeGridController`) and sidebar navigation (`CommonSidebar`) with routes for all 8 master sub-entities. |
| 2026-11-12 | Antigravity AI | Implemented State module: added `StateItem` model, state API methods in `MasterRepository`, `StateController`, and `StateScreen` with sorting, search, pagination, and Excel export. |
| 2026-11-12 | Antigravity AI | Standardized table pagination across Zone and State modules using mandatory `AppTablePagination`. |
| 2026-11-12 | Antigravity AI | Added confirmation dialogs (`AppCommonDialogBox.showConfirm`) before deactivating zones/states or deleting items. |
| 2026-11-12 | Antigravity AI | Added comprehensive loading indicators: screen-level `CustomAppLoader` overlays during toggle on/off and delete operations, plus button spinners and dialog overlays during create/edit. |
| 2026-11-12 | Antigravity AI | Refactored Add/Edit State dialog to standard default field UI: State Name (`AppCommonTextField`) positioned first, followed by Zone dropdown (`AppCommonMultiSelectDropdown<int>`) and Status toggle in the same row with matching `32.h` height and `aliceBlue` background. |
| 2026-11-13 | Antigravity AI | Established master module documentation (`documentation/master/MASTER.md`) under Rule 5 living documentation standard. |
| 2026-11-13 | Antigravity AI | Implemented District module: added `DistrictItem` model, repository CRUD operations (`district-index`, `district-create`, `district-update`, `district-delete`), `DistrictController` with reactive search, sorting, pagination, and Excel export, `DistrictScreen` adhering to default UI standard with District Name first, State dropdown & Status in same row, dense `24.h` table, confirmation dialogs, loader overlays, and wired route in `app_pages.dart`. |
| 2026-11-13 | Antigravity AI | Standardized default UI across State and District dialogs: aligned Status toggle to match dropdown input box baseline via `CrossAxisAlignment.end` and `Padding(bottom: 6.h)` while preserving native default widget dimensions. |
| 2026-11-13 | Antigravity AI | Implemented Services Master module: added `ServiceItem` and `ServiceListResponse` models, repository CRUD methods with multipart/form-data upload (`service-index`, `service-create`, `service-update`, `service-delete`), `ServiceController` with reactive search, sorting, pagination, and Excel export, `ServiceScreen` with dense `24.h` table, icon previews (`AppImageView`), image upload picker, and wired route in `app_pages.dart`. |
| 2026-11-14 | Antigravity AI | Implemented Amenities Master module: added `AmenityItem` and `AmenityListResponse` models, repository CRUD methods (`amenity-index`, `amenity-create`, `amenity-update`, `amenity-delete`), `AmenityController` with reactive search, sorting, pagination, and Excel export, `AmenityScreen` with dense `24.h` table, icon previews (`AppImageView`), single image camera/gallery picker (`AppCommonBottomSheet.showModal`), and wired route in `app_pages.dart`. |
| 2026-11-14 | Antigravity AI | Fixed Master Panel RBAC enforcement: wrapped Master module in `CommonSidebar` with `hasPerm(AppPermissions.masterPanel)`, added `permissionKey: AppPermissions.masterPanel` to Zones/Master `GridItemData` & subActions in `HomeGridController`, added explicit permission filtering in `_initGridItems()`, and standardized case-insensitive permission checks across all Master screens. |
| 2026-11-16 | Antigravity AI | Integrated full-screen image viewer (`AppImageView.showFullScreen`) with pinch-to-zoom interactive viewer, dark backdrop, and title header across master sub-modules (`ServiceScreen` & `AmenityScreen` table icons and add/edit preview cards). Synchronized live API contracts for `Amenity` CRUD operations and removed `SI No.` column from Amenity table. |
| 2026-11-16 | Antigravity AI | Updated `updateService` method to `POST` (from `PUT`) to match live API contract (`service-update`), pass compressed `serviceIcon` via `AppImageCompressor`, and maintain `id` as string in multipart form data. |

