// lib/providers/gift_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/gift_model.dart';
import '../utils/constants.dart';

class GiftProvider with ChangeNotifier {
  List<Gift> _gifts = [];
  GiftList? _giftList;
  bool _isLoading = false;
  String? _error;
  
  List<Gift> get gifts => [..._gifts];
  GiftList? get giftList => _giftList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchGiftList(int eventId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/gifts/lists/?event=$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is List && data.isNotEmpty) {
          _giftList = GiftList.fromJson(data[0]);
          await fetchGifts(_giftList!.id, token);
        } else if (data['results'] != null && data['results'] is List && data['results'].isNotEmpty) {
          _giftList = GiftList.fromJson(data['results'][0]);
          await fetchGifts(_giftList!.id, token);
        } else {
          _giftList = null;
          _gifts = [];
        }
      } else {
        _error = 'Erreur lors de la récupération de la liste de cadeaux';
        _giftList = null;
        _gifts = [];
      }
    } catch (e) {
      _error = 'Erreur de connexion: $e';
      _giftList = null;
      _gifts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchGifts(int listId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/gifts/gifts/?list=$listId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is List) {
          _gifts = data.map((json) => Gift.fromJson(json)).toList();
        } else if (data['results'] != null && data['results'] is List) {
          _gifts = data['results'].map<Gift>((json) => Gift.fromJson(json)).toList();
        } else {
          _gifts = [];
        }
      } else {
        _error = 'Erreur lors de la récupération des cadeaux';
        _gifts = [];
      }
    } catch (e) {
      _error = 'Erreur de connexion: $e';
      _gifts = [];
    }
  }
  
  Future<GiftList?> createGiftList(GiftList giftList, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/gifts/lists/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode(giftList.toJson()),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _giftList = GiftList.fromJson(data);
        
        notifyListeners();
        return _giftList;
      } else {
        final data = json.decode(response.body);
        _error = data['detail'] ?? 'Erreur lors de la création de la liste de cadeaux';
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
  
  Future<Gift?> addGift(Gift gift, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/gifts/gifts/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode(gift.toJson()),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final newGift = Gift.fromJson(data);
        
        _gifts.add(newGift);
        
        notifyListeners();
        return newGift;
      } else {
        final data = json.decode(response.body);
        _error = data['detail'] ?? 'Erreur lors de l\'ajout du cadeau';
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
  
  Future<Gift?> updateGift(Gift gift, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.put(
        Uri.parse('${Constants.apiUrl}/gifts/gifts/${gift.id}/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode(gift.toJson()),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedGift = Gift.fromJson(data);
        
        final giftIndex = _gifts.indexWhere((g) => g.id == gift.id);
        if (giftIndex >= 0) {
          _gifts[giftIndex] = updatedGift;
        }
        
        notifyListeners();
        return updatedGift;
      } else {
        final data = json.decode(response.body);
        _error = data['detail'] ?? 'Erreur lors de la mise à jour du cadeau';
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
  
  Future<bool> reserveGift(int giftId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/gifts/gifts/$giftId/reserve/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedGift = Gift.fromJson(data);
        
        final giftIndex = _gifts.indexWhere((g) => g.id == giftId);
        if (giftIndex >= 0) {
          _gifts[giftIndex] = updatedGift;
        }
        
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['detail'] ?? 'Erreur lors de la réservation du cadeau';
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
  
  Future<bool> cancelReservation(int giftId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/gifts/gifts/$giftId/cancel_reservation/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedGift = Gift.fromJson(data);
        
        final giftIndex = _gifts.indexWhere((g) => g.id == giftId);
        if (giftIndex >= 0) {
          _gifts[giftIndex] = updatedGift;
        }
        
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['detail'] ?? 'Erreur lors de l\'annulation de la réservation';
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
  
  Future<bool> deleteGift(int giftId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.delete(
        Uri.parse('${Constants.apiUrl}/gifts/gifts/$giftId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      
      if (response.statusCode == 204) {
        _gifts.removeWhere((gift) => gift.id == giftId);
        notifyListeners();
        return true;
      } else {
        _error = 'Erreur lors de la suppression du cadeau';
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