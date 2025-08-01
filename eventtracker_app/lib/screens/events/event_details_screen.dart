import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../guests/guests_screen.dart';
import '../planning/planning_screen.dart';
import '../gifts/gifts_screen.dart';
import '../photos/photos_screen.dart';
import 'create_event_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  EventModel? event;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      event = await eventProvider.getEventById(widget.eventId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement de l\'événement: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _editEvent() {
    if (event == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(event: event),
      ),
    ).then((_) => _loadEventDetails());
  }

  Future<void> _deleteEvent() async {
    if (event == null) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      await eventProvider.deleteEvent(event!.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Événement supprimé avec succès')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
      
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showDeleteConfirmation() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cet événement ? Cette action est irréversible.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEvent();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: isLoading ? 'Chargement...' : event?.title ?? 'Détails de l\'événement',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: isLoading ? null : _editEvent,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: isLoading ? null : _showDeleteConfirmation,
          ),
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              _buildEventHeader(),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.people), text: 'Invités'),
                  Tab(icon: Icon(Icons.list), text: 'Tâches'),
                  Tab(icon: Icon(Icons.card_giftcard), text: 'Cadeaux'),
                  Tab(icon: Icon(Icons.photo_library), text: 'Photos'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    GuestsScreen(eventId: widget.eventId),
                    PlanningScreen(eventId: widget.eventId),
                    GiftsScreen(eventId: widget.eventId),
                    PhotosScreen(eventId: widget.eventId),
                  ],
                ),
              ),
            ],
          ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildEventHeader() {
    if (event == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event!.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 8),
              Text(event!.formattedDate),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 8),
              Text(event!.formattedTime),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(event!.location)),
            ],
          ),
          if (event!.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              event!.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (isLoading) return null;
    
    final currentTab = _tabController.index;
    
    switch (currentTab) {
      case 0: // Invités
        return FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(
              context, 
              '/add_guest', 
              arguments: {'eventId': widget.eventId}
            );
          },
          child: const Icon(Icons.person_add),
        );
      case 1: // Tâches
        return FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(
              context, 
              '/create_task', 
              arguments: {'eventId': widget.eventId}
            );
          },
          child: const Icon(Icons.add_task),
        );
      case 2: // Cadeaux
        return FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(
              context, 
              '/create_gift', 
              arguments: {'eventId': widget.eventId}
            );
          },
          child: const Icon(Icons.card_giftcard),
        );
      case 3: // Photos
        return FloatingActionButton(
          onPressed: () {
            // Ajouter une photo
          },
          child: const Icon(Icons.add_a_photo),
        );
      default:
        return null;
    }
  }
}