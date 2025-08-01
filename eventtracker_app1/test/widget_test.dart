//import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:eventtracker_app/providers/auth_provider.dart';
import 'package:eventtracker_app/providers/event_provider.dart';
import 'package:eventtracker_app/providers/theme_provider.dart';
import 'package:eventtracker_app/app.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => EventProvider()),
        ],
        child: const EventTrackerApp(),
      ),
    );

    // Vérifier que l'application se lance sans erreur
    expect(find.byType(EventTrackerApp), findsOneWidget);
  });
}