import 'package:flutter/material.dart';
import '../models/gift_model.dart';
import '../services/gift_service.dart';

class GiftProvider with ChangeNotifier {
  final GiftService _giftService = GiftService();
  Map<String, List<GiftModel>> _giftsByEvent = {};
  bool _isLoading = false;
  String? _error;

  List<GiftModel> getGiftsForEvent(String eventId) => _giftsByEvent[eventId] ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<List<GiftModel>> getGiftsByEvent(String eventId) async {
    _setLoading(true);
    _clearError();

    try {
      final gifts = await _giftService.getGiftsByEvent(eventId);
      _giftsByEvent[eventId] = gifts;
      notifyListeners();
      return gifts;
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<GiftModel> getGiftById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      return await _giftService.getGiftById(id);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<GiftModel> createGift(GiftModel gift) async {
    _setLoading(true);
    _clearError();

    try {
      final createdGift = await _giftService.createGift(gift);
      
      if (_giftsByEvent.containsKey(gift.eventId)) {
        _giftsByEvent[gift.eventId]!.add(createdGift);
      } else {
        _giftsByEvent[gift.eventId] = [createdGift];
      }
      
      notifyListeners();
      return createdGift;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<GiftModel> updateGift(GiftModel gift) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedGift = await _giftService.updateGift(gift);
      
      if (_giftsByEvent.containsKey(gift.eventId)) {
        final index = _giftsByEvent[gift.eventId]!.indexWhere((g) => g.id == gift.id);
        if (index != -1) {
          _giftsByEvent[gift.eventId]![index] = updatedGift;
        }
      }
      
      notifyListeners();
      return updatedGift;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteGift(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _giftService.deleteGift(id);
      
      // Supprimer le cadeau de toutes les listes
      for (final eventId in _giftsByEvent.keys) {
        _giftsByEvent[eventId]!.removeWhere((g) => g.id == id);
      }
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<GiftModel> reserveGift(String id, String reservedBy) async {
    _setLoading(true);
    _clearError();

    try {
      final reservedGift = await _giftService.reserveGift(id, reservedBy);
      
      // Mettre à jour le cadeau dans toutes les listes
      for (final eventId in _giftsByEvent.keys) {
        final index = _giftsByEvent[eventId]!.indexWhere((g) => g.id == id);
        if (index != -1) {
          _giftsByEvent[eventId]![index] = reservedGift;
        }
      }
      
      notifyListeners();
      return reservedGift;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<GiftModel> cancelReservation(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final canceledGift = await _giftService.cancelReservation(id);
      
      // Mettre à jour le cadeau dans toutes les listes
      for (final eventId in _giftsByEvent.keys) {
        final index = _giftsByEvent[eventId]!.indexWhere((g) => g.id == id);
        if (index != -1) {
          _giftsByEvent[eventId]![index] = canceledGift;
        }
      }
      
      notifyListeners();
      return canceledGift;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}