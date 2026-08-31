import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mfresh_ops/core/config/app_config.dart';

/// Singleton reverse-geocoding service with an in-memory cache.
/// Uses the device-native geocoding library (no API key required).
/// Falls back to OpenStreetMap (Nominatim) REST API if native fails (e.g. on Windows/Web).
class GeocodingService {
  GeocodingService._();
  static final GeocodingService instance = GeocodingService._();

  // Cache: "lat,lng" → human-readable address
  final Map<String, String> _cache = {};

  // Track in-flight requests so we don't duplicate them
  final Map<String, Future<String>> _pending = {};
  
  final Dio _dio = Dio();

  /// Resolve a "lat, lng" coordinate string (as returned by the API) to a
  /// short human-readable address.  Returns the raw string on any error.
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

  Future<String> _fetch(String key) async {
    try {
      final parts = key.split(',');
      if (parts.length < 2) return key;
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat == null || lng == null) return key;

      // 1. Try native geocoding (fastest on iOS/Android)
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
            final address = components.take(2).join(', ');
            _cache[key] = address;
            return address;
          }
        }
      } catch (_) {
        // Native failed (often happens on Windows/Web or emulators)
      }

      // 2. Fallback to Google Maps Geocoding API
      try {
        final apiKey = AppConfig.googleMapsApiKey;
        if (apiKey.isNotEmpty) {
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
              final formattedAddress = results.first['formatted_address'] as String?;
              if (formattedAddress != null && formattedAddress.isNotEmpty) {
                // Keep it short: take the first two components separated by comma
                final components = formattedAddress.split(',').map((e) => e.trim()).toList();
                final address = components.take(3).join(', ');
                _cache[key] = address;
                return address;
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Google Maps Geocoding failed: $e');
      }

    } catch (e) {
      debugPrint('Geocoding parse error: $e');
    }
    
    // 3. Ultimate Fallback: short formatted coords
    final parts = key.split(',');
    final fallback = parts.length >= 2
        ? '${double.tryParse(parts[0].trim())?.toStringAsFixed(4)}, '
          '${double.tryParse(parts[1].trim())?.toStringAsFixed(4)}'
        : key;
    _cache[key] = fallback;
    return fallback;
  }

  /// Clear the cache (useful for testing or memory pressure).
  void clear() => _cache.clear();
}
