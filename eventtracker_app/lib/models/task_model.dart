enum TaskPriority { high, medium, low }
enum TaskStatus { pending, inProgress, completed }

class TaskModel {
  final String id;
  final String eventId;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String? assignedTo;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.eventId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    this.assignedTo,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      eventId: json['event_id'],
      title: json['title'],
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['due_date']),
      priority: _parsePriority(json['priority']),
      status: _parseStatus(json['status']),
      assignedTo: json['assigned_to'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static TaskPriority _parsePriority(String? priority) {
    switch (priority) {
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      default:
        return TaskPriority.low;
    }
  }

  static TaskStatus _parseStatus(String? status) {
    switch (status) {
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      default:
        return TaskStatus.pending;
    }
  }

  String get priorityString {
    switch (priority) {
      case TaskPriority.high:
        return 'Haute';
      case TaskPriority.medium:
        return 'Moyenne';
      case TaskPriority.low:
        return 'Basse';
    }
  }

  String get statusString {
    switch (status) {
      case TaskStatus.pending:
        return 'À faire';
      case TaskStatus.inProgress:
        return 'En cours';
      case TaskStatus.completed:
        return 'Terminée';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'priority': _priorityToString(),
      'status': _statusToString(),
      'assigned_to': assignedTo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String _priorityToString() {
    switch (priority) {
      case TaskPriority.high:
        return 'high';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.low:
        return 'low';
    }
  }

  String _statusToString() {
    switch (status) {
      case TaskStatus.pending:
        return 'pending';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.completed:
        return 'completed';
    }
  }

  TaskModel copyWith({
    String? id,
    String? eventId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? assignedTo,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}