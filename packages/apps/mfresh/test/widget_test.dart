import 'package:flutter_test/flutter_test.dart';
import 'package:mfresh/main.dart';
import 'package:get/get.dart';
import 'package:services/settings_service.dart';
import 'package:services/storage_service.dart';
import 'package:flutter/material.dart';

// Simple Mocks
class MockStorageService extends GetxService implements StorageService {
  @override String? getToken() => null;
  @override bool getShowLogger() => false;
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSettingsService extends GetxService implements SettingsService {
  @override final RxBool showLogger = false.obs;
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    Get.put<StorageService>(MockStorageService());
    Get.put<SettingsService>(MockSettingsService());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('App smoke test - checks for login screen title', (WidgetTester tester) async {
    // Ignore overflows in tests as ScreenUtil scaling can be tricky in headless environments
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('overflowed')) {
        return;
      }
      FlutterError.presentError(details);
    };

    // Set a large viewport
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const MyApp());
    await tester.pump(); 
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Login your Account'), findsOneWidget);
  });
}
