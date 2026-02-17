// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:the_hi_ios_android/app/app.dart';
import 'package:the_hi_ios_android/app/di/service_locator.dart';
import 'package:the_hi_ios_android/core/config/app_config.dart';
import 'package:the_hi_ios_android/core/logging/app_logger.dart';

void main() {
  testWidgets(
    'App boots and shows health check with Supabase not configured message in dev',
    (WidgetTester tester) async {
      resetServiceLocator();
      const AppLogger logger = DebugPrintAppLogger();
      final AppConfig config = AppConfig.development();

      registerSingleton<AppLogger>(logger);
      registerSingleton<AppConfig>(config);

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.textContaining('Environment:'), findsOneWidget);
      expect(find.textContaining('Supabase is not configured'), findsOneWidget);
    },
  );
}

