# Inventory Module Documentation

> **Package:** `packages/apps/mfresh_ops`  
> **Module:** Inventory (`lib/modules/inventory/`)  
> **Last Updated:** 2026-10-23  

---

## 1. Overview
The Inventory module manages stores, stock entries, allotments, consumptions, and inventory audits across retail/service units. This includes audit report tracking and unit-wise audit comparison matrices.

---

## 2. API Specifications

### 2.1 Date-Wise Inventory Audits List
* **Endpoint:** `GET /public/api/inventory-audits`
* **Headers:** `Accept: application/json`, `Content-Type: application/json`, `Authorization: Bearer <token>`
* **Query Parameters:**
  * `audit_number` (optional, string)
  * `page` (optional, int)
* **Body / Filters:**
  * `unit_id` (list of int)
  * `audited_by` (list of int)
  * `from_date` (string `YYYY-MM-DD`)
  * `to_date` (string `YYYY-MM-DD`)
* **Response Payload Structure:**
```json
{
  "status": true,
  "message": "Date-wise inventory audits fetched successfully.",
  "unit_options": [{"id": 1, "name": "m1"}],
  "auditor_options": [{"id": 45, "name": "Alluri Praveen"}],
  "pagination": {
    "current_page": 1,
    "per_page": 25,
    "total": 27,
    "last_page": 2
  },
  "data": [
    {
      "id": 128,
      "representative_id": 128,
      "audit_number": "AUD-000128",
      "audit_day": "2026-10-22",
      "audit_date_display": "22-Oct-2026",
      "day_name": "Thursday",
      "audit_count": 3,
      "unit_count": 3,
      "unit_names": "m2, m3, m4",
      "units": [
        {
          "audit_id": 128,
          "audit_number": "AUD-000128",
          "unit_id": 5,
          "unit_name": "m2",
          "audit_date": "2026-10-22 19:30:36"
        }
      ]
    }
  ]
}
```

### 2.2 Date-Wise Inventory Audit Comparison Details
* **Endpoint:** `POST /public/api/inventory-audits-details`
* **Headers:** `Accept: application/json`, `Content-Type: application/json`, `Authorization: Bearer <token>`
* **Body:**
```json
{
  "audit_id": 128
}
```
* **Response Payload Structure:**
```json
{
  "status": true,
  "message": "Date-wise inventory audit comparison fetched successfully.",
  "data": {
    "audit_id": 128,
    "audit_number": "AUD-000128",
    "day": "2026-10-22",
    "date_display": "22-Oct-2026",
    "total_units": 3,
    "unit_names": "m2, m3, m4",
    "unitList": [
      {
        "id": 128,
        "audit_id": 128,
        "audit_number": "AUD-000128",
        "unit_id": 5,
        "unit_name": "m2",
        "audit_date": "2026-10-22 19:30:36",
        "audit_date_display": "22-Oct-2026 07:30 PM",
        "auditor_name": "Ranjan Dash"
      }
    ],
    "columns": {
      "fixed": ["Item", "Category", "Measurement Unit"],
      "per_unit": ["System Qty", "Actual Qty", "Difference", "Image", "Result"],
      "overall_total": ["Total System Qty", "Total Actual Qty", "Total Difference"]
    },
    "matrix": [
      {
        "item_id": 14,
        "name": "Air Freshner Spray",
        "category": "Other Consumptions",
        "unit": "pcs",
        "cells": {
          "128": {
            "audit_item_id": 1080,
            "audit_id": 128,
            "system": 1,
            "actual": 2,
            "diff": 1,
            "result": "Excess",
            "image": "https://...",
            "images": ["https://..."]
          }
        },
        "overall_total": {
          "system": 2,
          "actual": 3,
          "diff": 1,
          "result": "Excess"
        }
      }
    ],
    "extra": [],
    "existing_items_count": 10,
    "additional_items_count": 0
  }
}
```

---

## 3. UI Architecture & View Hierarchy

### 3.1 Inventory Audit Report Screen
* **View:** `AuditReportScreen` (`lib/modules/inventory/views/audit_report_screen.dart`)
* **Table Component:** `AuditReportTable` (`lib/modules/inventory/views/widgets/audit_report_table.dart`)
* **Columns:**
  1. `Audit No` (clickable blue text navigating to detail)
  2. `Audit Date`
  3. `Units`
  4. `Total Units`
  5. `Audit Records`
* **Header Color:** `Color(0xFF009BD9)` (solid primary blue).
* **Pagination:** Managed via `AppTablePagination`.

