# Info Directory Module Specification & Living Architecture

> **Status:** Active / Living Specification  
> **Package:** `packages/apps/mfresh_ops`  
> **Module Path:** `lib/modules/info_directory/`  
> **Documentation Location:** `documentation/info_directory/INFO_DIRECTORY.md`  
> **Last Updated:** October 2026  
> **Maintainer:** Banamali Nayak

---

## Overview
The **Info Directory** module provides centralized contact management, vendor tracking, asset/product inventory, and software/service account subscription management for the organization.

## Architecture & Submodules
The module contains 3 major domain submodules and 3 master lookup domains:
1. **Contacts Directory**:
   - Controller: `CreateContactController`, `InfoDirectoryController`
   - Views: `CreateContactScreen`, `InfoDirectoryScreen`
2. **Account Subscriptions**:
   - Controller: `CreateAccountSubscriptionController`, `AccountSubscriptionController`
   - Views: `CreateAccountSubscriptionScreen`, `AccountSubscriptionScreen`
3. **Assets & Products**:
   - Controller: `CreateAssetController`, `AssetsProductsController`
   - Views: `CreateAssetScreen`, `AssetsProductsScreen`
4. **Master Dialogs**:
   - Brand: `showMContactBrandDialog` (`mcontact_brand_dialog.dart`)
   - Company: `showMContactCompanyDialog` (`mcontact_company_dialog.dart`)
   - Asset Category: `showAssetCategoryDialog`, `showDeleteCategoryDialog` (`asset_category_dialog.dart`)

---

## Form Field Navigation & Next-Unfilled-Field Pointer
To streamline data entry across complex forms, each form implements sequential pointer progression to the next unfilled field (`focusNextUnfilledField`):

### 1. Contact Form Field Progression (17 Fields)
| Index | Field | Widget | Type |
|---|---|---|---|
| 0 | Contact Type | `AppCommonMultiSelectDropdown` | Dropdown |
| 1 | Name * | `AppCommonTextField` | Text |
| 2 | Brand | `AppCommonMultiSelectDropdown` | Dropdown |
| 3 | Company | `AppCommonMultiSelectDropdown` | Dropdown |
| 4 | Worked On | `AppCommonTextField` | Text |
| 5 | GST IN | `AppCommonTextField` | Text |
| 6 | Designation | `AppCommonTextField` | Text |
| 7 | Department | `AppCommonTextField` | Text |
| 8 | Mobile 1 * | `AppCommonTextField` | Phone (10 digits) |
| 9 | Mobile 2 | `AppCommonTextField` | Phone (10 digits) |
| 10 | Email | `AppCommonTextField` | Email |
| 11 | Level * | `AppCommonMultiSelectDropdown` | Dropdown |
| 12 | Type Service * | `AppCommonTextField` | Text |
| 13 | Location | `AppCommonTextField` | Text |
| 14 | Address | `AppCommonTextField` | Text |
| 15 | Website Links | `AppCommonTextField` | Text |
| 16 | Comment/Description | `AppCommonTextField` | Multiline Text |

### 2. Account Subscription Form Field Progression (21 Fields)
| Index | Field | Widget | Type |
|---|---|---|---|
| 0 | Account * | `AppCommonMultiSelectDropdown` | Dropdown |
| 1 | Company | `AppCommonTextField` | Text |
| 2 | Brand | `AppCommonTextField` | Text |
| 3 | Service | `AppCommonTextField` | Text |
| 4 | Unit | `AppCommonTextField` | Text |
| 5 | City | `AppCommonTextField` | Text |
| 6 | Location | `AppCommonTextField` | Text |
| 7 | Customer ID | `AppCommonTextField` | Text |
| 8 | Mobile No | `AppCommonTextField` | Phone |
| 9 | Email | `AppCommonTextField` | Email |
| 10 | User Name | `AppCommonTextField` | Text |
| 11 | Password | `AppCommonTextField` | Text |
| 12 | URLs | `AppCommonTextField` | Text |
| 13 | Remarks | `AppCommonTextField` | Text |
| 14 | Plan Name | `AppCommonTextField` | Text |
| 15 | Payment | `AppCommonMultiSelectDropdown` | Dropdown |
| 16 | Billing cycle & Due | `AppCommonTextField` | Text |
| 17 | Next Due On | `AppCommonDateField` | DatePicker |
| 18 | Last Payment | `AppCommonDateField` | DatePicker |
| 19 | Payment Details | `AppCommonTextField` | Multiline Text |
| 20 | Comments | `AppCommonTextField` | Text |

### 3. Asset Form Field Progression (17 Fields)
| Index | Field | Widget | Type |
|---|---|---|---|
| 0 | Item * | `AppCommonTextField` | Text |
| 1 | Item Type | `AppCommonMultiSelectDropdown` | Dropdown |
| 2 | Brand | `AppCommonTextField` | Text |
| 3 | Model | `AppCommonTextField` | Text |
| 4 | Category | `AppCommonMultiSelectDropdown` | Dropdown |
| 5 | Assigned To | `AppCommonMultiSelectDropdown` | Dropdown |
| 6 | Serial No | `AppCommonTextField` | Text |
| 7 | Project | `AppCommonMultiSelectDropdown` | Dropdown |
| 8 | Warranty Expiry Date | `AppCommonDateField` | DatePicker |
| 9 | Warranty Status | `AppCommonMultiSelectDropdown` | Dropdown |
| 10 | Installed At (Location) | `AppCommonTextField` | Text |
| 11 | Unit | `AppCommonTextField` | Text |
| 12 | Position | `AppCommonTextField` | Text |
| 13 | Vendor | `AppCommonTextField` | Text |
| 14 | Qty | `AppCommonTextField` | Number |
| 15 | Description | `AppCommonTextField` | Multiline Text |
| 16 | Specification | `AppCommonTextField` | Multiline Text |

---

## Table Sorting Capabilities
Both primary module tables (`InfoDirectoryTable` and `AccountSubscriptionTable`) implement interactive column sorting via `AppCommonTable`:
- **Sort Triggers**: Column headers display dynamic ascending/descending/none sort indicators.
- **Client-Side Responsive Sorting**: Sorts cached datasets dynamically across all data columns, retaining active order when new paginated data arrives.
- **Reset Integration**: Clearing or resetting filter controls resets table sorting to default.

---

## Change Log
| Date | Author | Description |
|---|---|---|
| 2026-10-22 | Developer | Refactored info_directory module to comply with rules.md: retrofitted all screens, tables, and dialogs with explicit region markers, AppCommon* widgets (including migrating all data tables to AppCommonTable and AppTablePagination), AppColors tokens, ScreenUtil responsive units, and implemented automatic sequential pointer movement to the next unfilled field across Create and Edit forms. |
| 2026-10-22 | Developer | Fixed pointer progression to prevent backward jumps to previous non-mandatory fields. Added interactive column sorting support to InfoDirectoryTable and AccountSubscriptionTable with active sort retention and filter reset synchronization. |
