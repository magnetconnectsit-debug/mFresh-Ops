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
│               ├── unit_create_edit_screen.dart
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

### 2.6 Units Master (`UnitScreen`), Unit Manager Details (`EditUnitManagerDialog`) & Unit Create / Edit (`UnitCreateEditScreen`)
- **Routes:**
  - Index: `AppRoutes.masterUnits` (`/master-units`) -> `UnitScreen`
  - Create / Edit: `AppRoutes.masterUnitCreateEdit` (`/master-unit-create-edit`) -> `UnitCreateEditScreen` (alias: `AppRoutes.masterUnitEdit`)
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
      - **2nd Action Button (Edit Button):** Compact bordered button (`22.h`) with `Icons.edit_outlined` and `Edit` text. Navigates to `UnitCreateEditScreen`.
  - **Edit Unit Manager Details Dialog (`EditUnitManagerDialog`):**
    - Modal popup with title and close ('X') icon, styled strictly with 2 fields in a row across mobile and tablet:
      - Row 1: `Highly Preferred` (`AppCommonMultiSelectDropdown<String>`) | `Timing` (`AppCommonTextField`).
      - Row 2: `Unit Address` (`AppCommonTextField`) | `Full Address` (`AppCommonTextField`).
      - Row 3: `Latitude` (`AppCommonTextField`) | `Longitude` (`AppCommonTextField`).
      - `Get Current Location` button powered by `Geolocator` to capture high-accuracy device GPS coordinates and prefill latitude/longitude.
      - `Cancel` and `Update` buttons calling `POST /public/api/unit-details-update`.
  - **Full Unit Create / Edit Screen (`UnitCreateEditScreen`):**
    - Standardized `AppCommonAppBar` with `topHeader: const CommonShortcutHeader()` and dynamic title (`Create Unit` or `Edit Unit`).
    - Zero redundant inner breadcrumbs and zero outer wrapper containers; uses direct responsive layout matching the reference web portal:
      - Row 1: `Unit Type` (`AppCommonMultiSelectDropdown<String>`, hint: `Select`) | `Service Type` (`AppCommonMultiSelectDropdown<String>`, hint: `Select`).
      - Row 2: `Service Name` (`AppCommonMultiSelectDropdown<String>`, hint: `Select`) | `Year of Delivery` (`AppCommonMultiSelectDropdown<String>`, hint: `Select`).
      - Row 3: `State` (`AppCommonMultiSelectDropdown<String>`, hint: `Select State`) | `District` (`AppCommonMultiSelectDropdown<String>`, hint: `Select District`).
      - Row 4: `Location` (`AppCommonTextField`) | `Timing` (`AppCommonTextField`).
      - Row 5: `Full Address` (`AppCommonTextField`, multiline).
      - Row 6: `Inauguration Date` (`AppCommonDateField`, wrapped in `Obx`).
      - Row 7: Image / Media Pickers: dual camera triggers (`Unit Image` and `Gallery Images`) with camera icons and count badges; tapping opens photo source bottom sheet (`Camera` / `Gallery`) matching the support tickets module pattern, with a horizontal thumbnail preview list and red delete (`X`) badges.
      - Row 8: **Amenities List:** Full-width vertical rows with toggle switch on the left, full amenity name in the middle (`style_12_500`), and compact right-aligned quantity box (`AppCommonTextField`, `52.w x 24.h`, hint `Qty`). When enabled, the field border highlights in orange (`#F15A24`) and remains empty for the user to specify; turning off clears the field.
      - Row 9: `Description` (`AppCommonTextField`, multiline) & `Specification` (`AppCommonTextField`, multiline).
    - Dropdowns default to unselected with placeholder hints during unit creation; district resets on state change.
    - `Cancel` and `Submit` / `Update` buttons calling `POST /public/api/unit-create` or `POST /public/api/unit-update` via multipart form data.
  - Search integrated into `AppCommonAppBar` (`showSearchBar: true`, debounced).
  - Table pagination powered by `AppTablePagination` with `startItem`, `endItem`, `totalItems`, `currentPage`, `totalPages`, `onPageChanged`.
  - Excel report export via `AppCommonExportButton` utilizing `AppExportUtils.exportToExcel`.
  - Full loading state overlays with `CustomAppLoader`.

