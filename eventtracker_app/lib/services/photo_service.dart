import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/photo_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class PhotoService {
  final ApiService _apiService = ApiService();

  Future<List<PhotoModel>> getPhotosByEvent(String eventId) async {
    final response = await _apiService.get('events/$eventId/photos');
    
    if (response != null && response is List) {
      return response.map((item) => PhotoModel.fromJson(item)).toList();
    }
    
    return [];
  }

  Future<PhotoModel> getPhotoById(String id) async {
    final response = await _apiService.get('photos/$id');
    
    if (response != null) {
      return PhotoModel.fromJson(response);
    }
    
    throw Exception('Photo non trouvée');
  }

  Future<PhotoModel> uploadPhoto(String eventId, File photoFile, {String? caption}) async {
  final token = await _getToken();
  
  if (token == null) {
    throw Exception('Utilisateur non authentifié');
  }
  
  final uri = Uri.parse('${Constants.apiUrl}/photos');
  final request = http.MultipartRequest('POST', uri);
  
  request.headers['Authorization'] = 'Bearer $token';
  request.fields['event_id'] = eventId;
  
  if (caption != null) {
    request.fields['caption'] = caption;
  }
  
  request.files.add(
    await http.MultipartFile.fromPath('photo', photoFile.path),
  );
  
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);
  
  if (response.statusCode >= 200 && response.statusCode < 300) {
    // Vérifier si le corps est vide et lancer une exception si c'est le cas
    if (response.body.isEmpty) {
      throw Exception('Réponse vide du serveur');
    }
    final jsonResponse = json.decode(response.body);
    return PhotoModel.fromJson(jsonResponse);
  } else {
    // Gestion de l'erreur
    try {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Échec du téléchargement de la photo');
    } catch (e) {
      throw Exception('Échec du téléchargement de la photo: ${response.statusCode}');
    }
  }
}
  Future<PhotoModel> updatePhotoCaption(String id, String caption) async {
    final response = await _apiService.put('photos/$id', {
      'caption': caption,
    });
    
    if (response != null) {
      return PhotoModel.fromJson(response);
    }
    
    throw Exception('Échec de la mise à jour de la légende');
  }

  Future<void> deletePhoto(String id) async {
    await _apiService.delete('photos/$id');
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.tokenPreference);
  }
}