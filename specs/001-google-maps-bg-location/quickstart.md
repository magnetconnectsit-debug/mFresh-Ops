# Quickstart: Google Maps Background Location

## Prerequisites
- Google Maps API Key (Android & iOS).
- Physical device for testing (Emulators have limited GPS simulation).

## Setup
1. **API Key**: Add your Google Maps API Key to `AndroidManifest.xml` and `AppDelegate.swift`.
2. **Permissions**: Ensure `permission_handler` is used to request:
    - `Permission.location`
    - `Permission.locationAlways`
    - `Permission.notification` (Android 13+)

## Usage
```dart
// To start tracking
final controller = Get.find<LocationController>();
controller.startTracking();

// Map Widget
GoogleMap(
  initialCameraPosition: CameraPosition(target: controller.currentLocation.value ?? defaultLatLong, zoom: 15),
  myLocationEnabled: true,
  myLocationButtonEnabled: true,
)
```
