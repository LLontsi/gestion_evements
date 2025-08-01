import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';

class CreateTaskScreen extends StatefulWidget {
  final String eventId;
  final TaskModel? task; // Null pour une nouvelle tâche, non-null pour modification

  const CreateTaskScreen({
    super.key,
    required this.eventId,
    this.task,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _assignedToController;
  late DateTime _dueDate;
  late TaskPriority _priority;
  late TaskStatus _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _assignedToController = TextEditingController(text: widget.task?.assignedTo ?? '');
    _dueDate = widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _status = widget.task?.status ?? TaskStatus.pending;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _dueDate.hour,
          _dueDate.minute,
        );
      });
    }
  }

  Future<void> _selectDueTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );
    if (picked != null) {
      setState(() {
        _dueDate = DateTime(
          _dueDate.year,
          _dueDate.month,
          _dueDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      final taskToSave = TaskModel(
        id: widget.task?.id ?? '',
        eventId: widget.eventId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        priority: _priority,
        status: _status,
        assignedTo: _assignedToController.text.trim(),
        createdAt: widget.task?.createdAt ?? DateTime.now(),
      );
      
      if (widget.task == null) {
        await taskProvider.createTask(taskToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tâche créée avec succès')),
          );
        }
      } else {
        await taskProvider.updateTask(taskToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tâche mise à jour avec succès')),
          );
        }
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    final title = isEditing ? 'Modifier la tâche' : 'Ajouter une tâche';

    return Scaffold(
      appBar: CustomAppBar(
        title: title,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Titre',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date d\'échéance'),
                subtitle: Text(DateFormat(Constants.dateFormat).format(_dueDate)),
                onTap: () => _selectDueDate(context),
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Heure d\'échéance'),
                subtitle: Text(DateFormat(Constants.timeFormat).format(_dueDate)),
                onTap: () => _selectDueTime(context),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.priority_high, color: Colors.grey),
                  const SizedBox(width: 16),
                  const Text('Priorité:'),
                  const SizedBox(width: 16),
                  DropdownButton<TaskPriority>(
                    value: _priority,
                    items: [
                      const DropdownMenuItem(
                        value: TaskPriority.low,
                        child: Text('Basse'),
                      ),
                      const DropdownMenuItem(
                        value: TaskPriority.medium,
                        child: Text('Moyenne'),
                      ),
                      const DropdownMenuItem(
                        value: TaskPriority.high,
                        child: Text('Haute'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _priority = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.assignment_turned_in, color: Colors.grey),
                  const SizedBox(width: 16),
                  const Text('Statut:'),
                  const SizedBox(width: 16),
                  DropdownButton<TaskStatus>(
                    value: _status,
                    items: [
                      const DropdownMenuItem(
                        value: TaskStatus.pending,
                        child: Text('À faire'),
                      ),
                      const DropdownMenuItem(
                        value: TaskStatus.inProgress,
                        child: Text('En cours'),
                      ),
                      const DropdownMenuItem(
                        value: TaskStatus.completed,
                        child: Text('Terminée'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _status = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _assignedToController,
                label: 'Assignée à',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(isEditing ? 'Mettre à jour' : 'Ajouter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}