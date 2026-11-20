# Booking, Membership, Payment, Cash Handover & C-to-D Specification

> **Package:** `packages/apps/mfresh_ops`  
> **Module:** Booking & Cash Management (`lib/modules/booking/`, `lib/modules/service_details/`, `lib/modules/cash_management/`)  
> **Last Updated:** 2026-11-04  
> **Maintainer:** Banamali Nayak

---

## 1. Overview & Architecture

The Booking and Cash Management lifecycle within **mFresh Ops** governs:
1. **Cashier / Operator Authentication & Unit Entry**: Employee or Guest Cashier session initialization (`cashier_session_id`, `booking_actor_user_id`, `unit_id`).
2. **Unit Booking Screen**: Live service catalogs, membership verification, and dynamic cart calculation with immediate refresh of the latest 6 cashier bookings.
3. **Multi-Mode Payment & Booking Initiation**:
   - Mode 1: Offline Cash (`payment_mode: 1`, `service_type: 1`).
   - Mode 2: PhonePe SDK / Payment Gateway (`payment_mode: 2`, `service_type: 2`).
   - Mode 3: External QR (`payment_mode: 3`, `service_type: 2`, `external_payment_confirmed: true`).
4. **Recent 6 Bookings Flow**: Cashier-scoped transaction history with receipt reprints and live refresh after every booking.
5. **Cash Management (Handover & C-to-D)**:
   - Overview & reconciliation: Cash due, shortages, completed/pending handovers.
   - C-to-D Multiple-Date Cash Deposits (`CASH_C_TO_D` action, date-wise allocation entries, receiver OTP verification, WhatsApp shortfall alert trigger).
   - Normal Cash Handover & Unit Switch/Logout (`exit-check`, receiver OTP verification, session closure).

---

## 2. API Specifications & Endpoints

### 2.1 Endpoint Catalog

| Endpoint | Method | Purpose | Request Parameters | Success Response / State Action |
|---|---|---|---|---|
| `login` | `POST` | Normal employee / cashier login | `{ mob, password }` or `{ mob, otp }` | Stores JWT token securely (`StorageService`). |
| `booking-guest/check-mobile` | `POST` | Check guest cashier mobile status | `{ mob }` | Identifies approved vs unapproved guest cashier. |
| `booking-guest/verify-otp` | `POST` | Verify guest cashier OTP | `{ mob, otp }` | Returns cashier JWT token for guest session. |
| `admin-booking/units` | `GET` | Fetch authorized units for cashier | None | Returns unit list and sets `booking_actor_user_id`. |
| `admin-booking/unit/enter` | `POST` | Enter unit & start cashier session | `{ unit_id }` | Returns `cashier_session_id`, `session_created`, `booking_actor_user_id`. |
| `admin-booking/unit/services` | `POST` | Fetch services for selected unit | `{ unit_id, cashier_session_id, service_type, mem_status }` | Returns service items with prices, images, and IDs. |
| `admin-booking/unit/recent-bookings` | `POST` | Fetch latest 6 cashier bookings | `{ unit_id, cashier_session_id }` | Returns latest 6 bookings with customer info, services, receipt URL. |
| `validate-mem-phone` | `POST` | Check member phone validity | `{ phone }` | Validates active member status (`status: "valid"`). |
| `send-otp-member` | `POST` | Send OTP to member | `{ phone }` | Customer receives 6-digit OTP (`status: "success"`). |
| `verify-otp-member` | `POST` | Verify member OTP | `{ phone, otp }` | Verifies member OTP (`status: "success"`, `verified: true`). |
| `admin-booking/booking/initiate` | `POST` | Create booking | `{ Unit_no, cashier_session_id, total_amount, payment_mode, service_type, mem_status, cart: [...] }` | Returns `booking_id`, `encrypt_booking_id`, `receipt_url`. |
| `admin-booking/booking/payment-success` | `POST` | Confirm PhonePe / Gateway payment | `{ userId, bookingId, Payment_status, provider_reference_id, check_sum }` | Verifies gateway payment and transitions status to `PAYMENT_SUCCESS`. |
| `admin-booking/resend-booking-sms` | `POST` | Resend booking receipt SMS | `{ booking_id, mobile_no, add_phone_no? }` | Sends receipt SMS to primary and optional additional phone numbers. |
| `admin-booking/handover/overview` | `POST` | Cash management overview | `{ unit_id, session_id }` | Returns cash due, handover summary, shortages, cash balance. |
| `admin-booking/handover/ctod-dates` | `POST` | Fetch date-wise C-to-D figures | `{ unit_id, session_id, from_date, to_date }` | Returns date-wise booking cash, completed/pending C-to-D, and collection actuals. |
| `admin-booking/handover/create` | `POST` | Create pending handover / C-to-D | `{ current_unit, session_id, next_cashier, handover_action: "LOGOUT" | "CASH_C_TO_D", amount, collection_entries }` | Returns `handover_id` and triggers receiver OTP. |
| `admin-booking/handover/resend-otp` | `POST` | Resend receiver OTP | `{ handover_id }` | Triggers OTP resend to receiver. |
| `admin-booking/handover/verify-otp` | `POST` | Verify receiver OTP | `{ handover_id, otp }` | Completes handover / C-to-D, updates collection sheet, triggers WhatsApp shortage check. |
| `admin-booking/handover/exit-check` | `POST` | Verify session closure before exit | `{ unit_id, session_id }` | Verifies zero unaccounted cash before unit exit/switch. |

