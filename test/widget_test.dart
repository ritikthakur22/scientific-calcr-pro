import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_calcr_pro/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Mock Sqflite Method Channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.tekartik.sqflite'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getDatabasesPath') {
          return '/mock/databases/path';
        }
        if (methodCall.method == 'openDatabase') {
          return 1; // Database ID
        }
        if (methodCall.method == 'query') {
          return []; // Return empty list for query results
        }
        if (methodCall.method == 'insert') {
          return 1; // Insert ID
        }
        return null;
      },
    );
  });

  testWidgets('Calculator app rendering smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ScientificCalcrProApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the calculator top screen renders with standard 0
    expect(find.text('0'), findsWidgets);
  });
}
