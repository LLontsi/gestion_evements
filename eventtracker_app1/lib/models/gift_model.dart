// lib/models/gift_model.dart
class Gift {
  final int id;
  final int listId;
  final String name;
  final String description;
  final double? price;
  final String url;
  final String? image;
  final String status; // 'available', 'reserved', 'purchased'
  final int? reservedById;
  
  Gift({
    required this.id,
    required this.listId,
    required this.name,
    required this.description,
    this.price,
    required this.url,
    this.image,
    required this.status,
    this.reservedById,
  });
  
  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      id: json['id'],
      listId: json['list'],
      name: json['name'],
      description: json['description'] ?? '',
      price: json['price'] != null ? double.parse(json['price'].toString()) : null,
      url: json['url'] ?? '',
      image: json['image'],
      status: json['status'],
      reservedById: json['reserved_by'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'list': listId,
      'name': name,
      'description': description,
      'price': price,
      'url': url,
      'status': status,
    };
  }
}

class GiftList {
  final int id;
  final int eventId;
  final String name;
  final String description;
  
  GiftList({
    required this.id,
    required this.eventId,
    required this.name,
    required this.description,
  });
  
  factory GiftList.fromJson(Map<String, dynamic> json) {
    return GiftList(
      id: json['id'],
      eventId: json['event'],
      name: json['name'],
      description: json['description'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'event': eventId,
      'name': name,
      'description': description,
    };
  }
}