### 3.2 Audit Report Detail Screen
* **View:** `AuditReportDetailScreen` (`lib/modules/inventory/views/audit_report_detail_screen.dart`)
* **AppBar:** Title is `"Audit Report"` (audit number omitted to keep header uncluttered) with an Excel export button.
* **Tables Rendered:**
  1. **Audit Summary Table** (`AuditSummaryTable`):
     - Expandable container with collapsible chevron and unit count badge.
     - Displays `Unit`, `Audit Number`, `Audit Date`, `Audited By` (`Sl No.` omitted).
     - Data source: `detail.unitList`.
  2. **Existing Inventory Items — Unit-wise Comparison** (`AuditReportDetailTable`):
     - Compact row height (`22.h`) matching default table standards.
     - 2-tier grouped header table with fractional overflow protection (`Expanded` tiers).
     - Fixed headers: `Item`, `Category`, `Measurement Unit` (`Sl No.` omitted).
     - Dynamic per-unit grouped headers (`<unit_name>`, spanning `System Qty`, `Actual Qty`, `Difference`, `Image`, `Result`) + `Overall Total` (spanning `Total System Qty`, `Total Actual Qty`, `Total Difference`).
     - Image thumbnails with tap-to-expand full screen viewer (`openFullScreenImageViewer`), decoded with bounded memory cache dimensions (`memCacheWidth: 64, memCacheHeight: 64`) to prevent out-of-memory crashes on device.
     - Dedicated bottom footer slider bar with draggable thumb and left/right step chevrons (non-overlapping with data rows).
     - Raw response quantity rendering (preserving exact integer or decimal formatting received directly from JSON response without forcing trailing `.00`).
     - Highlighted cell styling: Difference cells with negative values and Result cells with `'Shortage'` rendered with soft red fill (`#FEE2E2`) and bold red text (`#DC2626`).
  3. **Additional / Unlisted Items Table** (`AuditAdditionalItemsTable`):
     - Headers: `Item`, `Measurement Unit`, dynamic `<unit_name> Actual Qty`, `Total Actual Qty` (`Sl No.` omitted).
     - Values rendered exactly as received in API response without appending `.00`.
     - When empty: Displays centered message `"No additional items found."`.

---

## 4. Change Log

| Date | Author | Description |
|---|---|---|
| 2026-10-23 | Antigravity | Updated Date-wise Audit Report list and Audit Detail comparison screen to match web UI design specifications. Extracted `audit_report_model.dart`, implemented 2-tier grouped comparison matrix, dynamic unit summary and unlisted items table, and verified full architectural compliance (`rules.md`). |
| 2026-10-23 | Antigravity | Removed Sl No from Audit Summary, Comparison Matrix, and Additional Items tables. Made Audit Summary container expandable with unit count badge and chevron. Decreased comparison matrix row height to default 22.h, eliminated 1.00px header flex overflow, replaced overlapping Scrollbar overlay with dedicated non-intrusive bottom slider, and removed audit number from detail screen AppBar. |
| 2026-10-23 | Antigravity | Fixed horizontal scroll lag in AuditReportDetailTable by eliminating setState rebuilds during scrolling, isolating slider thumb progress in ValueListenableBuilder, caching header and row widgets, and wrapping table in RepaintBoundary. |
| 2026-10-23 | Antigravity | Fixed out-of-memory device crash by constraining thumbnail decode cache (`memCacheWidth/Height: 64`) and removing giant table `RepaintBoundary`. Removed `.toStringAsFixed(2)` to display exact server response values across comparison matrix and additional items tables. Implemented red cell background (`#FEE2E2`) and bold red text (`#DC2626`) for negative differences and Shortage results. |
| 2026-10-24 | Antigravity | Updated Unit & Store Required Orders dialogs to display cell quantities using `order_qty_display` from `bulk_preview` API response, rendering empty/blank cells whenever quantity is zero or display value is empty. |
| 2026-10-24 | Antigravity | Full rules.md compliance retrofit: restructured `UnitRequiredOrdersDialog`, `StoreRequiredOrdersDialog`, and `inventory_order_model.dart` into mandatory labeled `// region` blocks, enforced dense `24.h` row height and `2.h` cell vertical padding across main and offscreen preview tables, aligned typography to `style_11_500` / `style_11_700`, added header close actions, and verified RBAC visual and tap guards. |
| 2026-10-24 | Antigravity | Exposed `StoreRequiredOrdersDialog.show` and `UnitRequiredOrdersDialog.show` as public static methods on the widget classes, and fully retrofitted `StoreInventoryActionButtons` to use `AppCommonButton`, labeled `// region` blocks, and dual-level RBAC tap guards. |


