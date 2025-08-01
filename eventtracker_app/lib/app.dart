import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'providers/theme_provider.dart';
//import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';

class EventTrackerApp extends StatelessWidget {
  const EventTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    //final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      title: 'EventTracker',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      locale: const Locale('fr', 'FR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
       initialRoute: '/',
      routes: Routes.routes,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}