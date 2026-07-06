import 'package:rsc_rider/features/notifications/domain/entities/notification_entity.dart';
import 'package:rsc_rider/features/notifications/domain/repositories/notification_repository.dart';

class GetNotificationsUsecase {
  const GetNotificationsUsecase(this._repository);

  final NotificationRepository _repository;

  Future<List<NotificationEntity>> call() => _repository.getNotifications();
}