### 2.7 Assign Services (`AssignServiceScreen` & `AssignServiceCreateEditScreen`)
- **Routes:**
  - Index: `AppRoutes.masterAssignServices` (`/master-assign-services`) -> `AssignServiceScreen`
  - Create / Edit: `AppRoutes.masterAssignServiceCreateEdit` (`/master-assign-service-create-edit`) -> `AssignServiceCreateEditScreen`
- **Controller:** `AssignServiceController`
- **Core Features:**
  - Standardized dense data table (`AppCommonTable<AssignUnitItem>`) adhering to default `24.h` row height and compact cell padding (`2.h`).
  - Action Bar: includes `+ Create Assign Service` button (`AppCommonButton`) guarded by `AppPermissions.masterPanel`, Excel export button (`AppCommonExportButton`), and total units badge.
  - Columns:
    - `Unit Image` (`75.w`, non-sortable): renders `AppImageView` with compact `22.r` dimensions and fallback icon `Icons.bathroom_outlined`.
    - `Unit` (`90.w`, sortable): displays QR code ID (`qrcodeId`).
    - `Model` (`140.w`, sortable): displays model category (`unitcategory`).
    - `City` (`80.w`, sortable): displays unit location city (`unitLocation`).
    - `Operating Hrs` (`180.w`, non-sortable): displays unit operating address/hours (`fullAdd`).
    - `Inauguration Date` (`110.w`, sortable): displays formatted date (`dd-MMM-yyyy`).
    - `Action` (`65.w`, non-sortable): compact bordered button (`22.h x 22.w`) with `Icons.edit_outlined`. Navigates to `AssignServiceCreateEditScreen` in edit mode.
  - **Create / Edit Assign Service Screen (`AssignServiceCreateEditScreen`):**
    - Standardized `AppCommonAppBar` with `topHeader: const CommonShortcutHeader()` and dynamic title (`Create Assign Service` or `Edit Assign Service (<unitQr>)`).
    - Card container with light shadow, rounded corners (`12.r`), and breadcrumb header (`Assign Services / Create` or `Assign Services / Edit`).
    - In Create Mode: Unit selector dropdown (`AppCommonMultiSelectDropdown<String>`).
    - Matrix Pricing Grid:
      - Light blue table header (`#E4EDF7`) with columns: `Services | Service For | Mode | Gross Price | GST | Net Amt | Charge Type | Order | [Status in Edit] | Action`.
      - Grouped service blocks: Left column contains service selector dropdown and centered icon preview (`AppImageView`, `44.r`).
      - 4 default matrix rows per service:
        - `Customer` | `Offline` (with banknote icon in green)
        - `Customer` | `Online` (with credit card / POS icon in red)
        - `Members` | `Offline` (with banknote icon in green)
        - `Members` | `Online` (with credit card / POS icon in red)
      - Inputs: Gross Price, GST %, Net Amt (auto-calculated in real time via reverse tax formula: `Net = Gross / (1 + (GST / 100))`), Charge Type (default `Use`), Order number, and Status (`Active` / `Inactive` in edit mode).
      - Action controls: `+` button to add new service groups in create mode, `-` button to remove service groups in edit mode, plus `+ Add Service` button in edit mode.
    - Submit actions: Orange `Save` button calling `POST /public/api/assign-service-create` in create mode; orange `Update` button calling `POST /public/api/assign-service-update` in edit mode.
  - Table pagination powered by `AppTablePagination` with `startItem`, `endItem`, `totalItems`, `currentPage`, `totalPages`, `onPageChanged`.
  - Excel report export via `AppCommonExportButton` utilizing `AppExportUtils.exportToExcel`.
  - Full loading state overlays with `CustomAppLoader`.

