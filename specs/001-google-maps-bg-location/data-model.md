# Data Model: Google Maps & Background Location

## Entities

### `UserLocation` (Internal State)
Represents the current position of the user.

- `latitude`: double
- `longitude`: double
- `timestamp`: DateTime
- `accuracy`: double
- `altitude`: double
- `heading`: double
- `speed`: double

### `LocationTrackingConfig`
Settings for the background service.

- `interval`: int (milliseconds between updates)
- `distanceFilter`: int (minimum meters moved to trigger update)
- `accuracy`: LocationAccuracy enum
- `notificationTitle`: String
- `notificationText`: String

## State Management (GetX)

### `LocationController`
- `currentLocation`: Rx<UserLocation?>
- `isTracking`: RxBool
- `locationHistory`: RxList<UserLocation>

## Transitions

- `startTracking()`: Initializes foreground service and starts stream.
- `stopTracking()`: Shuts down service.
- `onLocationUpdate(Position)`: Maps `geolocator` position to `UserLocation` and updates state.
