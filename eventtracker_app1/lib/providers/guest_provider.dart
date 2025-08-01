import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/guest_model.dart';
import '../utils/constants.dart';

class GuestProvider with ChangeNotifier {
  List<Guest> _guests = [];
  bool _isLoading = false;
  String? _error;
  
  List<Guest> get guests => [..._guests];
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchGuests(int eventId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/guests/guests/?event=$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is List) {
          _guests = data.map((json) => Guest.fromJson(json)).toList();
        } else if (data['results'] != null && data['results'] is List) {
          _guests = data['results'].map<Guest>((json) => Guest.fromJson(json)).toList();
        } else {
          _guests = [];
        }
      } else {
        _error = 'Erreur lors de la récupération des invités';
      }
    } catch (e) {
      _error = 'Erreur de connexion: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Guest?> addGuest(Guest guest, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/guests/guests/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode(guest.toJson()),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final newGuest = Guest.fromJson(data);
        
        _guests.add(newGuest);
        
        notifyListeners();
        return newGuest;
      } else {
        final data = json.decode(response.body);
        _error = data['detail'] ?? 'Erreur lors de l\'ajout de l\'invité';
        return null;
      }
    } catch (e) {
      _error = 'Erreur de connexion: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Guest?> updateGuest(Guest guest, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.put(
        Uri.parse('${Constants.apiUrl}/guests/guests/${guest.id}/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode(guest.toJson()),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedGuest = Guest.fromJson(data);
        
        final index = _guests.indexWhere((g) => g.id == guest.id);
        if (index != -1) {
          _guests[index] = updatedGuest;
        }
        
        notifyListeners();
        return updatedGuest;
      } else {
        final data = json.decode(response.body);
        _error = data['detail'] ?? 'Erreur lors de la mise à jour de l\'invité';
        return null;
      }
    } catch (e) {
      _error = 'Erreur de connexion: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteGuest(int guestId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.delete(
        Uri.parse('${Constants.apiUrl}/guests/guests/$guestId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      
      if (response.statusCode == 204) {
        _guests.removeWhere((guest) => guest.id == guestId);
        
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['detail'] ?? 'Erreur lors de la suppression de l\'invité';
        return false;
      }
    } catch (e) {
      _error = 'Erreur de connexion: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
