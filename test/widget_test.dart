import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:so9ne_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: So9neApp()));

    // Verify that the app builds successfully (at least finding a MaterialApp)
    expect(find.byType(So9neApp), findsOneWidget);
  });
}
