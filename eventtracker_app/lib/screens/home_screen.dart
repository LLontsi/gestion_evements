import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../models/event_model.dart';
import '../models/user.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/event_card.dart';
import '../widgets/upcoming_events_list.dart';
import 'events/event_details_screen.dart';
import 'events/create_event_screen.dart';
import 'gifts/gifts_screen.dart';
import 'guests/guests_screen.dart';
import 'planning/planning_screen.dart';
import 'photos/photos_screen.dart';
import 'messages/messages_screen.dart';
import '../screens/auth/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Événements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_event').then((_) {
            if (_selectedIndex == 0) {
              final dashboardKey = _dashboardKey.currentState;
              if (dashboardKey != null) {
                dashboardKey.loadData();
              }
            } else if (_selectedIndex == 1) {
              final eventsKey = _eventsKey.currentState;
              if (eventsKey != null) {
                eventsKey.loadData();
              }
            }
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'Créer un événement',
      ),
    );
  }

  final GlobalKey<_DashboardPageState> _dashboardKey = GlobalKey<_DashboardPageState>();
  final GlobalKey<_EventsPageState> _eventsKey = GlobalKey<_EventsPageState>();

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return DashboardPage(key: _dashboardKey);
      case 1:
        return EventsPage(key: _eventsKey);
      case 2:
        return const MessagesPage();
      case 3:
        return const ProfilePage();
      default:
        return DashboardPage(key: _dashboardKey);
    }
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    // Utiliser addPostFrameCallback pour éviter les appels pendant le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }
  
  Future<void> loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      await eventProvider.fetchEvents();
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToFeature(BuildContext context, String feature, String? eventId) {
    if (eventId == null) {
      // Si aucun événement n'est sélectionné, afficher un message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un événement d\'abord'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    switch (feature) {
      case 'gifts':
        Navigator.pushNamed(
          context,
          '/gifts',
          arguments: eventId,
        );
        break;
      case 'guests':
        Navigator.pushNamed(
          context,
          '/guests',
          arguments: eventId,
        );
        break;
      case 'tasks':
        Navigator.pushNamed(
          context,
          '/planning',
          arguments: eventId,
        );
        break;
      case 'photos':
        Navigator.pushNamed(
          context,
          '/photos',
          arguments: eventId,
        );
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'EventTracker',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bannière de bienvenue
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenue, ${authProvider.user?.name ?? 'Utilisateur'}!',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Organisez vos événements et restez connecté avec vos proches.',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Créer un événement'),
                              onPressed: () {
                                Navigator.pushNamed(context, '/create_event')
                                  .then((_) => loadData());
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Événements à venir
                    const Text(
                      'Événements à venir',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (eventProvider.events.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Aucun événement à venir',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Créez un événement pour commencer à organiser vos activités',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: eventProvider.events.length,
                          itemBuilder: (context, index) {
                            final event = eventProvider.events[index];
                            return Container(
                              width: 250,
                              margin: const EdgeInsets.only(right: 16),
                              child: EventCard(
                                event: event,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/event_details',
                                  arguments: event.id,
                                ).then((_) => loadData()),
                              ),
                            );
                          },
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Fonctionnalités
                    const Text(
                      'Fonctionnalités',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _buildFeatureCard(
                          context,
                          icon: Icons.card_giftcard,
                          title: 'Listes de cadeaux',
                          color: Colors.purple,
                          onTap: () {
                            // Sélectionner l'événement pour accéder aux cadeaux
                            final selectedEvent = eventProvider.events.isNotEmpty 
                                ? eventProvider.events.first.id
                                : null;
                            _navigateToFeature(context, 'gifts', selectedEvent);
                          },
                        ),
                        _buildFeatureCard(
                          context,
                          icon: Icons.people,
                          title: 'Invités',
                          color: Colors.blue,
                          onTap: () {
                            final selectedEvent = eventProvider.events.isNotEmpty 
                                ? eventProvider.events.first.id
                                : null;
                            _navigateToFeature(context, 'guests', selectedEvent);
                          },
                        ),
                        _buildFeatureCard(
                          context,
                          icon: Icons.check_circle,
                          title: 'Tâches',
                          color: Colors.green,
                          onTap: () {
                            final selectedEvent = eventProvider.events.isNotEmpty 
                                ? eventProvider.events.first.id
                                : null;
                            _navigateToFeature(context, 'tasks', selectedEvent);
                          },
                        ),
                        _buildFeatureCard(
                          context,
                          icon: Icons.photo_library,
                          title: 'Photos',
                          color: Colors.amber,
                          onTap: () {
                            final selectedEvent = eventProvider.events.isNotEmpty 
                                ? eventProvider.events.first.id
                                : null;
                            _navigateToFeature(context, 'photos', selectedEvent);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  void initState() {
    super.initState();
    // Utiliser addPostFrameCallback pour éviter les appels pendant le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  Future<void> loadData() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.fetchUpcomingEvents();
    await eventProvider.fetchPastEvents();
  }

  void _onEventTap(EventModel event) {
    Navigator.pushNamed(
      context,
      '/event_details',
      arguments: event.id,
    ).then((_) => loadData());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Événements'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'À venir'),
              Tab(text: 'Passés'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUpcomingEventsList(),
            _buildPastEventsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEventsList() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        if (eventProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (eventProvider.upcomingEvents.isEmpty) {
          return const Center(
            child: Text('Aucun événement à venir'),
          );
        }

        return ListView.builder(
          itemCount: eventProvider.upcomingEvents.length,
          itemBuilder: (context, index) {
            final event = eventProvider.upcomingEvents[index];
            return EventCard(
              event: event,
              onTap: () => _onEventTap(event),
            );
          },
        );
      },
    );
  }

  Widget _buildPastEventsList() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        if (eventProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (eventProvider.pastEvents.isEmpty) {
          return const Center(
            child: Text('Aucun événement passé'),
          );
        }

        return ListView.builder(
          itemCount: eventProvider.pastEvents.length,
          itemBuilder: (context, index) {
            final event = eventProvider.pastEvents[index];
            return EventCard(
              event: event,
              onTap: () => _onEventTap(event),
            );
          },
        );
      },
    );
  }
}

class MessagesPage extends StatelessWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Messages',
        showBackButton: false,
      ),
      body: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const MessagesScreen(),
            settings: settings,
          );
        },
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profil',
        showBackButton: false,
      ),
      body: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
            settings: settings,
          );
        },
      ),
    );
  }
}
