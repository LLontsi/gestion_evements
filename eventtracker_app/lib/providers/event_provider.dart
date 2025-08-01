import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventProvider with ChangeNotifier {
  final EventService _eventService = EventService();
  List<EventModel> _events = [];
  List<EventModel> _upcomingEvents = [];
  List<EventModel> _pastEvents = [];
  bool _isLoading = false;
  String? _error;

  List<EventModel> get events => _events;
  List<EventModel> get upcomingEvents => _upcomingEvents;
  List<EventModel> get pastEvents => _pastEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEvents() async {
    // Définir l'état de chargement sans notifier immédiatement
    _isLoading = true;
    _error = null;
    // Notifier une seule fois pour indiquer le début du chargement
    notifyListeners();

    try {
      _events = await _eventService.getEvents();
    } catch (e) {
      _error = e.toString();
    } finally {
      // Modifier l'état et notifier une seule fois à la fin
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUpcomingEvents() async {
    // Ne pas notifier pendant le build
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _upcomingEvents = await _eventService.getUpcomingEvents();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPastEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pastEvents = await _eventService.getPastEvents();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<EventModel> getEventById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final event = await _eventService.getEventById(id);
      _isLoading = false;
      notifyListeners();
      return event;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<EventModel> createEvent(EventModel event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final createdEvent = await _eventService.createEvent(event);
      _events.add(createdEvent);
      _updateEventLists(createdEvent);
      _isLoading = false;
      notifyListeners();
      return createdEvent;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<EventModel> updateEvent(EventModel event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedEvent = await _eventService.updateEvent(event);
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = updatedEvent;
      }
      _updateEventLists(updatedEvent);
      _isLoading = false;
      notifyListeners();
      return updatedEvent;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _eventService.deleteEvent(id);
      
      _events.removeWhere((e) => e.id == id);
      _upcomingEvents.removeWhere((e) => e.id == id);
      _pastEvents.removeWhere((e) => e.id == id);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void _updateEventLists(EventModel event) {
    // Mettre à jour les listes d'événements à venir et passés
    if (event.isPastEvent) {
      final pastIndex = _pastEvents.indexWhere((e) => e.id == event.id);
      if (pastIndex != -1) {
        _pastEvents[pastIndex] = event;
      } else {
        _pastEvents.add(event);
        _upcomingEvents.removeWhere((e) => e.id == event.id);
      }
    } else {
      final upcomingIndex = _upcomingEvents.indexWhere((e) => e.id == event.id);
      if (upcomingIndex != -1) {
        _upcomingEvents[upcomingIndex] = event;
      } else {
        _upcomingEvents.add(event);
        _pastEvents.removeWhere((e) => e.id == event.id);
      }
    }
  }
}
