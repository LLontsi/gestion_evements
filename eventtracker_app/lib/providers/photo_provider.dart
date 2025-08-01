import 'dart:io';
import 'package:flutter/material.dart';
import '../models/photo_model.dart';
import '../services/photo_service.dart';

class PhotoProvider with ChangeNotifier {
  final PhotoService _photoService = PhotoService();
  Map<String, List<PhotoModel>> _photosByEvent = {};
  bool _isLoading = false;
  String? _error;

  List<PhotoModel> getPhotosForEvent(String eventId) => _photosByEvent[eventId] ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<List<PhotoModel>> getPhotosByEvent(String eventId) async {
    _setLoading(true);
    _clearError();

    try {
      final photos = await _photoService.getPhotosByEvent(eventId);
      _photosByEvent[eventId] = photos;
      notifyListeners();
      return photos;
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<PhotoModel> getPhotoById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      return await _photoService.getPhotoById(id);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<PhotoModel> uploadPhoto(String eventId, File photoFile, {String? caption}) async {
    _setLoading(true);
    _clearError();

    try {
      final uploadedPhoto = await _photoService.uploadPhoto(eventId, photoFile, caption: caption);
      
      if (_photosByEvent.containsKey(eventId)) {
        _photosByEvent[eventId]!.add(uploadedPhoto);
      } else {
        _photosByEvent[eventId] = [uploadedPhoto];
      }
      
      notifyListeners();
      return uploadedPhoto;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<PhotoModel> updatePhotoCaption(String id, String caption) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedPhoto = await _photoService.updatePhotoCaption(id, caption);
      
      // Mettre à jour la photo dans toutes les listes
      for (final eventId in _photosByEvent.keys) {
        final index = _photosByEvent[eventId]!.indexWhere((p) => p.id == id);
        if (index != -1) {
          _photosByEvent[eventId]![index] = updatedPhoto;
        }
      }
      
      notifyListeners();
      return updatedPhoto;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePhoto(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _photoService.deletePhoto(id);
      
      // Supprimer la photo de toutes les listes
      for (final eventId in _photosByEvent.keys) {
        _photosByEvent[eventId]!.removeWhere((p) => p.id == id);
      }
      
      notifyListeners();
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