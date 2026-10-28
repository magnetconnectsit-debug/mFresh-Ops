# Selfie Attendance Module Documentation

> **Package:** `packages/apps/mfresh_ops`  
> **Module:** Selfie Attendance (`lib/modules/selfie_attendance/`)  
> **Last Updated:** 2026-10-23  
> **Maintainer:** Banamali Nayak

---

## 1. Overview
The Selfie Attendance submodule is part of the Attendance & Tracking suite in `mFresh-Ops`. It tracks employee shift attendance via geo-tagged selfie captures at check-in and check-out, calculates working duration, break durations, and provides a daily log breakdown with interleaved break timelines and map locations.

---

## 2. API Specifications

### 2.1 Selfie Attendance Report List
* **Endpoint:** `POST /public/api/selfie-attendance/index?page={page}`
* **Headers:** `Accept: application/json`, `Content-Type: application/json`, `Authorization: Bearer <token>`
* **Request Payload Structure:**
```json
{
  "from_date": "2026-10-21",
  "to_date": "2026-10-23",
  "unit_id": [18],
  "user_id": [58],
  "global_search": ""
}
```
* **Response Payload Structure:**
```json
{
  "status": true,
  "message": "Selfie Attendance Report",
  "filters": {
    "from_date": "",
    "to_date": "",
    "unit_id": [],
    "user_id": [],
    "global_search": ""
  },
  "data": {
    "current_page": 1,
    "data": [
      {
        "user_id": "108",
        "user_name": "Sradhanjali Patra",
        "date": "23-Oct-2026",
        "date_iso": "2026-10-23",
        "units": "m2",
        "first_in": "11:30 AM",
        "last_out": "—",
        "total_duration": "—",
        "break_duration": "00:00:00",
        "actual_duration": "00:00:00",
        "total_duration_seconds": null,
        "break_seconds": 0,
        "actual_duration_seconds": 0,
        "total_sessions": 1,
        "completed_sessions": 0,
        "open_sessions": 1
      }
    ],
    "first_page_url": "...",
    "from": 1,
    "last_page": 1,
    "per_page": 25,
    "to": 6,
    "total": 6
  }
}
```

---

### 2.2 Selfie Attendance Check-in / Check-out Logs (Detail)
* **Endpoint:** `POST /public/api/selfie-attendance/logs`
* **Headers:** `Accept: application/json`, `Content-Type: application/json`, `Authorization: Bearer <token>`
* **Request Payload Structure:**
```json
{
  "user_id": 58,
  "date": "21-Oct-2026",
  "unit_id": []
}
```
* **Response Payload Structure:**
```json
{
  "status": true,
  "message": "Selfie Attendance Logs",
  "data": {
    "user": {
      "id": 58,
      "name": "Banamali Nayak"
    },
    "date": "21-Oct-2026",
    "date_iso": "2026-10-21",
    "summary": {
      "units": "MM2500DEV",
      "first_in": "05:01 PM",
      "last_out": "05:22 PM",
      "total_duration": "00:20:13",
      "break_duration": "00:19:38",
      "actual_duration": "00:00:35",
      "total_duration_seconds": 1213,
      "break_seconds": 1178,
      "actual_duration_seconds": 35,
      "total_sessions": 2,
      "completed_sessions": 2,
      "open_sessions": 0,
      "logs": [
        {
          "attendance_id": 1,
          "unit_id": "18",
          "unit_name": "MM2500DEV",
          "check_in_at": "2026-10-21 17:01:48",
          "check_in_time": "21-Oct-2026 05:01 PM",
          "checkout_at": "2026-10-21 17:02:09",
          "checkout_time": "21-Oct-2026 05:02 PM",
          "break_before_seconds": 0,
          "break_before": "00:00:00",
          "duration_seconds": 21,
          "duration": "00:00:21",
          "check_in_image": "1792582307_rBVWgLFDAy.jpg",
          "checkout_image": "1792582329_YwHMAMk8yl.jpg",
          "check_in_image_url": "https://magnetconnects.com/public/images/employee_attendance/checkin/1792582307_rBVWgLFDAy.jpg",
          "checkout_image_url": "https://magnetconnects.com/public/images/employee_attendance/checkout/1792582329_YwHMAMk8yl.jpg",
          "check_in_latitude": "20.3435638",
          "check_in_longitude": "85.8221672",
          "checkout_latitude": "20.3435633",
          "checkout_longitude": "85.8221671",
          "check_in_map_url": "https://www.google.com/maps?q=20.3435638,85.8221672",
          "checkout_map_url": "https://www.google.com/maps?q=20.3435633,85.8221671"
        }
      ]
    }
  }
}
```