---

## 3. Booking Initiate Payload Schema

```json
{
  "Unit_no": "MM2500DEV",
  "cashier_session_id": 275,
  "total_amount": 100,
  "payment_mode": 1,
  "service_type": 1,
  "mem_status": 0,
  "cart": [
    {
      "Assign_Service_Id": 56,
      "service_quantity": 2
    }
  ]
}
```

* For **Membership Booking**: `mem_status: 1`, provide verified member mobile.
* For **External QR**: `payment_mode: 3`, `service_type: 2`, `external_payment_confirmed: true`.
* For **PhonePe SDK**: `payment_mode: 2`, `service_type: 2`, `Payment_status: "Pending"`.

---

## 4. Cash Handover & C-to-D Flow Specifications

### 4.1 UI Design & Behavioral Architecture
1. **Normal Cash Handover Tab (`LOGOUT`)**:
   - **Handover To**: Dropdown selecting the next authorized receiver/operator.
   - **Date-wise Collection Sections (`Collection DD-MM-YYYY`)**:
     - Groups all records by date (e.g., `Collection 05-11-2026`, `Collection 16-11-2026`, `Collection 17-11-2026`).
     - **Received Cash Items (Read-Only)**: Displays all auto-forwarded received entries for that date with Sender Name, created timestamp, pending note (e.g. `Pending from received cash: ₹4.00`), and amount (green bold, e.g. `₹3.00`, `₹1.00`, `₹0.00`).
     - **Own Booking Cash Input**: Explicit field for `"Own booking cash"` with subtitle `"Enter only your own cash; received cash is separate"` and input box `[ ₹ Amount ]` for eligible/pending booking dates.
   - **Total Physical Cash Given**: Summary card aggregating all received cash items plus all entered own booking cash inputs across dates.
   - **Submit Action**: `"Continue Handover"` button dispatching date-wise collection entries and own amount to `/api/admin-booking/handover/create`.

2. **Cash C to D Tab (`CASH_C_TO_D`)**:
   - **Handover To**: Dropdown selecting the next authorized manager.
   - **Date Range Picker & Dates List**: Date-wise collection amounts with responsive currency inputs.
   - **Total Physical Cash Given**: Summary card aggregating date-wise entries.
   - **Submit Action**: `"Continue Cash C TO D"` button.

### 4.2 OTP Action Matrix & Session Lifecycle

