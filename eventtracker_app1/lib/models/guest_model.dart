// lib/models/guest_model.dart
class Guest {
  final int id;
  final int eventId;
  final String name;
  final String email;
  final String phone;
  final String responseStatus; // 'pending', 'accepted', 'declined'
  final int plusOnes;
  final String note;
  
  Guest({
    required this.id,
    required this.eventId,
    required this.name,
    required this.email,
    required this.phone,
    required this.responseStatus,
    required this.plusOnes,
    required this.note,
  });
  
  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'],
      eventId: json['event'],
      name: json['name'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      responseStatus: json['response_status'],
      plusOnes: json['plus_ones'] ?? 0,
      note: json['note'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'event': eventId,
      'name': name,
      'email': email,
      'phone': phone,
      'response_status': responseStatus,
      'plus_ones': plusOnes,
      'note': note,
    };
  }
}