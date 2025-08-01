import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import '../../models/event_model.dart';
import '../../utils/constants.dart';
import '../../models/event_model.dart'; // Assurez-vous que ce fichier contient la classe Event


class CreateEventScreen extends StatefulWidget {
   final Event? eventToEdit;
  const CreateEventScreen({Key? key, this.eventToEdit}) : super(key: key);

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _createEvent(String token) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/events/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({
          'title': _titleController.text,
          'description': _descriptionController.text,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        final data = json.decode(response.body);
        setState(() {
          _error = data['detail'] ?? 'Erreur lors de la création de l\'événement';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de connexion: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateEvent(int eventId, String token) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.put(
        Uri.parse('${Constants.apiUrl}/events/$eventId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({
          'title': _titleController.text,
          'description': _descriptionController.text,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        final data = json.decode(response.body);
        setState(() {
          _error = data['detail'] ?? 'Erreur lors de la mise à jour de l\'événement';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de connexion: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEvent(int eventId, String token) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.delete(
        Uri.parse('${Constants.apiUrl}/events/$eventId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 204) {
        Navigator.pop(context, true);
      } else {
        final data = json.decode(response.body);
        setState(() {
          _error = data['detail'] ?? 'Erreur lors de la suppression de l\'événement';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de connexion: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un événement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Le titre est requis' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'La description est requise' : null,
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _createEvent('VOTRE_TOKEN_ICI');
                      },
                      child: const Text('Créer'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _updateEvent(1, 'VOTRE_TOKEN_ICI'); // Remplacez par l'ID réel
                      },
                      child: const Text('Mettre à jour'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _deleteEvent(1, 'VOTRE_TOKEN_ICI'); // Remplacez par l'ID réel
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