| API Response Code | Client Action & Session Lifecycle |
|---|---|
| `HANDOVER_OTP` | Immediately open receiver 6-digit OTP verification modal. |
| `INVALID_OTP` | Display error toast (`Invalid OTP`); keep OTP modal open for re-entry. |
| `OTP_EXPIRED` | Display warning toast (`OTP has expired`); keep modal open; trigger resend option. |
| `HANDOVER_COMPLETED` | Discard cashier session (`rxActiveCashierSessionId.value = null`), show completion modal, prompt for next shift / unit selection. |
| `CASH_C_TO_D_COMPLETED` | Retain active session, show completion modal/toast, refresh overview figures. |
| `ALREADY_COMPLETED` | Treat as completed without submitting duplicate request. Discard session if normal handover; retain if C-to-D. |
| `CTOD_HANDOVER_PENDING` | Surface warning dialog with pending cashier, date, and reason. |
| `SESSION_NOT_ACTIVE` | Invalidate local session state; prompt cashier to re-enter unit to start a new shift. |

### 4.3 Exit Check Guard (`exit-check`)
- Before navigating back or exiting `ServiceDetailsScreen`, the app triggers `POST /api/admin-booking/handover/exit-check`.
- If unaccounted cash exists, back navigation is blocked by `PopScope` and an alert dialog prompts the cashier to open the Handover modal or stay on the screen.

---

## 5. Change Log

