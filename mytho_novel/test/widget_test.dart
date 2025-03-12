import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mytho_novel/main.dart';

void main() {
  testWidgets('Login screen loads and has required fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(isLoggedIn: false));
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Submit'), findsOneWidget);
  });
}
