import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/guest_model.dart';
import '../../providers/guest_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';

class AddGuestScreen extends StatefulWidget {
  final String eventId;
  final GuestModel? guest; // Null pour un nouvel invité, non-null pour modification

  const AddGuestScreen({
    super.key,
    required this.eventId,
    this.guest,
  });

  @override
  State<AddGuestScreen> createState() => _AddGuestScreenState();
}

class _AddGuestScreenState extends State<AddGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;
  late int _numberOfGuests;
  late GuestStatus _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.guest?.name ?? '');
    _emailController = TextEditingController(text: widget.guest?.email ?? '');
    _phoneController = TextEditingController(text: widget.guest?.phone ?? '');
    _notesController = TextEditingController(text: widget.guest?.notes ?? '');
    _numberOfGuests = widget.guest?.numberOfGuests ?? 1;
    _status = widget.guest?.status ?? GuestStatus.pending;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveGuest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final guestProvider = Provider.of<GuestProvider>(context, listen: false);
      
      final guestToSave = GuestModel(
        id: widget.guest?.id ?? '',
        eventId: widget.eventId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        notes: _notesController.text.trim(),
        numberOfGuests: _numberOfGuests,
        status: _status,
        createdAt: widget.guest?.createdAt ?? DateTime.now(),
      );
      
      if (widget.guest == null) {
        await guestProvider.createGuest(guestToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invité ajouté avec succès')),
          );
        }
      } else {
        await guestProvider.updateGuest(guestToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invité mis à jour avec succès')),
          );
        }
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.guest != null;
    final title = isEditing ? 'Modifier l\'invité' : 'Ajouter un invité';

    return Scaffold(
      appBar: CustomAppBar(
        title: title,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Nom',
                icon: Icons.person,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Téléphone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.people, color: Colors.grey),
                  const SizedBox(width: 16),
                  const Text('Nombre d\'invités:'),
                  const SizedBox(width: 16),
                  DropdownButton<int>(
                    value: _numberOfGuests,
                    items: List.generate(10, (index) {
                      return DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text('${index + 1}'),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _numberOfGuests = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.event_available, color: Colors.grey),
                  const SizedBox(width: 16),
                  const Text('Statut:'),
                  const SizedBox(width: 16),
                  DropdownButton<GuestStatus>(
                    value: _status,
                    items: [
                      DropdownMenuItem(
                        value: GuestStatus.pending,
                        child: const Text('En attente'),
                      ),
                      DropdownMenuItem(
                        value: GuestStatus.confirmed,
                        child: const Text('Confirmé'),
                      ),
                      DropdownMenuItem(
                        value: GuestStatus.declined,
                        child: const Text('Décliné'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _status = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _notesController,
                label: 'Notes',
                icon: Icons.note,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveGuest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(isEditing ? 'Mettre à jour' : 'Ajouter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}