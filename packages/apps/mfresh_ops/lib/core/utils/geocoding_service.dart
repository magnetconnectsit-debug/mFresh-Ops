// region Imports
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mfresh_ops/core/config/app_config.dart';
// endregion

// region Geocoding Service
/// Singleton reverse-geocoding service with an in-memory cache.
/// Uses the Google Maps Geocoding API, device-native geocoding library,
/// and fallback coordinates formatting.
class GeocodingService {
  // region Singleton & State
  GeocodingService._();
  static final GeocodingService instance = GeocodingService._();

  // Cache: "lat,lng" → human-readable address
  final Map<String, String> _cache = {};

  // Track in-flight requests so we don't duplicate them
  final Map<String, Future<String>> _pending = {};

  final Dio _dio = Dio();
  // endregion

  // region Public API
  /// Reverse geocode coordinates directly using the Google Maps Geocoding API key.
  Future<String?> reverseGeocodeGoogleMaps(
    double lat,
    double lng, {
    bool fullAddress = true,
  }) async {
    final cacheKey = 'gmap_${lat.toStringAsFixed(5)},${lng.toStringAsFixed(5)}';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey];

    try {
      final apiKey = AppConfig.googleMapsApiKey;
      if (apiKey.isEmpty) {
        debugPrint('GeocodingService: Google Maps API key is empty');
        return null;
      }

      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': apiKey,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final results = response.data['results'] as List?;
        if (results != null && results.isNotEmpty) {
          final formattedAddress =
              results.first['formatted_address'] as String?;
          if (formattedAddress != null && formattedAddress.isNotEmpty) {
            final address = fullAddress
                ? formattedAddress
                : formattedAddress
                    .split(',')
                    .map((e) => e.trim())
                    .take(3)
                    .join(', ');
            _cache[cacheKey] = address;
            return address;
          }
        }
      }
    } catch (e) {
      debugPrint('GeocodingService.reverseGeocodeGoogleMaps error: $e');
    }
    return null;
  }

  /// Resolve a "lat, lng" coordinate string (as returned by the API) to a
  /// human-readable address. Falls back to native geocoding or short coords.
  Future<String> resolve(String latLngStr) async {
    if (latLngStr.isEmpty || latLngStr == '-') return latLngStr;

    final key = latLngStr.trim();
    if (_cache.containsKey(key)) return _cache[key]!;
    if (_pending.containsKey(key)) return _pending[key]!;

    final future = _fetch(key);
    _pending[key] = future;
    final result = await future;
    _pending.remove(key);
    return result;
  }

  /// Clear the cache (useful for testing or memory pressure).
  void clear() => _cache.clear();
  // endregion

  // region Internal Helpers
  Future<String> _fetch(String key) async {
    try {
      final parts = key.split(',');
      if (parts.length < 2) return key;
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat == null || lng == null) return key;

      // 1. Try Google Maps Geocoding API first
      final gmapAddress = await reverseGeocodeGoogleMaps(lat, lng);
      if (gmapAddress != null && gmapAddress.isNotEmpty) {
        _cache[key] = gmapAddress;
        return gmapAddress;
      }

      // 2. Try native geocoding (iOS/Android)
      try {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final components = [
            p.street,
            p.subLocality,
            p.locality,
            p.administrativeArea,
          ].where((e) => e != null && e.isNotEmpty && !e.contains('+')).toList();
          if (components.isNotEmpty) {
            final address = components.take(3).join(', ');
            _cache[key] = address;
            return address;
          }
        }
      } catch (_) {
        // Native failed
      }
    } catch (e) {
      debugPrint('Geocoding parse error: $e');
    }

    // 3. Fallback: formatted coords
    final parts = key.split(',');
    final fallback = parts.length >= 2
        ? '${double.tryParse(parts[0].trim())?.toStringAsFixed(4)}, '
          '${double.tryParse(parts[1].trim())?.toStringAsFixed(4)}'
        : key;
    _cache[key] = fallback;
    return fallback;
  }
  // endregion
}
// endregion