---

## 3. Architecture & File Structure

```
lib/
├── core/constants/
│   └── app_constants.dart             # Added selfieAttendanceIndex & selfieAttendanceLogs
├── routes/
│   ├── app_routes.dart                # Added selfieAttendanceReport & selfieAttendanceDetail
│   └── app_pages.dart                 # Registered GetPage with bindings
├── widgets/
│   └── common_sidebar.dart            # Sub-item under Attendance
├── data/
│   ├── models/selfie_attendance/
│   │   ├── selfie_attendance_report_model.dart
│   │   └── selfie_attendance_logs_model.dart
│   └── repositories/
│       └── selfie_attendance_repository.dart
└── modules/selfie_attendance/
    ├── bindings/
    │   └── selfie_attendance_binding.dart
    ├── controllers/
    │   ├── selfie_attendance_controller.dart
    │   └── selfie_attendance_detail_controller.dart
    └── views/
        ├── selfie_attendance_report_screen.dart
        ├── selfie_attendance_detail_screen.dart
        └── widgets/
            ├── selfie_attendance_filter_bar.dart
            ├── selfie_attendance_report_table.dart
            ├── selfie_attendance_detail_table.dart
            └── selfie_image_preview_dialog.dart
```

---

## 4. UI & UX Features

### 4.1 Selfie Attendance Report
* **Header & Badge:** Displays "Selfie Attendance Report" with a pill badge `Data: {count}`.
* **Standard Filter Container:**
  * Implemented using the standardized card container architecture (`AppColors.white`, `borderRadius: 12.r`, `boxShadow`).
  * Features a "Filters" header with conditional "Reset All" action.
  * Responsive `GridView` (`crossAxisExtent: 28.h`, `crossAxisCount: isMobile ? 2 : 4`) housing:
    * Date range picker (`InputDecorator` with floating label & calendar icon).
    * `AppCommonMultiSelectDropdown` for `Select User` with Select All & search.
    * `AppCommonMultiSelectDropdown` for `Select Unit` with Select All & search.
    * `Apply` and `Reset` action buttons (`AppCommonButton` with `28.h` height).
  * Dynamic active filter chips row below the grid with individual remove triggers.
* **Data Table:**
  * Uses `AppCommonTable` with the standardized default row height of `24.h` and compact cell padding (`2.h`).
  * Column sorting for `Employee`, `Date`, `Unit(s)`, `First In`, `Last Out`, `Total Duration`, `Break`, `Actual Duration`, and `Sessions`.
  * Distinct soft yellow cell styling (`#FEF9C3`) for the `Break` duration column.
  * Compact "Logs" action button with eye icon leading directly to the detailed log page.
  * Pagination via `AppTablePagination` with item count label.

### 4.2 Selfie Attendance Report Detail
* **Summary Cards / Fields:**
  * Top metrics configured in 2 horizontal rows using `AppCommonTextField` with `readOnly: true`:
    * Row 1: `Employee`, `Date`, `Unit(s)`, `First In`, `Last Out`
    * Row 2: `Total Duration`, `Break Duration`, `Actual Duration`, `Total Sessions`, `Completed / Open`
* **Log Table:**
  * Adheres to the standardized default row height of `24.h` for header and session rows (`20.h` for break dividers).
  * Shows session rows: `Sl No.`, `Unit`, `Check-in Time`, `Check-in Selfie`, `Check-in GPS`, `Check-out Time`, `Check-out Selfie`, `Check-out GPS`, `Break Before`, `Actual Duration`.
  * **Interleaved BREAK Banners:** Visual `#FEF9C3` yellow divider rows positioned dynamically between sessions.
  * **Selfie Previews & Location:** Compact thumbnail previews (`16.r`) next to "View", tapping opens `SelfieImagePreviewDialog` with zoom & full view, showing user name, timestamp, and human-readable reverse-geocoded location resolved using Google Maps Geocoding API (`AppConfig.googleMapsApiKey`), with an action to launch Google Maps externally.
  * **Map Navigation:** Clickable `Map` label with pin icon launches external Google Maps using coordinates or map URLs via `url_launcher`.
  * **Daily Total Footer:** Dedicated summary row at bottom (`24.h`) displaying daily break duration and actual worked duration.

