// lib/screens/events/event_details_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import 'create_event_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  
  const EventDetailsScreen({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    final timeFormat = DateFormat('HH:mm');
    
    // Convertir la couleur hexadécimale en Color
    Color eventColor = Color(int.parse(widget.event.eventTypeColor.replaceAll('#', '0xFF')));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de l\'événement'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => CreateEventScreen(eventToEdit: widget.event),
                ),
              ).then((_) => _refreshEvent());
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte principale avec les détails de l'événement
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bannière colorée avec type d'événement
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          decoration: BoxDecoration(
                            color: eventColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getEventIcon(widget.event.eventTypeName),
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(width: 8),
                              Text(
                                widget.event.eventTypeName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Contenu principal
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.event.title,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              
                              // Date et heure
                              _buildInfoRow(
                                icon: Icons.calendar_today,
                                title: 'Date',
                                content: dateFormat.format(widget.event.startDate),
                              ),
                              SizedBox(height: 12),
                              _buildInfoRow(
                                icon: Icons.access_time,
                                title: 'Heure',
                                content: timeFormat.format(widget.event.startDate),
                              ),
                              
                              // Date et heure de fin si disponible
                              if (widget.event.endDate != null) ...[
                                SizedBox(height: 12),
                                _buildInfoRow(
                                  icon: Icons.event_available,
                                  title: 'Fin',
                                  content: '${dateFormat.format(widget.event.endDate!)} à ${timeFormat.format(widget.event.endDate!)}',
                                ),
                              ],
                              
                              // Lieu si disponible
                              if (widget.event.location.isNotEmpty) ...[
                                SizedBox(height: 12),
                                _buildInfoRow(
                                  icon: Icons.location_on,
                                  title: 'Lieu',
                                  content: widget.event.location,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Description
                  if (widget.event.description.isNotEmpty) ...[
                    SizedBox(height: 24),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          widget.event.description,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                  
                  // Fonctionnalités disponibles (vues non encore implémentées)
                  SizedBox(height: 24),
                  Text(
                    'Fonctionnalités',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  // Grille des fonctionnalités
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildFeatureCard(
                        context,
                        icon: Icons.people,
                        title: 'Invités',
                        color: Colors.blue,
                        onTap: () => _navigateToFeature('guests'),
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.card_giftcard,
                        title: 'Liste de cadeaux',
                        color: Colors.purple,
                        onTap: () => _navigateToFeature('gifts'),
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.check_circle,
                        title: 'Tâches',
                        color: Colors.green,
                        onTap: () => _navigateToFeature('tasks'),
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.photo_library,
                        title: 'Photos',
                        color: Colors.amber,
                        onTap: () => _navigateToFeature('photos'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[700], size: 20),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
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
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
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
  
  void _navigateToFeature(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fonctionnalité "$feature" à implémenter'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Ces navigations seront décommentées au fur et à mesure que vous implémentez les écrans
    /*
    switch (feature) {
      case 'guests':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => GuestsScreen(eventId: widget.event.id),
          ),
        );
        break;
      case 'gifts':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => GiftsScreen(eventId: widget.event.id),
          ),
        );
        break;
      // etc.
    }
    */
  }
  
  IconData _getEventIcon(String typeName) {
    switch (typeName.toLowerCase()) {
      case 'anniversaire':
        return Icons.cake;
      case 'mariage':
        return Icons.favorite;
      case 'réunion':
        return Icons.people;
      case 'fête':
        return Icons.celebration;
      case 'deuil':
        return Icons.format_color_reset;
      default:
        return Icons.event;
    }
  }
  
  Future<void> _refreshEvent() async {
    setState(() {
      _isLoading = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    if (authProvider.isLoggedIn && authProvider.token != null) {
      await eventProvider.fetchEvents(authProvider.token!);
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Supprimer l\'événement'),
        content: Text('Êtes-vous sûr de vouloir supprimer cet événement ? Cette action est irréversible.'),
        actions: [
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      _deleteEvent();
    }
  }
  
  Future<void> _deleteEvent() async {
    setState(() {
      _isLoading = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    if (authProvider.isLoggedIn && authProvider.token != null) {
      final success = await eventProvider.deleteEvent(widget.event.id, authProvider.token!);
      
      if (success && mounted) {
        Navigator.of(context).pop(); // Retour à l'écran précédent
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression de l\'événement')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}