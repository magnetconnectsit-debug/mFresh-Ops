import 'dart:convert';

class AppUpdateConfig {
  final String currentIosAppVersion;
  final int currentIosAppBuildNumber;
  final bool isIosForceUpdate;
  final String updateMessage;
  final String appleStoreUrl;

  AppUpdateConfig({
    required this.currentIosAppVersion,
    required this.currentIosAppBuildNumber,
    required this.isIosForceUpdate,
    required this.updateMessage,
    required this.appleStoreUrl,
  });

  factory AppUpdateConfig.fromRemoteConfig(String jsonStr) {
    final Map<String, dynamic> data = json.decode(jsonStr);
    return AppUpdateConfig(
      currentIosAppVersion: data['current_ios_app_version'] ?? '1.0.0',
      currentIosAppBuildNumber: data['current_ios_app_build_number'] ?? 0,
      isIosForceUpdate: data['is_ios_force_update'] ?? false,
      updateMessage: data['update_message'] ?? 'A new version is available.',
      appleStoreUrl: data['apple_store_url'] ?? '',
    );
  }
}










