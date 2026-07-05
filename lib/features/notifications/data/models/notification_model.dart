import 'package:rsc_rider/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.recipientId,
    required this.recipientRole,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String recipientId;
  final String recipientRole;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        recipientId: json['recipientId'] as String,
        recipientRole: json['recipientRole'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        isRead: json['isRead'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  NotificationEntity toEntity() => NotificationEntity(
        id: id,
        recipientId: recipientId,
        recipientRole: recipientRole,
        type: type,
        title: title,
        body: body,
        isRead: isRead,
        createdAt: createdAt,
      );
}