---

## 5. Permissions & Routing

* **Route Names:**
  * `AppRoutes.selfieAttendanceReport` -> `/selfie-attendance-report`
  * `AppRoutes.selfieAttendanceDetail` -> `/selfie-attendance-detail`
* **RBAC Gateways:**
  * Menu access guarded by `AppPermissions.selfieAttendance` (`selfie_attendance`).

---

## 6. Change Log

| Date | Author | Description |
|---|---|---|
| 2026-10-23 | Antigravity AI | Initial creation of the Selfie Attendance submodule (Report & Detail Views, Models, Repository, Controllers, Bindings, and UI Widgets). |
| 2026-10-23 | Antigravity AI | Standardized Filter Container to match other modules (card container, 28.h grid, active filter chips) and updated table row heights to default 24.h as per rules.md. |
| 2026-10-23 | Antigravity AI | Removed redundant body title and moved report title + Data badge into AppCommonAppBar; adjusted filter container vertical alignment and spacing using responsive CrossAxisAlignment.end rows; removed redundant Reset button in favor of header 'Reset All' link; added Selfie Attendance to Home Grid subActions under Attendance. |
| 2026-10-23 | Antigravity AI | Full architectural compliance refactor: refactored Detail Table to mandatory AppCommonTable with 24.h rows, eliminated all hardcoded colors across module to AppColors.*, standardized pagination, decoupled controller props with Get.find, and brought all 8 module files into 100% compliance with strict labeled region blocks. |
| 2026-10-23 | Antigravity AI | Updated Selfie Attendance Detail Screen _buildSummaryCards to use AppCommonTextField with readOnly: true and managed TextEditingControllers in controller lifecycle. |
| 2026-10-23 | Antigravity AI | Aligned Summary Cards into responsive multi-column layout with 3-in-a-row grid presentation (and 2-in-a-row on narrow screens). |
| 2026-10-23 | Antigravity AI | Restored standard default AppCommonTextField UI styling (no custom color, border, or style overrides; clean title-cased labels). |
| 2026-10-23 | Antigravity AI | Added location resolution in SelfieImagePreviewDialog via GeocodingService with Google Maps API key reverse geocoding and external map launcher. |
| 2026-10-23 | Antigravity AI | Integrated `all_units`/`allUnits` payload parsing for selfie attendance reports and summaries; enabled filter auto-apply on date range, user, and unit changes; added support units fallback in controller; updated AppCommonTable and selfie attendance tables with single-line text ellipsis and dynamic row expansion on click. |
| 2026-10-23 | Antigravity AI | Configured dedicated `selfie_attendance` permission key in AppPermissions, CommonSidebar, and HomeGridController to govern visual rendering and execution-layer tap guards. |
| 2026-10-23 | Antigravity AI | Removed redundant Apply button from Selfie Attendance filter bar; restructured responsive filter layout to cleanly accommodate Date Range, User, and Unit fields with instantaneous auto-filtering. |
| 2026-10-24 | Antigravity AI | Implemented custom selfie check-in / check-out camera viewfinder overlay (`AppSelfieCameraOverlay`): featuring wood background texture, top `mFresh` logo (`app_logo.png`), dashed white person silhouette outline (head circle and upper torso/uniform boundary), and red guidance notice text; integrated seamlessly with `AppCameraScreen` preview and live decorators. |
| 2026-10-24 | Antigravity AI | Refined `AppSelfieCameraOverlay`: enlarged top brand logo to prominent `80.h` with rounded bounds, eliminated the dividing wood bridge and horizontal cross lines between head and torso into a unified, seamless person silhouette (head arc flowing continuously into neck, shoulders, and arms), and elevated warning text above zoom controls. |
| 2026-10-24 | Antigravity AI | Replaced wooden background texture with a clean square viewfinder box and semi-transparent dark outer scrim; centered white dashed human silhouette contour inside the square box; fixed vertical text wrapping bug by correctly insetting instruction capsule across screen width with `softWrap: false` and positioned it cleanly below the viewfinder box above camera controls. |
| 2026-10-24 | Antigravity AI | Styled the square viewfinder frame as 4 camera autofocus corner brackets (`┌ ┐ └ ┘`) with rounded corner arcs, drop shadow, and clean focus aesthetic while preserving the white dashed human silhouette inside. |
| 2026-10-24 | Antigravity AI | Converted camera to 100% full-screen presentation (`CameraPreviewFit.cover`, `CameraAspectRatios.ratio_16_9`, edge-to-edge `Scaffold.body` with `SafeArea` isolated to top and bottom controls); resolved missing `mFresh Board` text by fixing `Positioned` horizontal inset calculation (`left: 0, right: 0` with `Center`), positioning the badge directly across the top focus corner line; calibrated geometry to `top: 80.h` with dual-zone person silhouette below and high-contrast shadowed dashed outlines. |
| 2026-10-24 | Antigravity AI | Reshaped person silhouette from geometric circle to anatomical human oval head (1.28:1 height-to-width ratio with natural chin/jaw curve) and shortened torso to terminate 55.h below the shoulder crest, maintaining a compact bust guide and opening the lower camera viewfinder. |
| 2026-10-24 | Antigravity AI | Lowered body placement into natural central selfie framing zone (`headTopY: ~210.h`, `signboardRect.top: 70.h`) and sculpted realistic human head contour with cranial dome, temple indentations, cheekbone contours, and tapered jawline (eliminating generic egg oval). |
| 2026-10-24 | Antigravity AI | Substantially enlarged human head and silhouette dimensions by ~50% (`headHeight: 235.h`, cheek width: ~58% of screen) to comfortably frame human face at normal, natural handheld selfie distance without requiring full arm hyperextension. |
| 2026-10-24 | Antigravity AI | Calibrated silhouette to realistic human proportions (`headHalfWidth: 80.w`, `headHeight: 195.h`, `neckHalfWidth: 42.w` - 52.5% neck-to-head ratio), eliminating oversized alien bulb head while providing balanced, natural facial framing. |
| 2026-10-24 | Antigravity AI | Softened head shape to a clean, subtle gentle oval (height:width ratio 1.15:1, `headRadiusX: ~86.w`, `headRadiusY: ~100.h`) with continuous seamless ellipse arc flowing into neck and shoulders, achieving a natural face silhouette without exaggeration. |
| 2026-10-24 | Antigravity AI | Implemented exact visual styling from user reference mockup: neon green corner brackets on signboard box (`#22C55E`) and shoulder tips, white dashed connecting lines, natural ear contour profile, red 'm' logo on top `mFresh Board` pill, dedicated `Face & shoulders` center pill, and `Face, uniform & board should be visible` guidance notice. |
| 2026-10-24 | Antigravity AI | Aligned silhouette geometry with user reference image: enlarged face area with generous ear-to-ear span (`earHalfWidth: 0.31 * width`, ~250.w total width), natural ear contours, broad realistic neck (`0.17 * width`), expanded height spanning from below signboard box down to guidance pill, and centered `Face & shoulders` badge directly across lower chest/shoulders. |
| 2026-10-24 | Antigravity AI | Fixed top-right green focus corner bracket drawing bug in `_SelfieViewfinderPainter` (`_drawBoxCorners`) by correcting vertical right-edge endpoint from horizontal offset to `(rect.right, rect.top + cornerLen)`; removed default `1.0X` zoom slider in selfie mode via `middleContentBuilder: (state) => const SizedBox.shrink()`. |
| 2026-10-25 | Antigravity AI | Removed two-shade scrim darkening (`scrimPaint` mask with cutouts) from `AppSelfieCameraOverlay` to keep lighting natural and uniform across both inside and outside the camera viewfinder area while preserving dashed borders, focus corners, and guide badges. |
| 2026-10-26 | Antigravity AI | Removed `AppSelfieCameraOverlay` from `_buildPreviewView` in `AppCameraScreen` so captured photo preview is displayed clean without outline borders, focus brackets, or guide badges. |
