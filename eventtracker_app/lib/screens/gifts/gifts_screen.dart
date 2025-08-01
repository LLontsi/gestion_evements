import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/gift_model.dart';
import '../../providers/gift_provider.dart';
import 'create_gift_screen.dart';

class GiftsScreen extends StatefulWidget {
  final String eventId;

  const GiftsScreen({super.key, required this.eventId});

  @override
  State<GiftsScreen> createState() => _GiftsScreenState();
}

class _GiftsScreenState extends State<GiftsScreen> {
  bool _isLoading = false;
  List<GiftModel> _gifts = [];

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final giftProvider = Provider.of<GiftProvider>(context, listen: false);
      _gifts = await giftProvider.getGiftsByEvent(widget.eventId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des cadeaux: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onAddGift() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGiftScreen(eventId: widget.eventId),
      ),
    ).then((_) => _loadGifts());
  }

  void _onEditGift(GiftModel gift) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGiftScreen(
          eventId: widget.eventId,
          gift: gift,
        ),
      ),
    ).then((_) => _loadGifts());
  }

  Future<void> _reserveGift(GiftModel gift) async {
    final TextEditingController nameController = TextEditingController();
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Réserver ce cadeau'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Entrez votre nom pour réserver ce cadeau:'),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Votre nom',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Réserver'),
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  
                  try {
                    final giftProvider = Provider.of<GiftProvider>(context, listen: false);
                    await giftProvider.reserveGift(gift.id, nameController.text);
                    
                    _loadGifts();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cadeau réservé avec succès')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: ${e.toString()}')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelReservation(GiftModel gift) async {
    try {
      final giftProvider = Provider.of<GiftProvider>(context, listen: false);
      await giftProvider.cancelReservation(gift.id);
      
      _loadGifts();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation annulée avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteGift(GiftModel gift) async {
    try {
      final giftProvider = Provider.of<GiftProvider>(context, listen: false);
      await giftProvider.deleteGift(gift.id);
      
      _loadGifts();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadeau supprimé avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  void _showGiftOptions(GiftModel gift) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                _onEditGift(gift);
              },
            ),
            if (!gift.isReserved)
              ListTile(
                leading: const Icon(Icons.bookmark_add, color: Colors.green),
                title: const Text('Réserver'),
                onTap: () {
                  Navigator.pop(context);
                  _reserveGift(gift);
                },
              ),
            if (gift.isReserved)
              ListTile(
                leading: const Icon(Icons.bookmark_remove, color: Colors.orange),
                title: const Text('Annuler la réservation'),
                onTap: () {
                  Navigator.pop(context);
                  _cancelReservation(gift);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(gift);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(GiftModel gift) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer ce cadeau ?'),
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
                _deleteGift(gift);
              },
            ),
          ],
        );
      },
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
                  'Liste de cadeaux',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_gifts.length} cadeau${_gifts.length > 1 ? 'x' : ''}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _gifts.isEmpty
                ? _buildEmptyState()
                : _buildGiftList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddGift,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun cadeau pour cet événement',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _onAddGift,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un cadeau'),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftList() {
    return RefreshIndicator(
      onRefresh: _loadGifts,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _gifts.length,
        itemBuilder: (context, index) {
          final gift = _gifts[index];
          return _buildGiftItem(gift);
        },
      ),
    );
  }

  Widget _buildGiftItem(GiftModel gift) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: gift.isReserved 
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.card_giftcard),
        title: Text(
          gift.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (gift.description.isNotEmpty)
              Text(
                gift.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (gift.price > 0)
              Text(
                'Prix: ${gift.price.toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (gift.isReserved && gift.reservedBy.isNotEmpty)
              Text(
                'Réservé par: ${gift.reservedBy}',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.green,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showGiftOptions(gift),
        ),
        onTap: () => _showGiftOptions(gift),
      ),
    );
  }
}