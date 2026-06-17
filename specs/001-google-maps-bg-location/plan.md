# Implementation Plan: Google Maps Background Location Integration

**Branch**: `001-google-maps-bg-location` | **Date**: 2026-06-05 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-google-maps-bg-location/spec.md`

## Summary

The goal is to integrate Google Maps into the `mfresh_ops` application and implement background location tracking. The approach involves using `google_maps_flutter` for the UI and a combination of `geolocator` and `flutter_background_service` (or a specialized background location plugin) to ensure continuous tracking even when the app is in the background.

## Technical Context

**Language/Version**: Dart (Flutter SDK ^3.9.2)

**Primary Dependencies**: 
- `google_maps_flutter`: For map display.
- `geolocator`: For location acquisition.
- `permission_handler`: For managing permissions.
- [NEEDS CLARIFICATION: Background plugin choice - `flutter_background_service` vs `background_locator_2`?]

**Storage**: Local state management (GetX, which is already used in the project).

**Testing**: Flutter unit and widget tests.

**Target Platform**: Android (primary focus as per `mfresh_ops` structure), iOS.

**Project Type**: Mobile Application (Operations app).

**Performance Goals**: 60 fps map interaction, location updates every 10-30 seconds in background.

**Constraints**: Battery efficiency, Android Foreground Service requirements (API 34+ compliance), Secret management via Envied.

**Scale/Scope**: Single feature integration within the `mfresh_ops` app.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Define the outcome before implementation.
- [x] Prefer small, scoped changes over broad refactors.
- [x] Keep Flutter apps thin and move reusable logic into shared packages.
- [x] Apply the same spec-first workflow to both apps.
- [x] Validate changes with analysis and tests where available.
- [x] Preserve existing behavior.

## Project Structure

### Documentation (this feature)

```text
specs/001-google-maps-bg-location/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
packages/
├── apps/
│   └── mfresh_ops/
│       ├── lib/
│       │   ├── modules/
│       │   │   └── map/          # New module for map and location
│       │   │       ├── bindings/
│       │   │       ├── controllers/
│       │   │       └── views/
│       │   └── routes/           # Update routes for map access
├── shared/
│   └── services/
│       └── lib/
│           └── src/
│               └── location/     # Shared location service logic
```

**Structure Decision**: A new `map` module will be created in `mfresh_ops` following its GetX pattern. Reusable location logic will be placed in `packages/shared/services`.

## Complexity Tracking

*No constitution violations identified.*
