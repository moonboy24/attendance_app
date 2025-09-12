import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../flutter_app/lib/ui/pages/dashboard_page.dart';
import '../flutter_app/lib/ui/pages/login_page.dart';
import 'package:attendance_app/app.dart';
import '../lib/ui/pages/login_page.dart';
import '../lib/ui/pages/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Shows LoginPage when no token is stored', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({}); // no token

    await tester.pumpWidget(const AttendanceApp());
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(DashboardPage), findsNothing);
  });

  testWidgets('Shows DashboardPage when token exists', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({"token": "dummy_jwt_token"}); // mock token

    await tester.pumpWidget(const AttendanceApp());
    await tester.pumpAndSettle();

    expect(find.byType(DashboardPage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
  });
}
