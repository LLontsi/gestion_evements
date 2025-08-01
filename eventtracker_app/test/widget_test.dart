// This is a basic Flutter widget test.
// 
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

//import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:eventtracker_app/app.dart';
import 'package:eventtracker_app/providers/auth_provider.dart';
import 'package:eventtracker_app/providers/event_provider.dart';
import 'package:eventtracker_app/providers/gift_provider.dart';
import 'package:eventtracker_app/providers/guest_provider.dart';
import 'package:eventtracker_app/providers/task_provider.dart';
import 'package:eventtracker_app/providers/photo_provider.dart';
import 'package:eventtracker_app/providers/theme_provider.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => EventProvider()),
          ChangeNotifierProvider(create: (_) => GiftProvider()),
          ChangeNotifierProvider(create: (_) => GuestProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => PhotoProvider()),
        ],
        child: const EventTrackerApp(),
      ),
    );

    // Verify that the splash screen is displayed
    expect(find.text('EventTracker'), findsOneWidget);
    expect(find.text('Organisez vos événements simplement'), findsOneWidget);
  });
}