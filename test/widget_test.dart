// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:smart_document_search_frontend/main.dart';

void main() {
  testWidgets('App renders onboarding screen (smoke test)',
      (WidgetTester tester) async {
    // Firebase options are environment-specific; keep firebaseReady=false in tests.
    await tester.pumpWidget(const SmartDocumentSearchApp(firebaseReady: false));
    await tester.pump();

    expect(find.text('Smart Document Search Engine'), findsOneWidget);
  });
}
