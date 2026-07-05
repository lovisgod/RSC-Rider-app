import 'package:rsc_rider/features/notifications/domain/entities/notification_entity.dart';

abstract interface class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();

  Future<void> markAsRead(String notificationId);
}
