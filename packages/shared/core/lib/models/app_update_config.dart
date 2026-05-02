import 'dart:convert';

class AppUpdateConfig {
  final String currentIosAppVersion;
  final int currentIosAppBuildNumber;
  final bool isIosForceUpdate;
  final String appleStoreUrl;
  final String updateMessage;

  AppUpdateConfig({
    required this.currentIosAppVersion,
    required this.currentIosAppBuildNumber,
    required this.isIosForceUpdate,
    required this.appleStoreUrl,
    required this.updateMessage,
  });

  factory AppUpdateConfig.fromRemoteConfig(String jsonStr) {
    final Map<String, dynamic> data = json.decode(jsonStr);
    return AppUpdateConfig(
      currentIosAppVersion: data['ios_version'] ?? '1.0.0',
      currentIosAppBuildNumber: data['ios_build'] ?? 1,
      isIosForceUpdate: data['ios_force_update'] ?? false,
      appleStoreUrl: data['ios_store_url'] ?? '',
      updateMessage: data['update_message'] ?? 'A new version is available!',
    );
  }
}
