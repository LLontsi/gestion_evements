import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gift_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class GiftService {
  final ApiService _apiService = ApiService();

  Future<List<GiftModel>> getGiftsByEvent(String eventId) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Récupération des cadeaux simulés');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 600));
      
      final prefs = await SharedPreferences.getInstance();
      final giftsJson = prefs.getString('dev_gifts');
      
      if (giftsJson != null) {
        final List<dynamic> giftsData = json.decode(giftsJson);
        return giftsData
          .where((g) => g['eventId'] == eventId)
          .map((g) => GiftModel.fromJson(g))
          .toList();
      }
      
      return [];
    }
    
    // Mode normal avec API
    final response = await _apiService.get('events/$eventId/gifts');
    
    if (response != null && response is List) {
      return response.map((item) => GiftModel.fromJson(item)).toList();
    }
    
    return [];
  }

  Future<GiftModel> getGiftById(String id) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Récupération d\'un cadeau simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 400));
      
      final prefs = await SharedPreferences.getInstance();
      final giftsJson = prefs.getString('dev_gifts');
      
      if (giftsJson != null) {
        final List<dynamic> giftsData = json.decode(giftsJson);
        final giftData = giftsData.firstWhere(
          (g) => g['id'] == id, 
          orElse: () => throw Exception('Cadeau non trouvé')
        );
        return GiftModel.fromJson(giftData);
      }
      
      throw Exception('Cadeau non trouvé');
    }
    
    // Mode normal avec API
    final response = await _apiService.get('gifts/$id');
    
    if (response != null) {
      return GiftModel.fromJson(response);
    }
    
    throw Exception('Cadeau non trouvé');
  }

  Future<GiftModel> createGift(GiftModel gift) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Création d\'un cadeau simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 800));
      
      final prefs = await SharedPreferences.getInstance();
      final giftsJson = prefs.getString('dev_gifts');
      
      // Créer un nouvel ID
      final newId = 'gift-${DateTime.now().millisecondsSinceEpoch}';
      final newGift = gift.copyWith(
        id: newId,
        createdAt: DateTime.now(),
      );
      
      // Ajouter aux cadeaux existants
      if (giftsJson != null) {
        final List<dynamic> giftsData = json.decode(giftsJson);
        giftsData.add(newGift.toJson());
        await prefs.setString('dev_gifts', json.encode(giftsData));
      } else {
        await prefs.setString('dev_gifts', json.encode([newGift.toJson()]));
      }
      
      return newGift;
    }
    
    // Mode normal avec API
    final response = await _apiService.post('gifts', gift.toJson());
    
    if (response != null) {
      return GiftModel.fromJson(response);
    }
    
    throw Exception('Échec de la création du cadeau');
  }

  Future<GiftModel> updateGift(GiftModel gift) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Mise à jour d\'un cadeau simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 700));
      
      final prefs = await SharedPreferences.getInstance();
      final giftsJson = prefs.getString('dev_gifts');
      
      if (giftsJson != null) {
        final List<dynamic> giftsData = json.decode(giftsJson);
        final index = giftsData.indexWhere((g) => g['id'] == gift.id);
        
        if (index != -1) {
          giftsData[index] = gift.toJson();
          await prefs.setString('dev_gifts', json.encode(giftsData));
          return gift;
        }
        
        throw Exception('Cadeau non trouvé');
      }
      
      throw Exception('Aucun cadeau enregistré');
    }
    
    // Mode normal avec API
    final response = await _apiService.put('gifts/${gift.id}', gift.toJson());
    
    if (response != null) {
      return GiftModel.fromJson(response);
    }
    
    throw Exception('Échec de la mise à jour du cadeau');
  }

  Future<void> deleteGift(String id) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Suppression d\'un cadeau simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 500));
      
      final prefs = await SharedPreferences.getInstance();
      final giftsJson = prefs.getString('dev_gifts');
      
      if (giftsJson != null) {
        final List<dynamic> giftsData = json.decode(giftsJson);
        final newGiftsData = giftsData.where((g) => g['id'] != id).toList();
        await prefs.setString('dev_gifts', json.encode(newGiftsData));
      }
      
      return;
    }
    
    // Mode normal avec API
    await _apiService.delete('gifts/$id');
  }

  Future<GiftModel> reserveGift(String id, String reservedBy) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Réservation d\'un cadeau simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 600));
      
      final prefs = await SharedPreferences.getInstance();
      final giftsJson = prefs.getString('dev_gifts');
      
      if (giftsJson != null) {
        final List<dynamic> giftsData = json.decode(giftsJson);
        final index = giftsData.indexWhere((g) => g['id'] == id);
        
        if (index != -1) {
          final gift = GiftModel.fromJson(giftsData[index]);
          final updatedGift = gift.copyWith(
            isReserved: true,
            reservedBy: reservedBy,
          );
          
          giftsData[index] = updatedGift.toJson();
          await prefs.setString('dev_gifts', json.encode(giftsData));
          
          return updatedGift;
        }
        
        throw Exception('Cadeau non trouvé');
      }
      
      throw Exception('Aucun cadeau enregistré');
    }
    
    // Mode normal avec API
    final response = await _apiService.put('gifts/$id/reserve', {
      'reserved_by': reservedBy,
    });
    
    if (response != null) {
      return GiftModel.fromJson(response);
    }
    
    throw Exception('Échec de la réservation du cadeau');
  }

  Future<GiftModel> cancelReservation(String id) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Annulation de réservation d\'un cadeau simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 600));
      
      final prefs = await SharedPreferences.getInstance();
      final giftsJson = prefs.getString('dev_gifts');
      
      if (giftsJson != null) {
        final List<dynamic> giftsData = json.decode(giftsJson);
        final index = giftsData.indexWhere((g) => g['id'] == id);
        
        if (index != -1) {
          final gift = GiftModel.fromJson(giftsData[index]);
          final updatedGift = gift.copyWith(
            isReserved: false,
            reservedBy: '',
          );
          
          giftsData[index] = updatedGift.toJson();
          await prefs.setString('dev_gifts', json.encode(giftsData));
          
          return updatedGift;
        }
        
        throw Exception('Cadeau non trouvé');
      }
      
      throw Exception('Aucun cadeau enregistré');
    }
    
    // Mode normal avec API
    final response = await _apiService.put('gifts/$id/cancel-reservation', {});
    
    if (response != null) {
      return GiftModel.fromJson(response);
    }
    
    throw Exception('Échec de l\'annulation de la réservation');
  }
}