### 2.8 All Assign Services (`AllAssignServiceScreen`)
- **Route:** `AppRoutes.masterAllAssignServices` (`/master-all-assign-services`)
- **Controller:** `AllAssignServiceController`
- **Core Features:**
  - Standardized dense data table (`AppCommonTable<AllAssignServiceItem>`) adhering to default `24.h` row height and compact cell padding (`2.h`).
  - Action Bar: `+ Create Assign Service` button (`AppCommonButton`) guarded by `AppPermissions.masterPanel`, Excel export button (`AppCommonExportButton`), and total records count badge.
  - Columns:
    - `Unit ID's` (`75.w`, sortable): QR code identifier (`assqrcodeId`).
    - `Service name` (`115.w`, sortable): service title (`servicesName`).
    - `Service For` (`80.w`, sortable): target audience (`Customer` / `Membership`).
    - `Pay Type` (`75.w`, sortable): payment mode (`Offline` / `Online`).
    - `Price` (`65.w`, sortable, center): gross price.
    - `GST (%)` (`65.w`, sortable, center): tax percentage (`gstpercent`).
    - `Net Price` (`70.w`, sortable, center): net revenue price.
    - `Uses` (`65.w`, sortable): billing duration/unit (`Use`, `hour`, `30 min`, `Set`).
    - `Status` (`65.w`, sortable): text indicator (`Active` / `Inactive`).
    - `Toggle` (`95.w`, center): reactive switch with confirmation guard (`AppCommonDialogBox.showConfirm`) when deactivating active services.
    - `Action` (`55.w`, center): compact edit icon button calling `controller.editUnitAssignService(item)`, which preloads the unit's complete service configuration into `AssignServiceCreateEditScreen`.
  - App bar search filtering across unit ID, service name, audience, payment mode, price, and status.
  - Table pagination powered by `AppTablePagination` with `startItem`, `endItem`, `totalItems`, `currentPage`, `totalPages`, `onPageChanged`.
  - Excel report export via `AppCommonExportButton` utilizing `AppExportUtils.exportToExcel`.
  - Full loading state overlays with `CustomAppLoader`.

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

### 4.7 Assign Service Endpoints
- **Index:** `GET` `AppConstants.assignsIndex` (`public/api/assigns-index`)
  - Response: Retail assigned units with `id`, `qrcodeId`, `unit_img_url`, `unitcategory`, `unit_location`, `ing_date`, `full_add`, `assignments` (nested list of services and row configurations: `row_id`, `services_for`, `pay_type`, `gross_price`, `gst`, `net_amount`, `uses`, `order`, `status`), and `edit_payload` (pre-formatted update payload).
- **Assign Service Create:** `POST` `AppConstants.assignServiceCreate` (`public/api/assign-service-create`)
  - Content-Type: `application/json`
  - Payload:
    ```json
    {
      "assignqrId": "MM25001",
      "service_id": [25],
      "services_for": [0, 0, 1, 1],
      "pay_type": [1, 2, 1, 2],
      "gross_price": [100, 120, 80, 90],
      "gst": [5, 5, 5, 5],
      "uses": ["Use", "hour", "30 min", "Set"],
      "order": ["1", "2", "3", "4"]
    }
    ```
