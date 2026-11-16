import 'dart:convert';

class AppUpdateConfig {
  final String currentIosAppVersion;
  final int currentIosAppBuildNumber;
  final bool isIosForceUpdate;
  final String appleStoreUrl;

  final String currentAndroidAppVersion;
  final int currentAndroidAppBuildNumber;
  final bool isAndroidForceUpdate;
  final String googlePlayStoreUrl;

  final String updateMessage;

  AppUpdateConfig({
    required this.currentIosAppVersion,
    required this.currentIosAppBuildNumber,
    required this.isIosForceUpdate,
    required this.appleStoreUrl,
    required this.currentAndroidAppVersion,
    required this.currentAndroidAppBuildNumber,
    required this.isAndroidForceUpdate,
    required this.googlePlayStoreUrl,
    required this.updateMessage,
  });

  factory AppUpdateConfig.fromRemoteConfig(String jsonStr) {
    final Map<String, dynamic> data = json.decode(jsonStr);
    return AppUpdateConfig(
      currentIosAppVersion: data['ios_version'] ?? '1.0.0',
      currentIosAppBuildNumber: data['ios_build'] ?? 1,
      isIosForceUpdate: data['ios_force_update'] ?? false,
      appleStoreUrl: data['ios_store_url'] ?? '',
      currentAndroidAppVersion: data['android_version'] ?? '1.0.0',
      currentAndroidAppBuildNumber: data['android_build'] ?? 1,
      isAndroidForceUpdate: data['android_force_update'] ?? false,
      googlePlayStoreUrl: data['android_store_url'] ?? '',
      updateMessage: data['update_message'] ?? 'A new version is available!',
    );
  }
}
