import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/guest_model.dart';
import '../../providers/guest_provider.dart';
import '../../widgets/guest_list_item.dart';
import 'add_guest_screen.dart';

class GuestsScreen extends StatefulWidget {
  final String eventId;

  const GuestsScreen({super.key, required this.eventId});

  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  bool _isLoading = false;
  List<GuestModel> _guests = [];
  GuestStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadGuests();
  }

  Future<void> _loadGuests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final guestProvider = Provider.of<GuestProvider>(context, listen: false);
      _guests = await guestProvider.getGuestsByEvent(widget.eventId);
      _applyFilter();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des invités: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_filterStatus != null) {
      final guestProvider = Provider.of<GuestProvider>(context, listen: false);
      final allGuests = guestProvider.getGuestsForEvent(widget.eventId);
      setState(() {
        _guests = allGuests.where((guest) => guest.status == _filterStatus).toList();
      });
    } else {
      final guestProvider = Provider.of<GuestProvider>(context, listen: false);
      setState(() {
        _guests = guestProvider.getGuestsForEvent(widget.eventId);
      });
    }
  }

  void _onAddGuest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGuestScreen(eventId: widget.eventId),
      ),
    ).then((_) => _loadGuests());
  }

  void _onGuestTap(GuestModel guest) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGuestScreen(
          eventId: widget.eventId,
          guest: guest,
        ),
      ),
    ).then((_) => _loadGuests());
  }

  Future<void> _sendInvitation(String guestId) async {
    try {
      final guestProvider = Provider.of<GuestProvider>(context, listen: false);
      await guestProvider.sendInvitation(guestId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitation envoyée avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _sendReminder(String guestId) async {
    try {
      final guestProvider = Provider.of<GuestProvider>(context, listen: false);
      await guestProvider.sendReminder(guestId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rappel envoyé avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Tous les invités'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _filterStatus = null;
              });
              _applyFilter();
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: const Text('Présents'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _filterStatus = GuestStatus.confirmed;
              });
              _applyFilter();
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel, color: Colors.red),
            title: const Text('Absents'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _filterStatus = GuestStatus.declined;
              });
              _applyFilter();
            },
          ),
          ListTile(
            leading: const Icon(Icons.help, color: Colors.orange),
            title: const Text('En attente'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _filterStatus = GuestStatus.pending;
              });
              _applyFilter();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Liste des invités',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Bouton de filtre
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterOptions,
                ),
              ],
            ),
          ),
          // Statistiques des invités
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildGuestStats(),
          ),
          const SizedBox(height: 8),
          // Liste des invités
          Expanded(
            child: _guests.isEmpty
                ? _buildEmptyState()
                : _buildGuestList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddGuest,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGuestStats() {
    final guestProvider = Provider.of<GuestProvider>(context, listen: false);
    final allGuests = guestProvider.getGuestsForEvent(widget.eventId);
    
    final totalGuests = allGuests.length;
    final confirmedGuests = allGuests.where((g) => g.status == GuestStatus.confirmed).length;
    final declinedGuests = allGuests.where((g) => g.status == GuestStatus.declined).length;
    final pendingGuests = allGuests.where((g) => g.status == GuestStatus.pending).length;
    
    // Calcul du nombre total de personnes (invités + accompagnants)
    final totalPeople = allGuests.fold(0, (sum, guest) => sum + guest.numberOfGuests);
    final confirmedPeople = allGuests
        .where((g) => g.status == GuestStatus.confirmed)
        .fold(0, (sum, guest) => sum + guest.numberOfGuests);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total des invités: $totalGuests (Personnes: $totalPeople)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Présents', confirmedGuests, Colors.green),
                _buildStatItem('Absents', declinedGuests, Colors.red),
                _buildStatItem('En attente', pendingGuests, Colors.orange),
              ],
            ),
            if (confirmedGuests > 0) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Personnes attendues: $confirmedPeople',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun invité pour cet événement',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _onAddGuest,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un invité'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestList() {
    return RefreshIndicator(
      onRefresh: _loadGuests,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _guests.length,
        itemBuilder: (context, index) {
          final guest = _guests[index];
          return GuestListItem(
            guest: guest,
            onTap: () => _onGuestTap(guest),
            onSendInvitation: () => _sendInvitation(guest.id),
            onSendReminder: guest.status == GuestStatus.pending
                ? () => _sendReminder(guest.id)
                : null,
          );
        },
      ),
    );
  }
}