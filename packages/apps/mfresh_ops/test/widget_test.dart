import 'package:flutter_test/flutter_test.dart';
import 'package:mfresh_ops/main.dart';

void main() {
  testWidgets('mFresh Ops smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OpsApp());

    // Verify that our operations app text is present
    expect(find.text('mFresh Ops - Operations App'), findsOneWidget);
  });
}
