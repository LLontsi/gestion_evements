import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/guest_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class GuestService {
  final ApiService _apiService = ApiService();

  Future<List<GuestModel>> getGuestsByEvent(String eventId) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Récupération des invités simulés');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 700));
      
      final prefs = await SharedPreferences.getInstance();
      final guestsJson = prefs.getString('dev_guests');
      
      if (guestsJson != null) {
        final List<dynamic> guestsData = json.decode(guestsJson);
        return guestsData
          .where((g) => g['eventId'] == eventId)
          .map((g) => GuestModel.fromJson(g))
          .toList();
      }
      
      return [];
    }
    
    // Mode normal avec API
    final response = await _apiService.get('events/$eventId/guests');
    
    if (response != null && response is List) {
      return response.map((item) => GuestModel.fromJson(item)).toList();
    }
    
    return [];
  }

  Future<GuestModel> getGuestById(String id) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Récupération d\'un invité simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 400));
      
      final prefs = await SharedPreferences.getInstance();
      final guestsJson = prefs.getString('dev_guests');
      
      if (guestsJson != null) {
        final List<dynamic> guestsData = json.decode(guestsJson);
        final guestData = guestsData.firstWhere(
          (g) => g['id'] == id, 
          orElse: () => throw Exception('Invité non trouvé')
        );
        return GuestModel.fromJson(guestData);
      }
      
      throw Exception('Invité non trouvé');
    }
    
    // Mode normal avec API
    final response = await _apiService.get('guests/$id');
    
    if (response != null) {
      return GuestModel.fromJson(response);
    }
    
    throw Exception('Invité non trouvé');
  }

  Future<GuestModel> createGuest(GuestModel guest) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Création d\'un invité simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 800));
      
      final prefs = await SharedPreferences.getInstance();
      final guestsJson = prefs.getString('dev_guests');
      
      // Créer un nouvel ID
      final newId = 'guest-${DateTime.now().millisecondsSinceEpoch}';
      final newGuest = guest.copyWith(
        id: newId,
        createdAt: DateTime.now(),
      );
      
      // Ajouter aux invités existants
      if (guestsJson != null) {
        final List<dynamic> guestsData = json.decode(guestsJson);
        guestsData.add(newGuest.toJson());
        await prefs.setString('dev_guests', json.encode(guestsData));
      } else {
        await prefs.setString('dev_guests', json.encode([newGuest.toJson()]));
      }
      
      return newGuest;
    }
    
    // Mode normal avec API
    final response = await _apiService.post('guests', guest.toJson());
    
    if (response != null) {
      return GuestModel.fromJson(response);
    }
    
    throw Exception('Échec de l\'ajout de l\'invité');
  }

  Future<GuestModel> updateGuest(GuestModel guest) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Mise à jour d\'un invité simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 700));
      
      final prefs = await SharedPreferences.getInstance();
      final guestsJson = prefs.getString('dev_guests');
      
      if (guestsJson != null) {
        final List<dynamic> guestsData = json.decode(guestsJson);
        final index = guestsData.indexWhere((g) => g['id'] == guest.id);
        
        if (index != -1) {
          guestsData[index] = guest.toJson();
          await prefs.setString('dev_guests', json.encode(guestsData));
          return guest;
        }
        
        throw Exception('Invité non trouvé');
      }
      
      throw Exception('Aucun invité enregistré');
    }
    
    // Mode normal avec API
    final response = await _apiService.put('guests/${guest.id}', guest.toJson());
    
    if (response != null) {
      return GuestModel.fromJson(response);
    }
    
    throw Exception('Échec de la mise à jour de l\'invité');
  }

  Future<void> deleteGuest(String id) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Suppression d\'un invité simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 500));
      
      final prefs = await SharedPreferences.getInstance();
      final guestsJson = prefs.getString('dev_guests');
      
      if (guestsJson != null) {
        final List<dynamic> guestsData = json.decode(guestsJson);
        final newGuestsData = guestsData.where((g) => g['id'] != id).toList();
        await prefs.setString('dev_guests', json.encode(newGuestsData));
      }
      
      return;
    }
    
    // Mode normal avec API
    await _apiService.delete('guests/$id');
  }

  Future<GuestModel> updateGuestStatus(String id, GuestStatus status) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Mise à jour du statut d\'un invité simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 600));
      
      final prefs = await SharedPreferences.getInstance();
      final guestsJson = prefs.getString('dev_guests');
      
      if (guestsJson != null) {
        final List<dynamic> guestsData = json.decode(guestsJson);
        final index = guestsData.indexWhere((g) => g['id'] == id);
        
        if (index != -1) {
          final guest = GuestModel.fromJson(guestsData[index]);
          final updatedGuest = guest.copyWith(status: status);
          
          guestsData[index] = updatedGuest.toJson();
          await prefs.setString('dev_guests', json.encode(guestsData));
          
          return updatedGuest;
        }
        
        throw Exception('Invité non trouvé');
      }
      
      throw Exception('Aucun invité enregistré');
    }
    
    // Mode normal avec API
    String statusStr;
    switch (status) {
      case GuestStatus.confirmed:
        statusStr = 'confirmed';
        break;
      case GuestStatus.declined:
        statusStr = 'declined';
        break;
      default:
        statusStr = 'pending';
    }

    final response = await _apiService.put('guests/$id/status', {
      'status': statusStr,
    });
    
    if (response != null) {
      return GuestModel.fromJson(response);
    }
    
    throw Exception('Échec de la mise à jour du statut');
  }

  Future<void> sendInvitation(String id) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Envoi d\'invitation simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(seconds: 1));
      
      return;
    }
    
    // Mode normal avec API
    await _apiService.post('guests/$id/send-invitation', {});
  }

  Future<void> sendReminder(String id) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Envoi de rappel simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(seconds: 1));
      
      return;
    }
    
    // Mode normal avec API
    await _apiService.post('guests/$id/send-reminder', {});
  }
}
