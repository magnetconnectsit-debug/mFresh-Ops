import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

class RemoteConfigService extends GetxService {
  FirebaseRemoteConfig? _remoteConfig;
  String _defaultBaseUrl = '';

  Future<RemoteConfigService> init({String defaultBaseUrl = ''}) async {
    _defaultBaseUrl = defaultBaseUrl;
    try {
      // Check if Firebase is initialized
      if (Firebase.apps.isNotEmpty) {
        _remoteConfig = FirebaseRemoteConfig.instance;
        
        await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ));

        // Set default values
        await _remoteConfig!.setDefaults({
          'base_url': _defaultBaseUrl,
          'app_update_settings': '{}',
        });

        await fetchAndActivate();
      } else {
        debugPrint('RemoteConfigService: Firebase not initialized, skipping.');
      }
    } catch (e) {
      debugPrint('RemoteConfigService Error: $e');
    }
    return this;
  }

  Future<void> fetchAndActivate() async {
    if (_remoteConfig == null) return;
    try {
      await _remoteConfig!.fetchAndActivate();
    } catch (e) {
      debugPrint('RemoteConfigService Fetch Error: $e');
    }
  }

  String getBaseUrl() {
    if (_remoteConfig == null) return _defaultBaseUrl;
    final url = _remoteConfig!.getString('base_url');
    return url.isNotEmpty ? url : _defaultBaseUrl;
  }

  String getStringValue(String key) {
    if (_remoteConfig == null) return '';
    return _remoteConfig!.getString(key);
  }
}






