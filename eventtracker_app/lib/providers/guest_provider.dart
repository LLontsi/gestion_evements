import 'package:flutter/material.dart';
import '../models/guest_model.dart';
import '../services/guest_service.dart';

class GuestProvider with ChangeNotifier {
  final GuestService _guestService = GuestService();
  Map<String, List<GuestModel>> _guestsByEvent = {};
  bool _isLoading = false;
  String? _error;

  List<GuestModel> getGuestsForEvent(String eventId) => _guestsByEvent[eventId] ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<List<GuestModel>> getGuestsByEvent(String eventId) async {
    _setLoading(true);
    _clearError();

    try {
      final guests = await _guestService.getGuestsByEvent(eventId);
      _guestsByEvent[eventId] = guests;
      notifyListeners();
      return guests;
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<GuestModel> getGuestById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      return await _guestService.getGuestById(id);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<GuestModel> createGuest(GuestModel guest) async {
    _setLoading(true);
    _clearError();

    try {
      final createdGuest = await _guestService.createGuest(guest);
      
      if (_guestsByEvent.containsKey(guest.eventId)) {
        _guestsByEvent[guest.eventId]!.add(createdGuest);
      } else {
        _guestsByEvent[guest.eventId] = [createdGuest];
      }
      
      notifyListeners();
      return createdGuest;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<GuestModel> updateGuest(GuestModel guest) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedGuest = await _guestService.updateGuest(guest);
      
      if (_guestsByEvent.containsKey(guest.eventId)) {
        final index = _guestsByEvent[guest.eventId]!.indexWhere((g) => g.id == guest.id);
        if (index != -1) {
          _guestsByEvent[guest.eventId]![index] = updatedGuest;
        }
      }
      
      notifyListeners();
      return updatedGuest;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteGuest(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _guestService.deleteGuest(id);
      
      // Supprimer l'invité de toutes les listes
      for (final eventId in _guestsByEvent.keys) {
        _guestsByEvent[eventId]!.removeWhere((g) => g.id == id);
      }
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<GuestModel> updateGuestStatus(String id, GuestStatus status) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedGuest = await _guestService.updateGuestStatus(id, status);
      
      // Mettre à jour l'invité dans toutes les listes
      for (final eventId in _guestsByEvent.keys) {
        final index = _guestsByEvent[eventId]!.indexWhere((g) => g.id == id);
        if (index != -1) {
          _guestsByEvent[eventId]![index] = updatedGuest;
        }
      }
      
      notifyListeners();
      return updatedGuest;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendInvitation(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _guestService.sendInvitation(id);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendReminder(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _guestService.sendReminder(id);
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