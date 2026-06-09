# Research: Google Maps & Background Location

## Background Location Strategy (Android 14/15)

### Decision: `flutter_foreground_task` + `geolocator`
- **Rationale**: `flutter_foreground_task` is actively maintained and specifically addresses Android 14+ requirements for `foregroundServiceType="location"`. It provides a clean way to manage isolates for background work. `geolocator` is the standard for fetching GPS data.
- **Alternatives considered**:
    - `background_locator_2`: Less active maintenance, more complex configuration for modern Android versions.
    - `flutter_background_service`: Versatile but requires more manual setup for notification and service type declarations.
    - `flutter_background_geolocation`: Excellent but paid/proprietary for Android.

### Google Maps Integration
- **Decision**: `google_maps_flutter`
- **Rationale**: Official Google-maintained plugin, highly performant, and standard for Flutter.

### Android 14/15 Compliance
- Must declare `FOREGROUND_SERVICE_LOCATION` in manifest.
- Must start the service while the app is in the foreground to avoid `ForegroundServiceStartNotAllowedException`.
- Need to handle granular location permissions (Foreground vs. Background).

## Decisions Summary

| Topic | Chosen Solution | Why |
|-------|-----------------|-----|
| Background Service | `flutter_foreground_task` | Android 14/15 compliance, isolate management. |
| Location Logic | `geolocator` | Reliable GPS API. |
| Map UI | `google_maps_flutter` | Official plugin. |
| State Management | GetX | Existing project standard. |
