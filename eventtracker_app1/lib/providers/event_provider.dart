import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import '../utils/constants.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  List<EventType> _eventTypes = [];
  bool _isLoading = false;
  String? _error;
  
  List<Event> get events => [..._events];
  List<EventType> get eventTypes => [..._eventTypes];
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchEvents(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/events/events/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is List) {
          _events = data.map((json) => Event.fromJson(json)).toList();
          // Trier les événements par date de début
          _events.sort((a, b) => a.startDate.compareTo(b.startDate));
        } else if (data['results'] != null && data['results'] is List) {
          // Gestion de la pagination
          _events = data['results'].map<Event>((json) => Event.fromJson(json)).toList();
          _events.sort((a, b) => a.startDate.compareTo(b.startDate));
        }
      } else {
        _error = 'Erreur lors de la récupération des événements';
      }
    } catch (e) {
      _error = 'Erreur de connexion: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchEventTypes(String token) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/events/types/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is List) {
          _eventTypes = data.map((json) => EventType.fromJson(json)).toList();
        } else if (data['results'] != null && data['results'] is List) {
          _eventTypes = data['results'].map<EventType>((json) => EventType.fromJson(json)).toList();
        }
      } else {
        _error = 'Erreur lors de la récupération des types d\'événements';
      }
    } catch (e) {
      _error = 'Erreur de connexion: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Event?> createEvent(Event event, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/events/events/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode(event.toJson()),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final newEvent = Event.fromJson(data);
        
        _events.add(newEvent);
        _events.sort((a, b) => a.startDate.compareTo(b.startDate));
        
        notifyListeners();
        return newEvent;
      } else {
        final data = json.decode(response.body);
        _error = data['detail'] ?? 'Erreur lors de la création de l\'événement';
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
  
  Future<bool> updateEvent(Event event, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.put(
        Uri.parse('${Constants.apiUrl}/events/events/${event.id}/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode(event.toJson()),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedEvent = Event.fromJson(data);
        
        final eventIndex = _events.indexWhere((e) => e.id == event.id);
        if (eventIndex >= 0) {
          _events[eventIndex] = updatedEvent;
          _events.sort((a, b) => a.startDate.compareTo(b.startDate));
        }
        
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['detail'] ?? 'Erreur lors de la mise à jour de l\'événement';
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
  
  Future<bool> deleteEvent(int eventId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.delete(
        Uri.parse('${Constants.apiUrl}/events/events/$eventId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      
      if (response.statusCode == 204) {
        _events.removeWhere((event) => event.id == eventId);
        notifyListeners();
        return true;
      } else {
        _error = 'Erreur lors de la suppression de l\'événement';
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
  
  List<Event> getUpcomingEvents() {
    final now = DateTime.now();
    return _events.where((event) => event.startDate.isAfter(now)).toList();
  }
  
  List<Event> getEventsByMonth(int year, int month) {
    return _events.where((event) {
      return event.startDate.year == year && event.startDate.month == month;
    }).toList();
  }
}