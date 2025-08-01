class GiftModel {
  final String id;
  final String eventId;
  final String name;
  final String description;
  final double price;
  final String link;
  final bool isReserved;
  final String reservedBy;
  final DateTime? createdAt;

  GiftModel({
    required this.id,
    required this.eventId,
    required this.name,
    required this.description,
    required this.price,
    required this.link,
    required this.isReserved,
    required this.reservedBy,
    this.createdAt,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id'],
      eventId: json['event_id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      link: json['link'] ?? '',
      isReserved: json['is_reserved'] ?? false,
      reservedBy: json['reserved_by'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'name': name,
      'description': description,
      'price': price,
      'link': link,
      'is_reserved': isReserved,
      'reserved_by': reservedBy,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  GiftModel copyWith({
    String? id,
    String? eventId,
    String? name,
    String? description,
    double? price,
    String? link,
    bool? isReserved,
    String? reservedBy,
    DateTime? createdAt,
  }) {
    return GiftModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      link: link ?? this.link,
      isReserved: isReserved ?? this.isReserved,
      reservedBy: reservedBy ?? this.reservedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}