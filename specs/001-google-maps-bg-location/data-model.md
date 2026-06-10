# Data Model: Google Maps & Background Location

## Entities

### `TrackingSession`
- `sessionId`: int
- `deviceId`: String
- `isActive`: bool

### `LocationUpdate`
- `latitude`: double
- `longitude`: double
- `accuracy`: double
- `speed`: double
- `heading`: double
- `battery`: int
- `isCharging`: bool
- `networkType`: String
- `locationTime`: String (format: YYYY-MM-DD HH:MM:SS)

### `RouteHistory`
- `date`: String
- `points`: List<LocationUpdate>
- `stoppages`: List<Stoppage>
- `segments`: List<Segment>

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
