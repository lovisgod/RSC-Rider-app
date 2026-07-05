import 'package:rsc_rider/features/notifications/domain/repositories/notification_repository.dart';

class MarkNotificationReadUsecase {
  const MarkNotificationReadUsecase(this._repository);

  final NotificationRepository _repository;

  Future<void> call(String notificationId) =>
      _repository.markAsRead(notificationId);
}
