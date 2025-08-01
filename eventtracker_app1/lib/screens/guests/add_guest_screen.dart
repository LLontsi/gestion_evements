import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/guest_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guest_provider.dart';
import '../../widgets/custom_text_field.dart';

class AddGuestScreen extends StatefulWidget {
  final int eventId;
  final Guest? guestToEdit;

  const AddGuestScreen({
    Key? key, 
    required this.eventId, 
    this.guestToEdit,
  }) : super(key: key);

  @override
  _AddGuestScreenState createState() => _AddGuestScreenState();
}

class _AddGuestScreenState extends State<AddGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _responseStatus = 'pending';
  int _plusOnes = 0;
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.guestToEdit != null) {
      _nameController.text = widget.guestToEdit!.name;
      _emailController.text = widget.guestToEdit!.email;
      _phoneController.text = widget.guestToEdit!.phone;
      _noteController.text = widget.guestToEdit!.note;
      _responseStatus = widget.guestToEdit!.responseStatus;
      _plusOnes = widget.guestToEdit!.plusOnes;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  
  Future<void> _saveGuest() async {
    if (_formKey.currentState?.validate() != true) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final guestProvider = Provider.of<GuestProvider>(context, listen: false);

    if (!authProvider.isLoggedIn || authProvider.token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Vous devez être connecté pour ajouter un invité';
      });
      return;
    }
    
    try {
      final guest = Guest(
        id: widget.guestToEdit?.id ?? 0,
        eventId: widget.eventId,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        responseStatus: _responseStatus,
        plusOnes: _plusOnes,
        note: _noteController.text,
      );

      Guest? result;
      if (widget.guestToEdit != null) {
        result = await guestProvider.updateGuest(guest, authProvider.token!);
      } else {
        result = await guestProvider.addGuest(guest, authProvider.token!);
      }

      if (result != null && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = guestProvider.error ?? 'Une erreur est survenue';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur: $e';
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.guestToEdit != null ? 'Modifier l\'invité' : 'Ajouter un invité'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),
                SizedBox(height: 16),
              ],
              
              CustomTextField(
                controller: _nameController,
                labelText: 'Nom',
                hintText: 'Nom de l\'invité',
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Email de l\'invité (facultatif)',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Veuillez entrer un email valide';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              CustomTextField(
                controller: _phoneController,
                labelText: 'Téléphone',
                hintText: 'Numéro de téléphone (facultatif)',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              
              Text('Statut', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _responseStatus,
                items: [
                  DropdownMenuItem(value: 'pending', child: Text('En attente')),
                  DropdownMenuItem(value: 'accepted', child: Text('Accepté')),
                  DropdownMenuItem(value: 'declined', child: Text('Refusé')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _responseStatus = value;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              
              Text('Accompagnants', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: _plusOnes > 0
                        ? () => setState(() => _plusOnes--)
                        : null,
                  ),
                  Text('$_plusOnes', style: TextStyle(fontSize: 16)),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => setState(() => _plusOnes++),
                  ),
                  Expanded(
                    child: Text(
                      'personne(s) accompagnant l\'invité',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              
              CustomTextField(
                controller: _noteController,
                labelText: 'Note',
                hintText: 'Note supplémentaire (facultatif)',
                prefixIcon: Icons.note,
                maxLines: 3,
              ),
              SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveGuest,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(widget.guestToEdit != null ? 'Mettre à jour' : 'Ajouter'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
