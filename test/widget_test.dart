import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alertxband_app/main.dart';

void main() {
  testWidgets('AlertXBand splash and dashboard test', (
    WidgetTester tester,
  ) async {
    // Launch the AlertXBand application.
    await tester.pumpWidget(const ProviderScope(child: AlertXBandApp()));

    await tester.pumpAndSettle();

    // Verify splash screen.
    expect(find.text('AlertXBand'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Navigate to dashboard.
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify dashboard.
    expect(find.text('Welcome to AlertXBand Dashboard'), findsOneWidget);
  });
}
