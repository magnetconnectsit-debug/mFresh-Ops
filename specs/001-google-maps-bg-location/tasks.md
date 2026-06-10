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

- [x] T001 [P] Add `google_maps_flutter`, `flutter_foreground_task`, `geolocator`, and `permission_handler` to `packages/apps/mfresh_ops/pubspec.yaml`
- [x] T002 [P] Add `geolocator` and `flutter_foreground_task` to `packages/shared/services/pubspec.yaml`
- [x] T003 [P] Add `GOOGLE_MAPS_API_KEY` to `packages/apps/mfresh_ops/.env`
- [x] T004 [P] Update `packages/apps/mfresh_ops/lib/core/env/env.dart` to include `googleMapsApiKey` and run build_runner
- [x] T005 [P] Configure Google Maps API Key in `packages/apps/mfresh_ops/android/app/src/main/AndroidManifest.xml` using manifest placeholders
- [x] T006 [P] Configure Google Maps API Key in `packages/apps/mfresh_ops/ios/Runner/AppDelegate.swift`
- [x] T006a [P] Add location and foreground service permissions to `packages/apps/mfresh_ops/android/app/src/main/AndroidManifest.xml`
- [x] T006b [P] Add location permissions to `packages/apps/mfresh_ops/ios/Runner/Info.plist`
- [x] T006c [P] Configure Android manifest placeholders in `packages/apps/mfresh_ops/android/app/build.gradle.kts`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [x] T007 Create `LocationService` interface in `packages/shared/services/lib/src/location/location_service.dart`
- [x] T008 Implement `GeolocatorLocationService` in `packages/shared/services/lib/src/location/geolocator_location_service.dart`
- [x] T009 [P] Create `LocationController` in `packages/apps/mfresh_ops/lib/modules/map/controllers/location_controller.dart`
- [x] T010 [P] Create `LocationBinding` in `packages/apps/mfresh_ops/lib/modules/map/bindings/location_binding.dart`
- [x] T011 Setup `flutter_foreground_task` entry point and handler in `packages/apps/mfresh_ops/lib/main.dart`

---

## Phase 3: User Story 1 - Real-time Location on Map (Priority: P1) 🎯 MVP

**Goal**: Display Google Map with the user's current location in real-time.

- [x] T012 [P] [US1] Create `MapView` in `packages/apps/mfresh_ops/lib/modules/map/views/map_view.dart`
- [x] T013 [US1] Integrate `GoogleMap` widget into `MapView` using `LocationController` stream.
- [x] T014 [US1] Register Map route in `packages/apps/mfresh_ops/lib/routes/app_pages.dart`
- [x] T015 [US1] Implement foreground location permission request flow in `LocationController`.

**Checkpoint**: User Story 1 is functional.

---

## Phase 4: User Story 2 - Employee Tracking Lifecycle & Sync (Priority: P1)

**Goal**: Track location and sync with backend, including offline caching.

- [x] T016 [US2] Implement tracking session management (start/stop) with `/tracking/start` and `/tracking/stop` APIs.
- [x] T017 [US2] Implement location update sync logic using `/tracking/location-update` (real-time) and `/tracking/bulk-sync` (background/offline).
- [x] T018 [US2] Implement current status check via `/tracking/current-status` on app start.

---

## Phase 5: User Story 4 - Route Visualization & History (Priority: P2)

**Goal**: Fetch location history and draw routes on the map.

- [x] T019 [US4] Implement route history fetching from `/tracking/my-route-history`.
- [x] T020 [US4] Implement stoppage and segment data fetching from `/tracking/my-stoppages` and `/tracking/my-segments`.
- [x] T021 [US4] Draw route polylines and markers for stops on the Google Map.
- [x] T022 [US4] Implement today's summary view (logic in HistoryController).

---

## Phase 6: User Story 3 - Handling Permissions & GPS State (Priority: P3)

**Goal**: Robust error handling and user guidance.

- [x] T023 [US3] Implement GPS status listener and permission error handling in `LocationController`.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [x] T024 [P] Add offline caching via Hive and automatic bulk-sync recovery.
- [x] T025 Final manual verification audit.
