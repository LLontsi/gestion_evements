import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class TaskService {
  final ApiService _apiService = ApiService();

  Future<List<TaskModel>> getTasksByEvent(String eventId) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Récupération des tâches simulées');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 650));
      
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('dev_tasks');
      
      if (tasksJson != null) {
        final List<dynamic> tasksData = json.decode(tasksJson);
        return tasksData
          .where((t) => t['eventId'] == eventId)
          .map((t) => TaskModel.fromJson(t))
          .toList();
      }
      
      return [];
    }
    
    // Mode normal avec API
    final response = await _apiService.get('events/$eventId/tasks');
    
    if (response != null && response is List) {
      return response.map((item) => TaskModel.fromJson(item)).toList();
    }
    
    return [];
  }

  Future<TaskModel> getTaskById(String id) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Récupération d\'une tâche simulée');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 450));
      
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('dev_tasks');
      
      if (tasksJson != null) {
        final List<dynamic> tasksData = json.decode(tasksJson);
        final taskData = tasksData.firstWhere(
          (t) => t['id'] == id, 
          orElse: () => throw Exception('Tâche non trouvée')
        );
        return TaskModel.fromJson(taskData);
      }
      
      throw Exception('Tâche non trouvée');
    }
    
    // Mode normal avec API
    final response = await _apiService.get('tasks/$id');
    
    if (response != null) {
      return TaskModel.fromJson(response);
    }
    
    throw Exception('Tâche non trouvée');
  }

  Future<TaskModel> createTask(TaskModel task) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Création d\'une tâche simulée');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 750));
      
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('dev_tasks');
      
      // Créer un nouvel ID
      final newId = 'task-${DateTime.now().millisecondsSinceEpoch}';
      final newTask = task.copyWith(
        id: newId,
        createdAt: DateTime.now(),
      );
      
      // Ajouter aux tâches existantes
      if (tasksJson != null) {
        final List<dynamic> tasksData = json.decode(tasksJson);
        tasksData.add(newTask.toJson());
        await prefs.setString('dev_tasks', json.encode(tasksData));
      } else {
        await prefs.setString('dev_tasks', json.encode([newTask.toJson()]));
      }
      
      return newTask;
    }
    
    // Mode normal avec API
    final response = await _apiService.post('tasks', task.toJson());
    
    if (response != null) {
      return TaskModel.fromJson(response);
    }
    
    throw Exception('Échec de la création de la tâche');
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Mise à jour d\'une tâche simulée');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 700));
      
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('dev_tasks');
      
      if (tasksJson != null) {
        final List<dynamic> tasksData = json.decode(tasksJson);
        final index = tasksData.indexWhere((t) => t['id'] == task.id);
        
        if (index != -1) {
          tasksData[index] = task.toJson();
          await prefs.setString('dev_tasks', json.encode(tasksData));
          return task;
        }
        
        throw Exception('Tâche non trouvée');
      }
      
      throw Exception('Aucune tâche enregistrée');
    }
    
    // Mode normal avec API
    final response = await _apiService.put('tasks/${task.id}', task.toJson());
    
    if (response != null) {
      return TaskModel.fromJson(response);
    }
    
    throw Exception('Échec de la mise à jour de la tâche');
  }

  Future<void> deleteTask(String id) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Suppression d\'une tâche simulée');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 550));
      
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('dev_tasks');
      
      if (tasksJson != null) {
        final List<dynamic> tasksData = json.decode(tasksJson);
        final newTasksData = tasksData.where((t) => t['id'] != id).toList();
        await prefs.setString('dev_tasks', json.encode(newTasksData));
      }
      
      return;
    }
    
    // Mode normal avec API
    await _apiService.delete('tasks/$id');
  }

  Future<TaskModel> updateTaskStatus(String id, TaskStatus status) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Mise à jour du statut d\'une tâche simulée');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 600));
      
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('dev_tasks');
      
      if (tasksJson != null) {
        final List<dynamic> tasksData = json.decode(tasksJson);
        final index = tasksData.indexWhere((t) => t['id'] == id);
        
        if (index != -1) {
          final task = TaskModel.fromJson(tasksData[index]);
          final updatedTask = task.copyWith(status: status);
          
          tasksData[index] = updatedTask.toJson();
          await prefs.setString('dev_tasks', json.encode(tasksData));
          
          return updatedTask;
        }
        
        throw Exception('Tâche non trouvée');
      }
      
      throw Exception('Aucune tâche enregistrée');
    }
    
    // Mode normal avec API
    String statusStr;
    switch (status) {
      case TaskStatus.inProgress:
        statusStr = 'in_progress';
        break;
      case TaskStatus.completed:
        statusStr = 'completed';
        break;
      default:
        statusStr = 'pending';
    }

    final response = await _apiService.put('tasks/$id/status', {
      'status': statusStr,
    });
    
    if (response != null) {
      return TaskModel.fromJson(response);
    }
    
    throw Exception('Échec de la mise à jour du statut');
  }

  Future<TaskModel> assignTask(String id, String assignedTo) async {
    // Mode développement
    if (Constants.isDevMode) {
      print('Mode DEV: Assignation d\'une tâche simulée');
      
      // Simuler une attente pour l'UI
      await Future.delayed(const Duration(milliseconds: 600));
      
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('dev_tasks');
      
      if (tasksJson != null) {
        final List<dynamic> tasksData = json.decode(tasksJson);
        final index = tasksData.indexWhere((t) => t['id'] == id);
        
        if (index != -1) {
          final task = TaskModel.fromJson(tasksData[index]);
          final updatedTask = task.copyWith(assignedTo: assignedTo);
          
          tasksData[index] = updatedTask.toJson();
          await prefs.setString('dev_tasks', json.encode(tasksData));
          
          return updatedTask;
        }
        
        throw Exception('Tâche non trouvée');
      }
      
      throw Exception('Aucune tâche enregistrée');
    }
    
    // Mode normal avec API
    final response = await _apiService.put('tasks/$id/assign', {
      'assigned_to': assignedTo,
    });
    
    if (response != null) {
      return TaskModel.fromJson(response);
    }
    
    throw Exception('Échec de l\'assignation de la tâche');
  }
}
