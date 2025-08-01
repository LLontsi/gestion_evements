import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  Map<String, List<TaskModel>> _tasksByEvent = {};
  bool _isLoading = false;
  String? _error;

  List<TaskModel> getTasksForEvent(String eventId) => _tasksByEvent[eventId] ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<List<TaskModel>> getTasksByEvent(String eventId) async {
    _setLoading(true);
    _clearError();

    try {
      final tasks = await _taskService.getTasksByEvent(eventId);
      _tasksByEvent[eventId] = tasks;
      notifyListeners();
      return tasks;
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<TaskModel> getTaskById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      return await _taskService.getTaskById(id);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<TaskModel> createTask(TaskModel task) async {
    _setLoading(true);
    _clearError();

    try {
      final createdTask = await _taskService.createTask(task);
      
      if (_tasksByEvent.containsKey(task.eventId)) {
        _tasksByEvent[task.eventId]!.add(createdTask);
      } else {
        _tasksByEvent[task.eventId] = [createdTask];
      }
      
      notifyListeners();
      return createdTask;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedTask = await _taskService.updateTask(task);
      
      if (_tasksByEvent.containsKey(task.eventId)) {
        final index = _tasksByEvent[task.eventId]!.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasksByEvent[task.eventId]![index] = updatedTask;
        }
      }
      
      notifyListeners();
      return updatedTask;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTask(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _taskService.deleteTask(id);
      
      // Supprimer la tâche de toutes les listes
      for (final eventId in _tasksByEvent.keys) {
        _tasksByEvent[eventId]!.removeWhere((t) => t.id == id);
      }
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<TaskModel> updateTaskStatus(String id, TaskStatus status) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedTask = await _taskService.updateTaskStatus(id, status);
      
      // Mettre à jour la tâche dans toutes les listes
      for (final eventId in _tasksByEvent.keys) {
        final index = _tasksByEvent[eventId]!.indexWhere((t) => t.id == id);
        if (index != -1) {
          _tasksByEvent[eventId]![index] = updatedTask;
        }
      }
      
      notifyListeners();
      return updatedTask;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<TaskModel> assignTask(String id, String assignedTo) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedTask = await _taskService.assignTask(id, assignedTo);
      
      // Mettre à jour la tâche dans toutes les listes
      for (final eventId in _tasksByEvent.keys) {
        final index = _tasksByEvent[eventId]!.indexWhere((t) => t.id == id);
        if (index != -1) {
          _tasksByEvent[eventId]![index] = updatedTask;
        }
      }
      
      notifyListeners();
      return updatedTask;
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