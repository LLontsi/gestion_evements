class PhotoModel {
  final String id;
  final String eventId;
  final String url;
  final String? caption;
  final String uploadedBy;
  final DateTime createdAt;

  PhotoModel({
    required this.id,
    required this.eventId,
    required this.url,
    this.caption,
    required this.uploadedBy,
    required this.createdAt,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'],
      eventId: json['event_id'],
      url: json['url'],
      caption: json['caption'],
      uploadedBy: json['uploaded_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'url': url,
      'caption': caption,
      'uploaded_by': uploadedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PhotoModel copyWith({
    String? id,
    String? eventId,
    String? url,
    String? caption,
    String? uploadedBy,
    DateTime? createdAt,
  }) {
    return PhotoModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      url: url ?? this.url,
      caption: caption ?? this.caption,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}