| Date | Author | Description |
|---|---|---|
| 2026-11-19 | Magnet Connects Team | Fixed individual receipt printing prices for multi-quantity bookings: resolved issue where booking 3 quantity of a service printed the total booking amount on all 3 tickets instead of the unit price. Added robust unit price resolution (`getUnitPriceForService`, `getFormattedUnitPriceForService`) on `BookingDetailsModel` and `BookingServiceDetailItem` that accurately reconciles unit price vs line total across ESC/POS thermal printing (`TwoInchReceipt`, `ThreeInchReceipt`), PDF/system print, internal Plutus PineLabs printing, and receipt preview screen. Explicitly passed `unitPrice` and `lineTotal` in `ServiceDetailsController` and parsed `unit_price`, `rate`, `total_price` in `BookingServiceDetailItem.fromJson`. |
| 2026-11-18 | Magnet Connects Team | Added floating left-center tab back button on `BookingConfirmedScreen` to match `mfresh`: placed responsive curved orange tab (`40.w x 60.h`, border radius `30.r` on right, `Icons.arrow_back_ios_new_rounded`, `#F15A22` @ 90% opacity) vertically centered on the left edge. Integrated `resetAll()` on `ServiceDetailsController` upon tap and system back pop. |
| 2026-11-18 | Magnet Connects Team | Implemented dynamic auto-adjusting QR code scaling and viewport optimization in `AppCommonWebView` (`package:core/core.dart`): replaced legacy static `scale(0.5)` / `max-width: 30%` shrink styles with an automated responsive JS observer (`autoAdjustQr` + `MutationObserver`) that calculates optimal QR dimensions (~55% of device width, bounded between 160px-230px, capped at 33% screen height), centered inside the card container to dynamically adapt across phones, POS terminals, and tablets. |
| 2026-11-18 | Magnet Connects Team | Migrated PhonePe payment execution from Native SDK to PhonePe Payment Gateway Web URL flow with domain whitelisting (`https://magnetconnects.com/`). Standardized and upgraded `AppCommonWebView` (`package:core/core.dart`) with dedicated redirect capture for whitelisted domain, origin/referer whitelisting headers (`Referer: https://magnetconnects.com/`, `Origin: https://magnetconnects.com`), mobile user-agent, external UPI app intent launching (`upi://`, `phonepe://`, `gpay://`, `paytmmp://`, `ppesim://`), and automated multi-attempt server verification via `checkPaymentStatus`. Registered `AppRoutes.webView` in `AppRoutes` and `AppPages` mapping directly to `AppCommonWebView`. |
| 2026-11-17 | Magnet Connects Team | Updated SMS receipt sending flow (`admin-booking/resend-booking-sms`): ensured additional phone number entered during booking (`addPhoneController`) is forwarded to `BookingDetailsModel` and `BookingDetailsController`, added 'Additional Phone (Optional)' field to the 'Send Receipt via SMS' dialog on `BookingConfirmedScreen` with auto-prefill, and passed additional phone number under `add_phone_no` / `Add_phone_no` in the `sendSmsReceipt` repository payload. |
| 2026-11-17 | Magnet Connects Team | Adjusted spacing and compact middle padding across Handover Cash and Cash C TO D modal: reduced the empty state vertical padding to `8.h` (`10.h` on tablet), increased breathing room between segmented tabs and 'Handover To' dropdown to `10.h` (`12.h` on tablet), added proper `10.h` vertical spacing between dropdown, date pickers, collection cards, total given summary box, and bottom action buttons across both tabs. |
| 2026-11-17 | Magnet Connects Team | Standardized dynamic highlighting of service catalog cards and counter controls based on Online/Offline state to match spec: active Online mode highlights selected cards with orange border (`#F15A24`), soft peach background (`#FFF5EE`), and orange counter (`#FFBA87`); active Offline mode highlights selected cards with blue border (`#0288D1`), soft blue background (`#E8F4FD`), and sky blue counter (`#A6D8F8`); unselected cards maintain white card background with `#E2E8F0` border and light grey `#F8FAFC` counter with dark text. |
| 2026-11-17 | Magnet Connects Team | Centered the Online/Offline toggle on its dedicated row below the full-width Customer/Membership connected tab switcher. |
| 2026-11-17 | Magnet Connects Team | Removed post-handover success dialogs: on successful handover completion, a success toast is shown and the app immediately navigates to `AppRoutes.bookingUnitSelection` while automatically triggering `fetchUnits()` to refresh available units. |
| 2026-11-17 | Magnet Connects Team | Added 'All Units' action button at the bottom-left of the booking screen top banner with responsive button dimensions (`120.w x 36.h` on tablet, `88.w x 25.h` on mobile), symmetric padding to protect centered unit title/location from overlap, and integrated `handleBackExit` exit-check guard with fallback to `AppRoutes.bookingUnitSelection`. |
| 2026-11-17 | Magnet Connects Team | Removed default date pre-selection for Cash C TO D (`dateRangeController.text` starts blank with placeholder), and ensured the sequential date pickers default to today (`DateTime.now()`) opening directly in the active current month. |
| 2026-11-17 | Magnet Connects Team | Switched Cash C TO D date selection from `showDateRangePicker` to sequential standard `showDatePicker` flow (first picks 'From Date', then immediately prompts for 'To Date' constrained to on or after the selected From Date). |
| 2026-11-17 | Magnet Connects Team | Updated Handover success dialog ("NEXT SHIFT / ENTER UNIT") and session expiry alert ("ENTER UNIT") navigation from `AppRoutes.home` (Operations dashboard) to `AppRoutes.bookingUnitSelection` (`BookingUnitSelectionScreen`) to seamlessly guide cashiers to unit selection for starting their next shift. |
| 2026-11-17 | Magnet Connects Team | Implemented backend 5-mandatory-rule contract: guaranteed all pending dates are submitted together in `collection_entries` with `own_cash_amount` (including ₹0), added 'No own booking cash input required' UI handling for `own_cash_input_required: false`, and validated total handover amount calculation (`own_cash + received_cash`). |
| 2026-11-17 | Magnet Connects Team | Standardized Handover modal UI & typography to Magnet rules: moved 'Handover To' dropdown outside the scroll view to prevent floating label clipping, tightened vertical spacing across collection cards, unified bottom cash summary & action buttons, integrated `AppDateUtils` for all date displays, and removed ad-hoc widget overrides in favor of default `AppCommon*` styling. |
| 2026-11-17 | Magnet Connects Team | Resolved Laravel 422 validation errors by standardizing `cashier_session_id` and required default date ranges (`from_date`, `to_date`) across all Handover API endpoints (`overview`, `ctod-dates`, `create`, `exit-check`). |
| 2026-11-17 | Magnet Connects Team | Implemented complete Booking & Cash Handover API flow: added `ReceivedCashEntry` read-only auto-forward card, `HandoverExitCheckResult`, OTP response action matrix (`HANDOVER_COMPLETED`, `CASH_C_TO_D_COMPLETED`, etc.), and `PopScope` exit-check guard on `ServiceDetailsScreen`. |
| 2026-11-04 | Magnet Connects Team | Updated Membership API routes to `/validate-mem-phone`, `/send-otp-member`, and `/verify-otp-member` without legacy customer prefix. |
