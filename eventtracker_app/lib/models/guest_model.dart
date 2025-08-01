enum GuestStatus { pending, confirmed, declined }

class GuestModel {
  final String id;
  final String eventId;
  final String name;
  final String email;
  final String? phone;
  final GuestStatus status;
  final String? notes;
  final int numberOfGuests;
  final DateTime createdAt;

  GuestModel({
    required this.id,
    required this.eventId,
    required this.name,
    required this.email,
    this.phone,
    required this.status,
    this.notes,
    required this.numberOfGuests,
    required this.createdAt,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    return GuestModel(
      id: json['id'],
      eventId: json['event_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      status: _parseStatus(json['status']),
      notes: json['notes'],
      numberOfGuests: json['number_of_guests'] ?? 1,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static GuestStatus _parseStatus(String? status) {
    switch (status) {
      case 'confirmed':
        return GuestStatus.confirmed;
      case 'declined':
        return GuestStatus.declined;
      default:
        return GuestStatus.pending;
    }
  }

  String get statusString {
    switch (status) {
      case GuestStatus.confirmed:
        return 'Confirmé';
      case GuestStatus.declined:
        return 'Décliné';
      case GuestStatus.pending:
        return 'En attente';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'name': name,
      'email': email,
      'phone': phone,
      'status': _statusToString(),
      'notes': notes,
      'number_of_guests': numberOfGuests,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String _statusToString() {
    switch (status) {
      case GuestStatus.confirmed:
        return 'confirmed';
      case GuestStatus.declined:
        return 'declined';
      case GuestStatus.pending:
        return 'pending';
    }
  }

  GuestModel copyWith({
    String? id,
    String? eventId,
    String? name,
    String? email,
    String? phone,
    GuestStatus? status,
    String? notes,
    int? numberOfGuests,
    DateTime? createdAt,
  }) {
    return GuestModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}