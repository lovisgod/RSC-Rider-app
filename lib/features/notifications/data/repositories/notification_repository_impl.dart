import 'package:dio/dio.dart';
import 'package:rsc_rider/core/constants/api_endpoints.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/network/api_response.dart';
import 'package:rsc_rider/core/network/dio_client.dart';
import 'package:rsc_rider/core/utils/logger.dart';
import 'package:rsc_rider/features/notifications/data/models/notification_model.dart';
import 'package:rsc_rider/features/notifications/domain/entities/notification_entity.dart';
import 'package:rsc_rider/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._client);

  final DioClient _client;

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    try {
      final response = await _client.dio
          .get<Map<String, dynamic>>(ApiEndpoints.notifications);
      final data = response.data!['data'] as List<dynamic>;
      final notifications = data
          .map(
            (json) => NotificationModel.fromJson(
              json as Map<String, dynamic>,
            ).toEntity(),
          )
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception(AppStrings.sessionExpired);
      }
      final error = e.error;
      throw Exception(
        error is ApiFailure ? error.message : AppStrings.somethingWentWrong,
      );
    }
  }

  // Never crashes the app — a failed "mark as read" is not worth interrupting
  // the rider's flow over, so it's logged and swallowed.
  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _client.dio
          .patch<void>(ApiEndpoints.markNotificationRead(notificationId));
    } catch (e) {
      appLogger.w('[Notifications] Failed to mark as read.', error: e);
    }
  }
}
