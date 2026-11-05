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

## 4. Change Log

| Date | Author | Description |
|---|---|---|
| 2026-11-04 | Magnet Connects Team | Updated Membership API routes to `/validate-mem-phone`, `/send-otp-member`, and `/verify-otp-member` without legacy customer prefix. |
