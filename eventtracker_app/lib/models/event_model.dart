import 'package:intl/intl.dart';
import '../utils/constants.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedDate {
    return DateFormat(Constants.dateFormat).format(date);
  }

  String get formattedTime {
    return DateFormat(Constants.timeFormat).format(date);
  }

  String get formattedDateTime {
    return DateFormat(Constants.dateTimeFormat).format(date);
  }

  bool get isPastEvent {
    return date.isBefore(DateTime.now());
  }

  int get daysUntilEvent {
    final now = DateTime.now();
    final difference = date.difference(now);
    return difference.inDays;
  }
}