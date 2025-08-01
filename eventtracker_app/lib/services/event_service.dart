import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class EventService {
  final ApiService _apiService = ApiService();

  Future<List<EventModel>> getEvents() async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Récupération des événements simulés');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 800));
      
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString('dev_events');
      
      if (eventsJson != null) {
        final List<dynamic> eventsData = json.decode(eventsJson);
        return eventsData.map((e) => EventModel.fromJson(e)).toList();
      }
      
      return [];
    }
    
    // Mode normal avec API
    final response = await _apiService.get('events');
    
    if (response != null && response is List) {
      return response.map((item) => EventModel.fromJson(item)).toList();
    }
    
    return [];
  }

  Future<EventModel> getEventById(String id) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Récupération d\'un événement simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 500));
      
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString('dev_events');
      
      if (eventsJson != null) {
        final List<dynamic> eventsData = json.decode(eventsJson);
        final eventData = eventsData.firstWhere(
          (e) => e['id'] == id, 
          orElse: () => throw Exception('Événement non trouvé')
        );
        return EventModel.fromJson(eventData);
      }
      
      throw Exception('Événement non trouvé');
    }
    
    // Mode normal avec API
    final response = await _apiService.get('events/$id');
    
    if (response != null) {
      return EventModel.fromJson(response);
    }
    
    throw Exception('Événement non trouvé');
  }

  Future<EventModel> createEvent(EventModel event) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Création d\'un événement simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 800));
      
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString('dev_events');
      
      // Créer un nouvel ID
      final newId = 'event-${DateTime.now().millisecondsSinceEpoch}';
      final newEvent = event.copyWith(
        id: newId,
        createdAt: DateTime.now(),
      );
      
      // Ajouter aux événements existants
      if (eventsJson != null) {
        final List<dynamic> eventsData = json.decode(eventsJson);
        eventsData.add(newEvent.toJson());
        await prefs.setString('dev_events', json.encode(eventsData));
      } else {
        await prefs.setString('dev_events', json.encode([newEvent.toJson()]));
      }
      
      return newEvent;
    }
    
    // Mode normal avec API
    final response = await _apiService.post('events', event.toJson());
    
    if (response != null) {
      return EventModel.fromJson(response);
    }
    
    throw Exception('Échec de la création de l\'événement');
  }

  Future<EventModel> updateEvent(EventModel event) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Mise à jour d\'un événement simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 700));
      
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString('dev_events');
      
      if (eventsJson != null) {
        final List<dynamic> eventsData = json.decode(eventsJson);
        final index = eventsData.indexWhere((e) => e['id'] == event.id);
        
        if (index != -1) {
          eventsData[index] = event.toJson();
          await prefs.setString('dev_events', json.encode(eventsData));
          return event;
        }
        
        throw Exception('Événement non trouvé');
      }
      
      throw Exception('Aucun événement enregistré');
    }
    
    // Mode normal avec API
    final response = await _apiService.put('events/${event.id}', event.toJson());
    
    if (response != null) {
      return EventModel.fromJson(response);
    }
    
    throw Exception('Échec de la mise à jour de l\'événement');
  }

  Future<void> deleteEvent(String id) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Suppression d\'un événement simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 600));
      
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString('dev_events');
      
      if (eventsJson != null) {
        final List<dynamic> eventsData = json.decode(eventsJson);
        final newEventsData = eventsData.where((e) => e['id'] != id).toList();
        await prefs.setString('dev_events', json.encode(newEventsData));
        
        // Supprimer également les invités, tâches, cadeaux associés
        await _deleteRelatedData(prefs, id);
      }
      
      return;
    }
    
    // Mode normal avec API
    await _apiService.delete('events/$id');
  }

  // Supprimer les données associées (invités, tâches, cadeaux) lors de la suppression d'un événement
  Future<void> _deleteRelatedData(SharedPreferences prefs, String eventId) async {
    // Supprimer les invités
    final guestsJson = prefs.getString('dev_guests');
    if (guestsJson != null) {
      final List<dynamic> guestsData = json.decode(guestsJson);
      final newGuestsData = guestsData.where((g) => g['eventId'] != eventId).toList();
      await prefs.setString('dev_guests', json.encode(newGuestsData));
    }
    
    // Supprimer les tâches
    final tasksJson = prefs.getString('dev_tasks');
    if (tasksJson != null) {
      final List<dynamic> tasksData = json.decode(tasksJson);
      final newTasksData = tasksData.where((t) => t['eventId'] != eventId).toList();
      await prefs.setString('dev_tasks', json.encode(newTasksData));
    }
    
    // Supprimer les cadeaux
    final giftsJson = prefs.getString('dev_gifts');
    if (giftsJson != null) {
      final List<dynamic> giftsData = json.decode(giftsJson);
      final newGiftsData = giftsData.where((g) => g['eventId'] != eventId).toList();
      await prefs.setString('dev_gifts', json.encode(newGiftsData));
    }
  }

  Future<List<EventModel>> getUpcomingEvents() async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Récupération des événements à venir simulés');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 600));
      
      final events = await getEvents();
      final now = DateTime.now();
      
      return events
        .where((e) => e.date.isAfter(now))
        .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    }
    
    // Mode normal avec API
    final response = await _apiService.get('events/upcoming');
    
    if (response != null && response is List) {
      return response.map((item) => EventModel.fromJson(item)).toList();
    }
    
    return [];
  }

  Future<List<EventModel>> getPastEvents() async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Récupération des événements passés simulés');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 600));
      
      final events = await getEvents();
      final now = DateTime.now();
      
      return events
        .where((e) => e.date.isBefore(now))
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Tri par date décroissante
    }
    
    // Mode normal avec API
    final response = await _apiService.get('events/past');
    
    if (response != null && response is List) {
      return response.map((item) => EventModel.fromJson(item)).toList();
    }
    
    return [];
  }
}
