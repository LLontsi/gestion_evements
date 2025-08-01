import 'package:intl/intl.dart';

class Event {
  final int id;
  final String title;
  final int eventTypeId;
  final String eventTypeName;
  final String eventTypeColor;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isPrivate;
  final List<Reminder> reminders;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Event({
    required this.id,
    required this.title,
    required this.eventTypeId,
    required this.eventTypeName,
    required this.eventTypeColor,
    required this.description,
    required this.location,
    required this.startDate,
    this.endDate,
    this.isPrivate = false,
    this.reminders = const [],
    required this.createdAt,
    required this.updatedAt,
  });
  
  String get formattedStartDate {
    return DateFormat('dd/MM/yyyy HH:mm').format(startDate);
  }
  
  String get formattedEndDate {
    return endDate != null 
        ? DateFormat('dd/MM/yyyy HH:mm').format(endDate!) 
        : '';
  }
  
  factory Event.fromJson(Map<String, dynamic> json) {
    List<Reminder> reminders = [];
    if (json['reminders'] != null) {
      reminders = List<Reminder>.from(
        json['reminders'].map((x) => Reminder.fromJson(x)),
      );
    }

    return Event(
      id: json['id'],
      title: json['title'],
      eventTypeId: json['event_type'],
      eventTypeName: json['event_type_name'],
      eventTypeColor: json['event_type_color'] ?? '#6200EE',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      isPrivate: json['is_private'] ?? false,
      reminders: reminders,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'event_type': eventTypeId,
      'description': description,
      'location': location,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_private': isPrivate,
    };
  }
}

class Reminder {
  final int id;
  final DateTime reminderDate;
  final String message;
  final bool sent;

  Reminder({
    required this.id,
    required this.reminderDate,
    this.message = '',
    required this.sent,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      reminderDate: DateTime.parse(json['reminder_date']),
      message: json['message'] ?? '',
      sent: json['sent'],
    );
  }
}

class EventType {
  final int id;
  final String name;
  final String icon;
  final String color;

  EventType({
    required this.id,
    required this.name,
    this.icon = '',
    required this.color,
  });

  factory EventType.fromJson(Map<String, dynamic> json) {
    return EventType(
      id: json['id'],
      name: json['name'],
      icon: json['icon'] ?? '',
      color: json['color'] ?? '#6200EE',
    );
  }
}