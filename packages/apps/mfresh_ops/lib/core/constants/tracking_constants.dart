// region Tracking Constants & Logic

import 'dart:math';

import 'package:geolocator/geolocator.dart';

class TrackingConstants {
  TrackingConstants._();

  // ===========================================================================
  // Distance Thresholds
  // ===========================================================================

  /// Normal movement upload threshold.
  static const double movementThresholdMeters = 20.0;

  /// Ignore GPS jitter below this distance.
  static const double minimumMovementMeters = 5.0;

  /// Indoor movement threshold.
  static const double indoorMovementMeters = 80.0;

  /// Reject impossible GPS jumps.
  static const double maxJumpMeters = 1000.0;

  // ===========================================================================
  // Speed Thresholds
  // ===========================================================================

  /// Minimum moving speed (m/s).
  static const double minimumSpeedMps = 1.5;

  /// Walking speed.
  static const double walkingSpeedMps = 2.0;

  /// Driving speed.
  static const double drivingSpeedMps = 8.0;

  /// Reject impossible GPS speed.
  static const double maximumAllowedSpeedMps = 70.0;

  // ===========================================================================
  // Accuracy
  // ===========================================================================

  static const double maxAcceptableAccuracyMeters = 50.0;

  static const double maxIndoorAccuracyMeters = 100.0;

  // ===========================================================================
  // Timing
  // ===========================================================================

  /// Ignore duplicate updates inside this duration.
  static const Duration minSyncCooldown = Duration(seconds: 3);

  /// Position considered stale after this.
  static const Duration stalePositionThreshold = Duration(seconds: 12);

  /// Stationary heartbeat.
  static const Duration stationaryHeartbeatMaxInterval = Duration(minutes: 10);

  // ===========================================================================
  // Queue
  // ===========================================================================

  static const int maxOfflineLocations = 5000;

  static const int bulkSyncBatchSize = 100;

  static const int maxUploadQueueSize = 50;

  // ===========================================================================
  // Upload Decision
  // ===========================================================================

  static bool shouldSyncMovement({
    required Position? lastProcessedPosition,
    required Position currentPosition,
  }) {
    if (lastProcessedPosition == null) {
      return true;
    }

    final distance = Geolocator.distanceBetween(
      lastProcessedPosition.latitude,
      lastProcessedPosition.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    final elapsed = currentPosition.timestamp.difference(
      lastProcessedPosition.timestamp,
    );

    // -------------------------------------------------------------------------
    // Invalid timestamps
    // -------------------------------------------------------------------------

    if (elapsed.isNegative) {
      return false;
    }

    // -------------------------------------------------------------------------
    // Duplicate GPS callbacks
    // -------------------------------------------------------------------------

    if (distance < 3 && elapsed < minSyncCooldown) {
      return false;
    }

    // -------------------------------------------------------------------------
    // Impossible GPS jump
    // -------------------------------------------------------------------------

    if (distance > maxJumpMeters && elapsed.inSeconds < 5) {
      return false;
    }

    // -------------------------------------------------------------------------
    // Heartbeat upload
    // -------------------------------------------------------------------------

    if (distance < minimumMovementMeters &&
        elapsed >= stationaryHeartbeatMaxInterval) {
      return true;
    }

    // -------------------------------------------------------------------------
    // Good GPS accuracy
    // -------------------------------------------------------------------------

    if (currentPosition.accuracy <= maxAcceptableAccuracyMeters) {
      if (distance >= movementThresholdMeters) {
        return true;
      }

      if (distance >= minimumMovementMeters &&
          currentPosition.speed >= minimumSpeedMps) {
        return true;
      }

      return false;
    }

    // -------------------------------------------------------------------------
    // Indoor GPS
    // -------------------------------------------------------------------------

    if (currentPosition.accuracy <= maxIndoorAccuracyMeters) {
      if (distance >= indoorMovementMeters) {
        return true;
      }

      if (currentPosition.speed >= walkingSpeedMps &&
          distance >= minimumMovementMeters) {
        return true;
      }
    }

    return false;
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  static bool isAccurate(Position position) {
    return position.accuracy <= maxAcceptableAccuracyMeters;
  }

  static bool isIndoorAccuracy(Position position) {
    return position.accuracy > maxAcceptableAccuracyMeters &&
        position.accuracy <= maxIndoorAccuracyMeters;
  }

  static bool isValidSpeed(double speed) {
    if (!speed.isFinite || speed.isNaN) {
      return false;
    }

    return speed >= 0 && speed <= maximumAllowedSpeedMps;
  }

  static bool isMoving(Position position) {
    return isValidSpeed(position.speed) && position.speed >= minimumSpeedMps;
  }

  static double normalizeSpeed(double speed) {
    if (!isValidSpeed(speed)) {
      return 0.0;
    }

    return speed * 3.6;
  }

  static double normalizeHeading(double heading) {
    if (!heading.isFinite || heading.isNaN || heading < 0) {
      return 0.0;
    }

    return heading % 360.0;
  }

  /// Exponential retry with random jitter.
  ///
  /// Attempts:
  /// 1 -> 2-3 sec
  /// 2 -> 4-5 sec
  /// 3 -> 8-11 sec
  /// 4 -> 16-19 sec
  static Duration calculateRetryDelay(int attempt) {
    final base = 1 << (attempt + 1);

    final jitter = Random().nextInt(base ~/ 2 + 1);

    return Duration(seconds: base + jitter);
  }
}

// endregion
