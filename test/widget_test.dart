import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:im_muslim/core/providers/preferences_provider.dart';
import 'package:im_muslim/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('Splash screen shows branding in RTL', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const Directionality(
          textDirection: TextDirection.rtl,
          child: MaterialApp(home: SplashScreen()),
        ),
      ),
    );

    expect(find.text('المسلم'), findsOneWidget);
    expect(find.text('رفيقك اليومي'), findsOneWidget);
    final directionality = tester.widget<Directionality>(
      find.byType(Directionality).first,
    );
    expect(directionality.textDirection, TextDirection.rtl);

    // Ensure delayed splash timer is drained before test teardown.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 4));
  });
}
