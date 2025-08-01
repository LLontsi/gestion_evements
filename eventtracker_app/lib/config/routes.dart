import 'package:flutter/material.dart';
/*import 'screens/splash_screen.dart';

import 'screens/gifts/gifts_screen.dart';
import 'screens/gifts/create_gift_screen.dart';
import 'screens/guests/guests_screen.dart';
import 'screens/guests/add_guest_screen.dart';
import 'screens/planning/planning_screen.dart';
import 'screens/planning/create_task_screen.dart';
import 'screens/photos/photos_screen.dart';
import 'screens/photos/photo_viewer_screen.dart';
import 'screens/messages/messages_screen.dart';
import 'screens/messages/chat_screen.dart';*/
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/profile_screen.dart';
import '../screens/events/events_screen.dart';
import '../screens/events/event_details_screen.dart';
import '../screens/events/create_event_screen.dart';
import '../screens/gifts/gifts_screen.dart';
import '../screens/gifts/create_gift_screen.dart';
import '../screens/guests/guests_screen.dart';
import '../screens/guests/add_guest_screen.dart';
import '../screens/planning/planning_screen.dart';
import '../screens/planning/create_task_screen.dart';
import '../screens/photos/photos_screen.dart';
import '../screens/photos/photo_viewer_screen.dart';
import '../screens/messages/messages_screen.dart';
import '../screens/messages/chat_screen.dart';

class Routes {
  // Routes statiques (sans paramètres)
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/home': (context) => const HomeScreen(),
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    '/profile': (context) => const ProfileScreen(),
    '/events': (context) => const EventsScreen(),
    '/messages': (context) => const MessagesScreen(),
  };

  // Routes dynamiques (avec paramètres)
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extraction des arguments et des noms de routes
    final args = settings.arguments;

    switch (settings.name) {
      case '/event_details':
        final eventId = args as String;
        return MaterialPageRoute(
          builder: (context) => EventDetailsScreen(eventId: eventId),
        );

      case '/create_event':
        return MaterialPageRoute(
          builder: (context) => CreateEventScreen(event: args as dynamic),
        );

      case '/gifts':
        final eventId = args as String;
        return MaterialPageRoute(
          builder: (context) => GiftsScreen(eventId: eventId),
        );

      case '/create_gift':
        final Map<String, dynamic> params = args as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => CreateGiftScreen(
            eventId: params['eventId'] as String,
            gift: params['gift'],
          ),
        );

      case '/guests':
        final eventId = args as String;
        return MaterialPageRoute(
          builder: (context) => GuestsScreen(eventId: eventId),
        );

      case '/add_guest':
        final Map<String, dynamic> params = args as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => AddGuestScreen(
            eventId: params['eventId'] as String,
            guest: params['guest'],
          ),
        );

      case '/planning':
        final eventId = args as String;
        return MaterialPageRoute(
          builder: (context) => PlanningScreen(eventId: eventId),
        );

      case '/create_task':
        final Map<String, dynamic> params = args as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => CreateTaskScreen(
            eventId: params['eventId'] as String,
            task: params['task'],
          ),
        );

      case '/photos':
        final eventId = args as String;
        return MaterialPageRoute(
          builder: (context) => PhotosScreen(eventId: eventId),
        );

      case '/photo_viewer':
        final Map<String, dynamic> params = args as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => PhotoViewerScreen(
            photos: params['photos'],
            initialIndex: params['initialIndex'] ?? 0,
          ),
        );

      case '/chat':
        final Map<String, dynamic> params = args as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => ChatScreen(
            eventId: params['eventId'] as String,
            receiverId: params['receiverId'] as String,
          ),
        );

      // Route par défaut en cas d'erreur
      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Page introuvable'),
            ),
          ),
        );
    }
  }

  // Méthode pour configurer le router dans MaterialApp
  static MaterialApp configureRouter(Widget home) {
    return MaterialApp(
      initialRoute: '/',
      routes: routes,
      onGenerateRoute: generateRoute,
      home: home,
    );
  }
}