import 'dart:async';
import 'package:geolocator/geolocator.dart';

abstract class LocationService {
  Future<Position?> getCurrentPosition();
  Stream<Position> getPositionStream();
  Future<bool> requestPermissions();
  Future<bool> isLocationServiceEnabled();
}

class GeolocatorLocationService implements LocationService {
  @override
  Future<Position?> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation),
    );
  }

  @override
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    );
  }

  @override
  Future<bool> requestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
