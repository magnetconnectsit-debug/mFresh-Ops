# Feature Specification: Google Maps Background Location Integration

**Feature Branch**: `001-google-maps-bg-location`

**Created**: 2026-06-05

**Status**: Draft

**Input**: User description: "integrate google maps with bg location"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Real-time Location on Map (Priority: P1)

As an app user, I want to see my current location on a Google Map so that I can orient myself and see my progress.

**Why this priority**: Core functionality of the request. Without the map, there's no visual feedback.

**Independent Test**: User opens the Map screen, and a Google Map is displayed with a blue dot or marker at their current GPS coordinates.

**Acceptance Scenarios**:

1. **Given** the user has granted location permissions, **When** they navigate to the Map screen, **Then** they see a Google Map centered on their current location.
2. **Given** the user moves, **When** the app is in the foreground, **Then** the map marker/position updates in real-time.

---

### User Story 2 - Employee Tracking Lifecycle (Priority: P1)

As an employee, I want to start a tracking session so that my location is recorded for my shift.

**Acceptance Scenarios**:
1. **Given** the user is logged in, **When** they tap 'Start Tracking', **Then** a session is created via the `/tracking/start` API and background tracking begins.
2. **Given** an active session, **When** the app is in background, **Then** location updates are sent via `/tracking/location-update` or `/tracking/bulk-sync`.
3. **Given** an active session, **When** the user taps 'Stop Tracking', **Then** the session is ended via `/tracking/stop` and background tracking ceases.

---

### User Story 4 - Tracking Insights & History (Priority: P2)

As an employee, I want to see my route history, stops, and segments so that I can review my day's work.

**Acceptance Scenarios**:
1. **Given** a date selection, **When** I view history, **Then** the map draws my route from `/tracking/my-route-history`.
2. **Given** the history view, **When** I check stops or segments, **Then** I see detailed data from `/tracking/my-stoppages` and `/tracking/my-segments`.

---

### User Story 3 - Handling Permissions & GPS State (Priority: P3)

As a user, I want the app to guide me if I haven't granted permissions or if my GPS is off so that I know how to fix it.

**Why this priority**: Necessary for robustness and user experience.

**Independent Test**: Open app with GPS off or permissions denied and verify that an appropriate prompt/dialog is shown.

**Acceptance Scenarios**:

1. **Given** GPS is disabled, **When** the user opens the map, **Then** they are prompted to enable GPS.
2. **Given** location permission is denied, **When** the user opens the map, **Then** they are explained why it's needed and offered a way to open Settings.

### Edge Cases

- **No Internet**: Google Maps might fail to load tiles. The app should handle offline state gracefully.
- **Battery Optimization**: Android might kill the background service. The app should request exclusion from battery optimization if critical.
- **Frequent Location Changes**: The app should throttle updates to save battery if precise real-time tracking is not needed.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST integrate the `google_maps_flutter` plugin for displaying maps.
- **FR-002**: System MUST use a background-capable location plugin (e.g., `geolocator` with service or `background_locator_2`).
- **FR-003**: System MUST implement a Foreground Service on Android to ensure the OS doesn't kill the location task.
- **FR-004**: System MUST handle "Fine" and "Background" location permission requests.
- **FR-005**: System MUST target the `mfresh_ops` (Operations) app.
- **FR-006**: System MUST sync location data (lat, long, timestamp, speed, activity) to the provided backend API.
- **FR-007**: System MUST fetch location history from the backend API based on user ID and date/time filters.
- **FR-008**: System MUST draw routes using Polylines on the Google Map.
- **FR-009**: System MUST support filtering history by Date and Time range.

### Key Entities

- **UserLocation**: Represents a geographic coordinate (latitude, longitude) at a specific point in time.
- **LocationSettings**: Configuration for tracking frequency and accuracy.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can see their location on the map within 3 seconds of opening the screen.
- **SC-002**: Background tracking remains active and receives updates at the specified interval for at least 4 hours of continuous background operation.
- **SC-003**: Location accuracy is within 20 meters in clear sky conditions.

## Assumptions

- This integration will follow standard Flutter plugin implementation patterns.
- A valid Google Maps API Key will be provided.
- Standard Android/iOS location permission workflows are acceptable.
