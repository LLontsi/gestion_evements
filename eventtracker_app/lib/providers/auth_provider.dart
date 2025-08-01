import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    _setLoading(true);
    try {
      _user = await _authService.getCurrentUser();
      if (_user != null) {
        print("Utilisateur déjà connecté: ${_user!.name}");
      } else {
        print("Aucun utilisateur connecté");
      }
    } catch (e) {
      print("Erreur lors de la vérification d'authentification: $e");
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _clearError();
    _setLoading(true);

    try {
      _user = await _authService.login(email, password);
      print("Connexion réussie: ${_user!.name}");
      notifyListeners();
      return true;
    } catch (e) {
      print("Erreur lors de la connexion: $e");
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _clearError();
    _setLoading(true);

    try {
      _user = await _authService.register(name, email, password);
      print("Inscription réussie: ${_user!.name}");
      notifyListeners();
      return true;
    } catch (e) {
      print("Erreur lors de l'inscription: $e");
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _clearError();
    _setLoading(true);

    try {
      await _authService.logout();
      _user = null;
      print("Déconnexion réussie");
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la déconnexion: $e");
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(User updatedUser) async {
    _clearError();
    _setLoading(true);

    try {
      _user = await _authService.updateProfile(updatedUser);
      print("Profil mis à jour avec succès");
      notifyListeners();
      return true;
    } catch (e) {
      print("Erreur lors de la mise à jour du profil: $e");
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _clearError();
    _setLoading(true);

    try {
      await _authService.changePassword(currentPassword, newPassword);
      print("Mot de passe changé avec succès");
      return true;
    } catch (e) {
      print("Erreur lors du changement de mot de passe: $e");
      _setError(e.toString());
      return false;
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
    notifyListeners();
  }
}