---
description: "Task list for Google Maps & Background Location integration"
---

# Tasks: Google Maps Background Location Integration

**Input**: Design documents from `/specs/001-google-maps-bg-location/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 [P] Add `google_maps_flutter`, `flutter_foreground_task`, `geolocator`, and `permission_handler` to `packages/apps/mfresh_ops/pubspec.yaml`
- [ ] T002 [P] Add `geolocator` and `flutter_foreground_task` to `packages/shared/services/pubspec.yaml`
- [ ] T003 [P] Configure Google Maps API Key in `packages/apps/mfresh_ops/android/app/src/main/AndroidManifest.xml`
- [ ] T004 [P] Configure Google Maps API Key in `packages/apps/mfresh_ops/ios/Runner/AppDelegate.swift`
- [ ] T005 [P] Add location and foreground service permissions to `packages/apps/mfresh_ops/android/app/src/main/AndroidManifest.xml`
- [ ] T006 [P] Add location permissions to `packages/apps/mfresh_ops/ios/Runner/Info.plist`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [ ] T007 Create `LocationService` interface in `packages/shared/services/lib/src/location/location_service.dart`
- [ ] T008 Implement `GeolocatorLocationService` in `packages/shared/services/lib/src/location/geolocator_location_service.dart`
- [ ] T009 [P] Create `LocationController` in `packages/apps/mfresh_ops/lib/modules/map/controllers/location_controller.dart`
- [ ] T010 [P] Create `LocationBinding` in `packages/apps/mfresh_ops/lib/modules/map/bindings/location_binding.dart`
- [ ] T011 Setup `flutter_foreground_task` entry point and handler in `packages/apps/mfresh_ops/lib/main.dart` or a dedicated background file.

---

## Phase 3: User Story 1 - Real-time Location on Map (Priority: P1) 🎯 MVP

**Goal**: Display Google Map with the user's current location in real-time.

**Independent Test**: Navigate to Map screen, see map centered on blue dot representing current location.

### Implementation for User Story 1

- [ ] T012 [P] [US1] Create `MapView` in `packages/apps/mfresh_ops/lib/modules/map/views/map_view.dart`
- [ ] T013 [US1] Integrate `GoogleMap` widget into `MapView` using `LocationController` stream.
- [ ] T014 [US1] Register Map route in `packages/apps/mfresh_ops/lib/routes/app_pages.dart`
- [ ] T015 [US1] Implement foreground location permission request flow in `LocationController`.

**Checkpoint**: User Story 1 is functional - Map displays current location while app is open.

---

## Phase 4: User Story 2 - Background Location Tracking (Priority: P2)

**Goal**: Track location even when the app is in the background.

**Independent Test**: Start tracking, minimize app, move, restore app, verify position updated.

### Implementation for User Story 2

- [ ] T016 [US2] Implement `startBackgroundService()` in `LocationController` using `flutter_foreground_task`.
- [ ] T017 [US2] Implement background task handler to update local state/controller when new location is received.
- [ ] T018 [US2] Add UI toggle in `MapView` to start/stop background tracking.
- [ ] T019 [US2] Implement "Always" location permission request flow.

**Checkpoint**: User Story 2 is functional - Location updates continue in background.

---

## Phase 5: User Story 3 - Handling Permissions & GPS State (Priority: P3)

**Goal**: Robust error handling and user guidance for GPS/Permissions.

**Independent Test**: Deny permissions or turn off GPS and verify app shows helpful dialogs.

### Implementation for User Story 3

- [ ] T020 [US3] Implement GPS status listener in `LocationController`.
- [ ] T021 [US3] Create error dialogs/snackbars for denied permissions and disabled GPS.
- [ ] T022 [US3] Add "Open Settings" shortcut in permission dialogs.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T023 [P] Add battery optimization exclusion request.
- [ ] T024 [P] Throttle location updates to save battery (configurable interval).
- [ ] T025 Final manual verification using `quickstart.md` steps.

---

## Dependencies & Execution Order

1. **Setup (Phase 1)** -> **Foundational (Phase 2)** -> **User Story 1 (Phase 3)**
2. **User Story 1** is the MVP.
3. **User Story 2** depends on **User Story 1** UI and **Foundational** service.
4. **User Story 3** can be done in parallel with or after **User Story 2**.