- **Assign Service Update:** `POST` `AppConstants.assignServiceUpdate` (`public/api/assign-service-update`)
  - Content-Type: `application/json`
  - Payload:
    ```json
    {
      "assignqrId": "m2",
      "service_id": [1, 10],
      "rows_per_service": [5, 4],
      "row_id": [9, 46, 109, 188, 189, 29, 53, 202, 203],
      "services_for": [0, 0, 0, 1, 1, 0, 0, 1, 1],
      "pay_type": [2, 2, 1, 2, 1, 1, 2, 2, 1],
      "gross_price": ["50", "80", "50", "30", "30", "120", "120", "100", "100"],
      "gst": [0, 0, 0, 0, 0, 18, 18, 18, 18],
      "net_amount": ["50.00", "80.00", "50", "30", "30", "101.69", "101.69", "84.75", "84.75"],
      "uses": ["Use", "Use", "Use", "Use", "Use", "Use", "Use", "Use", "Use"],
      "order": ["1", "1", "1", "1", "1", "7", "7", "8", "8"],
      "status": [1, 0, 1, 1, 1, 1, 1, 1, 1]
    }
    ```
      "services_for": [0, 0, 1, 1],
      "pay_type": [1, 2, 1, 2],
      "gross_price": [100, 120, 80, 90],
      "gst": [5, 5, 5, 5],
      "net_amount": [95, 114, 76, 85.5],
      "uses": [1, 1, 1, 1],
      "order": [1, 2, 3, 4],
      "status": [1, 1, 1, 0]
    }
    ```

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
| 2026-11-20 | Antigravity AI | Resolved interchanged Service Name / Service Type dropdown items in `UnitCreateEditScreen`: wired `Service Name` to `options.serviceNames` (`Movable` / `Fixed`) and `Service Type` to `options.serviceTypes` (`Retail` / `Rental`) with search bar (`showSearch: true`); created dedicated `YearPickerField` (`packages/shared/core/lib/widgets/year_picker_field.dart`) with decade navigation and 12-year grid for pure year selection (eliminating month picker modal); upgraded `Timing` field across `UnitCreateEditScreen` and `EditUnitManagerDialog` to `AppCommonTimeField` matching `CreateTaskScreen` with 12-hour clock format, tap-anywhere trigger, and uniform `aliceBlue` container styling. |
| 2026-11-20 | Antigravity AI | Resolved interchanged Service Name / Service Type dropdown items in `UnitCreateEditScreen`: wired `Service Name` to `options.serviceNames` (`Movable` / `Fixed`) and `Service Type` to `options.serviceTypes` (`Retail` / `Rental`) with search bar (`showSearch: true`); created dedicated `YearPickerField` (`packages/shared/core/lib/widgets/year_picker_field.dart`) with decade navigation and 12-year grid for pure year selection (eliminating month picker modal); upgraded `Timing` field across `UnitCreateEditScreen` and `EditUnitManagerDialog` to `AppCommonTimeField` matching `CreateTaskScreen` with 12-hour clock format, tap-anywhere trigger, and uniform `aliceBlue` container styling. |
| 2026-11-20 | Antigravity AI | Eliminated edit navigation delay and redundant network calls in `AllAssignServiceController` and `AssignServiceScreen`: added synchronous in-memory initializers `initForEditFromUnitAssignments` and `initForEditFromAllAssignServiceItems` in `AssignServiceController`, removed blocking `await` on network call before `Get.toNamed`, reused existing in-memory rows from `assignedServices` when editing from `AllAssignServiceScreen`, and ensured immediate screen transition on tap. |
| 2026-11-20 | Antigravity AI | Enhanced Assign Service models, repositories, and controllers with full `GET /public/api/assigns-index` structure: added `assignments` (nested services with rows: `row_id`, `services_for`, `pay_type`, `gross_price`, `gst`, `net_amount`, `uses`, `order`, `status`) and `edit_payload` to `AssignUnitItem`, added string `usesText` to `AssignedServiceRow` to preserve textual charge types, updated `MasterRepository` create and update methods to support string charge types and orders matching API contracts, and enhanced `AssignServiceController.loadAndInitForEdit` to instantly populate service matrix rows directly from unit assignments without secondary API calls. |
| 2026-11-19 | Antigravity AI | Implemented `All Assign Services` screen (`AllAssignServiceScreen`) and controller (`AllAssignServiceController`): integrated `GET /public/api/assign-services-index` endpoint, added models `AllAssignServiceItem` and `AllAssignServicesResponse`, constructed dense table with 11 columns matching reference UI (`Unit ID's`, `Service name`, `Service For`, `Pay Type`, `Price`, `GST (%)`, `Net Price`, `Uses`, `Status`, `Toggle`, `Action`), added reactive toggle switch with confirmation dialog on deactivation, wired action button to pre-populate unit services and open `AssignServiceCreateEditScreen`, added Excel export and pagination, and registered route `AppRoutes.masterAllAssignServices`. |
| 2026-11-19 | Antigravity AI | Cleared default values for `Gross Price`, `GST`, and `Net Amt` fields in `AssignServiceCreateEditScreen` and `AssignServiceController`: changed initial controller values and `hintText` to completely blank (`''`, removing all default `'0'`), updated real-time reverse tax net calculation to remain completely blank when gross price is empty, safely defaulted empty fields during API synchronization, and adjusted service group divider width to full table width (`870.w` in edit mode, `775.w` in create mode). |
| 2026-11-19 | Antigravity AI | Cleared default values for `Charge Type` and `Order` fields in `AssignServiceCreateEditScreen`: removed prefilled `'Use'` and `'1'`/`'2'`/`'3'`/`'4'` text across matrix rows, leaving them completely blank by default (`initialValue: ''`, `hintText: ''`) in both create mode and dynamic group additions. |
| 2026-11-19 | Antigravity AI | Implemented Assign Service Module: added `assignsIndex`, `assignServiceCreate`, `assignServiceUpdate` endpoints in `AppConstants`; created models `AssignUnitItem`, `AssignsIndexResponse`, `AssignedServiceRow`, `AssignedServiceGroup` in `assign_service_model.dart`; added repository methods `getAssignsIndex`, `createAssignService`, `updateAssignService` in `MasterRepository`; created `AssignServiceController` with reactive search, sorting, pagination, Excel export, dynamic matrix cell controllers and real-time net amount auto-calculation via reverse tax formula; designed `AssignServiceScreen` with dense `24.h` table and edit action; designed `AssignServiceCreateEditScreen` with responsive service matrix grid matching web reference images for both create and edit modes with icon previews and status toggles; registered routes `AppRoutes.masterAssignServices` and `AppRoutes.masterAssignServiceCreateEdit` in `app_routes.dart` and `app_pages.dart`. |
| 2026-11-19 | Antigravity AI | Added `Inauguration Date` field (`AppCommonDateField`) to `UnitCreateEditScreen` below Full Address, wired to `editIngDate` in `UnitController`. |
| 2026-11-19 | Antigravity AI | Updated `AssignServiceCreateEditScreen`: removed duplicate inner `Create Assign Service` header row inside the card (leaving single title in `AppCommonAppBar`), added full-width horizontal divider (`width: tableWidth, height: 2.h, color: Colors.black`) separating assigned service blocks in the table, added delete option (`[-]`) for mistakenly added or additional service groups in Create mode and all groups in Edit mode, and integrated confirmation dialog guard (`AppCommonDialogBox.showConfirm`) before deleting any assigned service group. |
| 2026-11-20 | Antigravity AI | Updated `UnitCreateEditScreen` and `UnitController`: replaced hardcoded `Year of Delivery` dropdown with mandatory `MonthYearPickerField` supporting 'MMM-yyyy' selection and seamless year parsing; updated `Timing` field to default to `DateTime.now()` formatted ('hh:mm a') on unit creation and added tap-to-pick `showTimePicker` suffix clock icon across `UnitCreateEditScreen` and `EditUnitManagerDialog`. |
| 2026-11-20 | Antigravity AI | Fixed Units Master data parsing & table rendering: mapped live `unit-index` API payload response keys in `UnitMasterItem.fromJson` (`unit_code` -> `qrcodeId`, `unit_type` -> `unitcategory`, `service_type`/`service_name` -> `servicetype`, `location` -> `unitLocation`, `full_address` -> `fullAdd`, `timing` -> `openTiming`, `image_url` -> `unitImgUrl`, `qr_image_url` -> `qrImageUrl`, `gallery_image_urls` -> `galleryUrls`, `highly_preferred` boolean/string parser), restoring Unit Image thumbnails, Unit Code, Model, City, Operating Hrs, and Inauguration Date cells across `UnitScreen`. |
| 2026-11-19 | Antigravity AI | Brought `UnitCreateEditScreen` and `UnitController` into 100% compliance with engineering rules: enforced complete `// region` and `// endregion` block structure (Rule 1); strictly eliminated raw colors in favor of `AppColors.*` tokens and ScreenUtil extensions across all dimensions (Rule 2); implemented dual-level RBAC permission enforcement checking `AppPermissions.masterPanel` at UI and action handler execution layers (Rule 3); resolved controller leak in `build()` by delegating quantity controllers to `UnitController.getAmenityQtyController` with lifecycle disposal (Rule 4). |
| 2026-11-20 | Antigravity AI | Integrated full-view image viewer on tap for table rows: clicking unit image thumbnails in `UnitScreen` opens the interactive gallery viewer (`AppImageView.showGalleryViewer`) enabling full-screen review and horizontal scrolling across the unit's photos and gallery attachments; wired full-screen preview in `AssignServiceScreen`. |
| 2026-11-20 | Antigravity AI | Separated Unit Image and Gallery Images in `UnitCreateEditScreen` into distinct side-by-side columns; added image stack overlay (`+N`) when more than 2 gallery images are present; built scrollable full-screen interactive gallery viewer (`AppImageView.showGalleryViewer`) with horizontal paging (`PageView`), pinch-to-zoom (`InteractiveViewer`), image counter, previous/next buttons, and delete support; updated amenity initialization to explicitly preserve and display `0` (instead of blank) when quantity is zero. |
| 2026-11-19 | Antigravity AI | Restored `Description` and `Specification` multiline fields in `UnitCreateEditScreen` below the Amenities section wired to `editDescCtrl` and `editSpecCtrl`. |
| 2026-11-19 | Antigravity AI | Reduced vertical height and spacing across `UnitCreateEditScreen`: tightened form section gaps from `12.h` to `10.h`, reduced amenities list item separator from `8.h` to `4.h`, and optimized quantity input field height to dense `24.h` standard with `style_11_500`. |
| 2026-11-19 | Antigravity AI | Updated Amenities quantity field in `UnitCreateEditScreen`: enabled state leaves the field empty with hint `Qty` for user entry (does not autofill `1`) and dynamically highlights the border in orange (`#F15A24`, width 1.4); added `borderColor` and `borderWidth` props to `AppCommonTextField`. |
| 2026-11-19 | Antigravity AI | Moved image picker section below `Full Address` in `UnitCreateEditScreen` and replaced the large cards with dual camera icon triggers (`Unit Image` & `Gallery Images`) with badges and a camera/gallery bottom sheet selector matching `CreateTicketScreen`; added horizontal preview list with delete buttons; enhanced `UnitController.pickSingleImage` and `pickMultiImages` to support explicit `ImageSource` selection (Camera / Gallery). |
| 2026-11-19 | Antigravity AI | Aligned `UnitCreateEditScreen` field order and layout strictly with reference UI: ordered fields into Row 1 (`Unit Type` / `Service Type`), Row 2 (`Service Name` / `Year of Delivery`), Row 3 (`Image` / `Images`), Row 4 (`State` / `District`), Row 5 (`Location` / `Timing`), and Row 6 (`Full Address`); removed extraneous `Inauguration Date`, `Description`, and `Specification` fields; converted Amenities section into vertical full-width rows with left toggle switch, un-truncated middle amenity label, and right-aligned `Qty` input box with hint `Qty`. |
| 2026-11-19 | Antigravity AI | Renamed `UnitEditScreen` to `UnitCreateEditScreen` (`unit_create_edit_screen.dart`), updated routes (`AppRoutes.masterUnitCreateEdit`), verified `AppTablePagination` contracts on `UnitScreen`, enforced strict 2-in-a-row layout in `EditUnitManagerDialog`, removed redundant inner breadcrumb and outer card wrapper in `UnitCreateEditScreen`, restored `topHeader: const CommonShortcutHeader()`, ensured dropdowns default to unselected with placeholder hints during unit creation, and miniaturized amenities switches (`20.w x 12.h`) and quantity boxes (`26.w x 20.h`) with 2-line wrapped text labels to completely eliminate truncation. |
| 2026-11-19 | Antigravity AI | Updated Create Unit form dropdown defaults: ensure nothing is selected by default in any dropdown (Unit Type/Category, Service Type, Service Name, Year of Delivery, State, District) by initializing state observables to empty strings and clearing fallback selections; updated district cascading to reset whenever state changes. |
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

