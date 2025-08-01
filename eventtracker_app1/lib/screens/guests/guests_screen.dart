// lib/screens/guests/guests_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/guest_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guest_provider.dart';
import 'add_guest_screen.dart';

class GuestsScreen extends StatefulWidget {
  final int eventId;
  
  const GuestsScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  _GuestsScreenState createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadGuests();
  }
  
  Future<void> _loadGuests() async {
    setState(() {
      _isLoading = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final guestProvider = Provider.of<GuestProvider>(context, listen: false);
    
    if (authProvider.isLoggedIn && authProvider.token != null) {
      await guestProvider.fetchGuests(widget.eventId, authProvider.token!);
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final guestProvider = Provider.of<GuestProvider>(context);
    final guests = guestProvider.guests;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Invités'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadGuests,
              child: guests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucun invité',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Ajoutez des invités en appuyant sur le bouton +',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: guests.length,
                      itemBuilder: (context, index) {
                        final guest = guests[index];
                        return _buildGuestCard(guest);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => AddGuestScreen(eventId: widget.eventId),
            ),
          ).then((_) => _loadGuests());
        },
        child: Icon(Icons.add),
        tooltip: 'Ajouter un invité',
      ),
    );
  }
  
  Widget _buildGuestCard(Guest guest) {
    Color statusColor;
    String statusText;
    
    switch (guest.responseStatus) {
      case 'accepted':
        statusColor = Colors.green;
        statusText = 'Accepté';
        break;
      case 'declined':
        statusColor = Colors.red;
        statusText = 'Refusé';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'En attente';
    }
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            guest.name.isNotEmpty ? guest.name[0].toUpperCase() : '?',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        title: Text(guest.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (guest.email.isNotEmpty)
              Text(guest.email),
            if (guest.phone.isNotEmpty)
              Text(guest.phone),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          // Ouvrir les détails de l'invité (à implémenter)
        },
      ),
    );
  }
}