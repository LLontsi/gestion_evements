import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_list_item.dart';
import 'create_task_screen.dart';

class PlanningScreen extends StatefulWidget {
  final String eventId;

  const PlanningScreen({super.key, required this.eventId});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  bool _isLoading = false;
  List<TaskModel> _tasks = [];
  TaskStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      _tasks = await taskProvider.getTasksByEvent(widget.eventId);
      _applyFilter();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des tâches: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_filterStatus != null) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final allTasks = taskProvider.getTasksForEvent(widget.eventId);
      setState(() {
        _tasks = allTasks.where((task) => task.status == _filterStatus).toList();
      });
    } else {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      setState(() {
        _tasks = taskProvider.getTasksForEvent(widget.eventId);
      });
    }
  }

  void _onCreateTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTaskScreen(eventId: widget.eventId),
      ),
    ).then((_) => _loadTasks());
  }

  Future<void> _updateTaskStatus(String taskId, TaskStatus newStatus) async {
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.updateTaskStatus(taskId, newStatus);
      _applyFilter();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  void _showTaskOptions(TaskModel task) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTaskScreen(
                      eventId: widget.eventId,
                      task: task,
                    ),
                  ),
                ).then((_) => _loadTasks());
              },
            ),
            if (task.status != TaskStatus.completed)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Marquer comme terminée'),
                onTap: () {
                  Navigator.pop(context);
                  _updateTaskStatus(task.id, TaskStatus.completed);
                },
              ),
            if (task.status != TaskStatus.inProgress)
              ListTile(
                leading: const Icon(Icons.pending_actions, color: Colors.orange),
                title: const Text('Marquer comme en cours'),
                onTap: () {
                  Navigator.pop(context);
                  _updateTaskStatus(task.id, TaskStatus.inProgress);
                },
              ),
            if (task.status != TaskStatus.pending)
              ListTile(
                leading: const Icon(Icons.restart_alt, color: Colors.blue),
                title: const Text('Marquer comme à faire'),
                onTap: () {
                  Navigator.pop(context);
                  _updateTaskStatus(task.id, TaskStatus.pending);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(task);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(TaskModel task) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cette tâche ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                
                try {
                  final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                  await taskProvider.deleteTask(task.id);
                  _loadTasks();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tâche supprimée avec succès')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: ${e.toString()}')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Toutes les tâches'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _filterStatus = null;
              });
              _applyFilter();
            },
          ),
          ListTile(
            leading: const Icon(Icons.pending_actions, color: Colors.blue),
            title: const Text('À faire'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _filterStatus = TaskStatus.pending;
              });
              _applyFilter();
            },
          ),
          ListTile(
            leading: const Icon(Icons.timelapse, color: Colors.orange),
            title: const Text('En cours'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _filterStatus = TaskStatus.inProgress;
              });
              _applyFilter();
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: const Text('Terminées'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _filterStatus = TaskStatus.completed;
              });
              _applyFilter();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Liste des tâches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Bouton de filtre
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterOptions,
                ),
              ],
            ),
          ),
          // Statistiques des tâches
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildTaskStats(),
          ),
          const SizedBox(height: 8),
          // Liste des tâches
          Expanded(
            child: _tasks.isEmpty
                ? _buildEmptyState()
                : _buildTaskList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreateTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskStats() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final allTasks = taskProvider.getTasksForEvent(widget.eventId);
    
    final totalTasks = allTasks.length;
    final completedTasks = allTasks.where((t) => t.status == TaskStatus.completed).length;
    final inProgressTasks = allTasks.where((t) => t.status == TaskStatus.inProgress).length;
    final pendingTasks = allTasks.where((t) => t.status == TaskStatus.pending).length;
    
    double completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progression: ${completionRate.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: totalTasks > 0 ? completedTasks / totalTasks : 0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('À faire', pendingTasks, Colors.blue),
                _buildStatItem('En cours', inProgressTasks, Colors.orange),
                _buildStatItem('Terminées', completedTasks, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune tâche pour cet événement',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _onCreateTask,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une tâche'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return TaskListItem(
            task: task,
            onTap: () => _showTaskOptions(task),
            onStatusChanged: (value) {
              if (value != null) {
                _updateTaskStatus(
                  task.id,
                  value ? TaskStatus.completed : TaskStatus.pending,
                );
              }
            },
          );
        },
      ),
    );
  }
}