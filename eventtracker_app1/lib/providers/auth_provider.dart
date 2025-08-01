import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _token;
  User? _user;
  bool _isLoggedIn = false;
  
  bool get isLoading => _isLoading;
  String? get token => _token;
  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  
  AuthProvider() {
    _checkLoginStatus();
  }
  
  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token != null) {
        _token = token;
        _isLoggedIn = true;
        
        // Charger les informations utilisateur
        final userData = prefs.getString('user');
        if (userData != null) {
          _user = User.fromJson(json.decode(userData));
        } else {
          await fetchUserProfile();
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification du statut de connexion: $e');
    }
  }
  
  Future<void> fetchUserProfile() async {
    if (_token == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/users/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $_token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _user = User.fromJson(data);
        
        // Sauvegarder les données utilisateur
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('user', json.encode(data));
      } else {
        await logout();
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération du profil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/token-auth/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        
        // Sauvegarder le token
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', _token!);
        
        // Récupérer le profil utilisateur
        await fetchUserProfile();
        
        _isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['non_field_errors'] ?? 'Erreur d\'authentification');
      }
    } catch (e) {
      debugPrint('Erreur de connexion: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> register(String username, String email, String password, String passwordConfirm) async {
  _isLoading = true;
  notifyListeners();
  
  try {
    final response = await http.post(
      Uri.parse('${Constants.apiUrl}/users/register/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm  // Ajoutez ce champ !
      }),
    );
    
    print("Statut de la réponse: ${response.statusCode}");
    print("Corps de la réponse: ${response.body}");
    
    if (response.statusCode == 201) {
      // Connexion automatique après inscription
      return await login(email, password);
    } else {
      final data = json.decode(response.body);
      throw Exception(data.toString());
    }
  } catch (e) {
    print('Erreur détaillée d\'inscription: $e');
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
  
  Future<void> logout() async {
    _token = null;
    _user = null;
    _isLoggedIn = false;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('token');
      prefs.remove('user');
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
    }
    
    notifyListeners();
  }
}