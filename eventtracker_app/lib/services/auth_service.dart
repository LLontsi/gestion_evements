import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/event_model.dart';
import '../models/guest_model.dart';
import '../models/gift_model.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';

class AuthService {
  // Base de données simulée pour le mode développement
  static final _devUser = User(
    id: 'dev-user-123',
    name: 'Ronaldino Lontsi',
    email: 'ronaldino.lontsi@facsciences-uy1.cm',
    phone: '+237 675 12 34 56',
    avatar: null,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  // Événements de test
  static final List<EventModel> _devEvents = [
    EventModel(
      id: 'event-1',
      title: 'Mariage de Jean et Marie',
      description: 'Mariage traditionnel et civil à Yaoundé',
      location: 'Salle des fêtes Hilton, Yaoundé',
      date: DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    EventModel(
      id: 'event-2',
      title: 'Anniversaire de Paul',
      description: 'Fête d\'anniversaire pour les 30 ans de Paul',
      location: 'Marina Club, Douala',
      date: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    EventModel(
      id: 'event-3',
      title: 'Remise de diplômes UY1',
      description: 'Cérémonie officielle de remise des diplômes',
      location: 'Campus de Ngoa-Ekellé, Yaoundé',
      date: DateTime.now().add(const Duration(days: 60)),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    EventModel(
      id: 'event-4',
      title: 'Conférence Tech237',
      description: 'Conférence annuelle des professionnels de la tech au Cameroun',
      location: 'Palais des Congrès, Yaoundé',
      date: DateTime.now().add(const Duration(days: 45)),
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    EventModel(
      id: 'event-5',
      title: 'Baptême de Sarah',
      description: 'Baptême de la fille de Marc et Judith',
      location: 'Église Saint-Jean, Douala',
      date: DateTime.now().subtract(const Duration(days: 15)),
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  // Invités de test pour le premier événement
  static final List<GuestModel> _devGuests = [
    GuestModel(
      id: 'guest-1',
      eventId: 'event-1',
      name: 'Pascal Nganou',
      email: 'pascal.nganou@gmail.com',
      phone: '+237 677 88 99 00',
      status: GuestStatus.confirmed,
      notes: 'Ami d\'enfance',
      numberOfGuests: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    GuestModel(
      id: 'guest-2',
      eventId: 'event-1',
      name: 'Nadine Meka',
      email: 'nadine.meka@yahoo.fr',
      phone: '+237 699 12 34 56',
      status: GuestStatus.pending,
      notes: 'Collègue de bureau',
      numberOfGuests: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
    GuestModel(
      id: 'guest-3',
      eventId: 'event-1',
      name: 'Pierre Kamdem',
      email: 'pierre.kamdem@outlook.com',
      phone: '+237 655 45 67 89',
      status: GuestStatus.declined,
      notes: 'Cousin de Marie',
      numberOfGuests: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    GuestModel(
      id: 'guest-4',
      eventId: 'event-1',
      name: 'Esther Biya',
      email: 'esther.biya@gmail.com',
      phone: '+237 678 90 12 34',
      status: GuestStatus.confirmed,
      notes: 'Amie de la famille',
      numberOfGuests: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  // Cadeaux de test pour le premier événement
  static final List<GiftModel> _devGifts = [
    GiftModel(
      id: 'gift-1',
      eventId: 'event-1',
      name: 'Service à vaisselle',
      description: 'Service complet pour 12 personnes',
      price: 75000,
      link: 'https://jumia.cm/vaisselle',
      isReserved: true,
      reservedBy: 'Pascal Nganou',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    GiftModel(
      id: 'gift-2',
      eventId: 'event-1',
      name: 'Machine à café',
      description: 'Machine à expresso automatique',
      price: 150000,
      link: 'https://jumia.cm/cafe',
      isReserved: false,
      reservedBy: '',
      createdAt: DateTime.now().subtract(const Duration(days: 11)),
    ),
    GiftModel(
      id: 'gift-3',
      eventId: 'event-1',
      name: 'Set de draps',
      description: 'Draps en coton égyptien, couleur blanc cassé',
      price: 45000,
      link: 'https://jumia.cm/draps',
      isReserved: false,
      reservedBy: '',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  // Tâches de test pour le premier événement
  static final List<TaskModel> _devTasks = [
    TaskModel(
      id: 'task-1',
      eventId: 'event-1',
      title: 'Réserver la salle',
      description: 'Contacter l\'hôtel Hilton pour confirmer la réservation',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      priority: TaskPriority.high,
      status: TaskStatus.completed,
      assignedTo: 'Moi',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    TaskModel(
      id: 'task-2',
      eventId: 'event-1',
      title: 'Commander le gâteau',
      description: 'Gâteau pour 100 personnes avec déco en blanc et or',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      priority: TaskPriority.medium,
      status: TaskStatus.inProgress,
      assignedTo: 'Marie',
      createdAt: DateTime.now().subtract(const Duration(days: 13)),
    ),
    TaskModel(
      id: 'task-3',
      eventId: 'event-1',
      title: 'Confirmer avec le DJ',
      description: 'Vérifier la liste de musique et l\'horaire',
      dueDate: DateTime.now().add(const Duration(days: 10)),
      priority: TaskPriority.low,
      status: TaskStatus.pending,
      assignedTo: 'Jean',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    TaskModel(
      id: 'task-4',
      eventId: 'event-1',
      title: 'Envoyer les invitations restantes',
      description: 'Famille éloignée et amis à l\'étranger',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: TaskPriority.high,
      status: TaskStatus.pending,
      assignedTo: 'Moi',
      createdAt: DateTime.now().subtract(const Duration(days: 11)),
    ),
  ];

  Future<User> login(String email, String password) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Connexion simulée');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(seconds: 1));
      
      // Sauvegarder l'utilisateur dans les préférences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.tokenPreference, 'dev-token-123');
      await prefs.setString(Constants.userPreference, json.encode(_devUser.toJson()));
      
      // Sauvegarder les données de test
      await _saveDevData(prefs);
      
      return _devUser;
    }
    
    // Mode normal avec API
    print('Tentative de connexion à ${Constants.apiUrl}/auth/login');
    print('Corps de la requête: email=$email');
    
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      print("Statut de la réponse: ${response.statusCode}");
      print("Corps de la réponse: ${response.body}");
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        
        // Rechercher le token dans différents formats possibles
        final token = data['token'] ?? data['access_token'] ?? data['access'];
        
        if (token == null) {
          throw Exception('Token non trouvé dans la réponse');
        }

        // Sauvegarder le token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.tokenPreference, token);
        
        // Extraire les informations utilisateur
        User user;
        if (data['user'] != null) {
          user = User.fromJson(data['user']);
        } else if (data['id'] != null) {
          // Si l'utilisateur est directement dans la réponse principale
          user = User.fromJson(data);
        } else {
          throw Exception('Informations utilisateur non trouvées');
        }
        
        // Sauvegarder les infos utilisateur
        await prefs.setString(Constants.userPreference, json.encode(user.toJson()));
        
        return user;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? error['detail'] ?? 'Échec de la connexion');
      }
    } catch (e) {
      print('Erreur de connexion: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Méthode pour sauvegarder les données de test
  Future<void> _saveDevData(SharedPreferences prefs) async {
    try {
      // Sauvegarder les événements
      await prefs.setString('dev_events', json.encode(
        _devEvents.map((e) => e.toJson()).toList()
      ));
      
      // Sauvegarder les invités
      await prefs.setString('dev_guests', json.encode(
        _devGuests.map((g) => g.toJson()).toList()
      ));
      
      // Sauvegarder les cadeaux
      await prefs.setString('dev_gifts', json.encode(
        _devGifts.map((g) => g.toJson()).toList()
      ));
      
      // Sauvegarder les tâches
      await prefs.setString('dev_tasks', json.encode(
        _devTasks.map((t) => t.toJson()).toList()
      ));
      
      print('Données de test sauvegardées avec succès');
    } catch (e) {
      print('Erreur lors de la sauvegarde des données de test: $e');
    }
  }
  
  Future<User> register(String name, String email, String password) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Inscription simulée');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(seconds: 1));
      
      // Créer un utilisateur simulé avec les informations fournies
      final user = User(
        id: 'dev-user-123',
        name: name,
        email: email,
        phone: '+237 6XX XX XX XX',
        avatar: null,
        createdAt: DateTime.now(),
      );
      
      // Sauvegarder l'utilisateur dans les préférences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.tokenPreference, 'dev-token-123');
      await prefs.setString(Constants.userPreference, json.encode(user.toJson()));
      
      // Sauvegarder les données de test
      await _saveDevData(prefs);
      
      return user;
    }
    
    // Mode normal avec API
    print('Tentative d\'inscription à ${Constants.apiUrl}/auth/register');
    
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );
      
      print("Statut de la réponse: ${response.statusCode}");
      print("Corps de la réponse: ${response.body}");
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Si l'inscription réussit, connectez-vous immédiatement
        return login(email, password);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? error['detail'] ?? 'Échec de l\'inscription');
      }
    } catch (e) {
      print('Erreur d\'inscription: $e');
      throw Exception('Erreur d\'inscription: $e');
    }
  }

  Future<void> logout() async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Déconnexion simulée');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 500));
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.tokenPreference);
      await prefs.remove(Constants.userPreference);
      
      return;
    }
    
    // Mode normal avec API
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(Constants.tokenPreference);
      
      if (token != null) {
        try {
          // Tentative de déconnexion côté serveur, mais on continue même si ça échoue
          await http.post(
            Uri.parse('${Constants.apiUrl}/auth/logout'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );
        } catch (e) {
          print('Erreur lors de la déconnexion côté serveur: $e');
        }
      }

      // Nettoyage local des préférences
      await prefs.remove(Constants.tokenPreference);
      await prefs.remove(Constants.userPreference);
    } catch (e) {
      print('Erreur de déconnexion locale: $e');
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(Constants.userPreference);
      
      if (userJson == null) {
        print('Aucun utilisateur trouvé dans les préférences');
        return null;
      }
      
      try {
        final userData = json.decode(userJson);
        final user = User.fromJson(userData);
        print('Utilisateur récupéré avec succès: ${user.name}');
        return user;
      } catch (e) {
        print('Erreur lors du décodage des données utilisateur: $e');
        // Supprimer les données utilisateur corrompues
        await prefs.remove(Constants.userPreference);
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération des informations utilisateur: $e');
      return null;
    }
  }

  Future<User> updateProfile(User user) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Mise à jour du profil simulée');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 800));
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.userPreference, json.encode(user.toJson()));
      
      return user;
    }
    
    // Mode normal avec API
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(Constants.tokenPreference);
      
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.put(
        Uri.parse('${Constants.apiUrl}/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(user.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final updatedUser = User.fromJson(json.decode(response.body));
        await prefs.setString(Constants.userPreference, json.encode(updatedUser.toJson()));
        return updatedUser;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? error['detail'] ?? 'Échec de la mise à jour du profil');
      }
    } catch (e) {
      print('Erreur de mise à jour du profil: $e');
      throw Exception('Erreur de mise à jour du profil: $e');
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Changement de mot de passe simulé');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 1000));
      
      return;
    }
    
    // Mode normal avec API
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(Constants.tokenPreference);
      
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/auth/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? error['detail'] ?? 'Échec du changement de mot de passe');
      }
    } catch (e) {
      print('Erreur de changement de mot de passe: $e');
      throw Exception('Erreur de changement de mot de passe: $e');
    }
  }
}
