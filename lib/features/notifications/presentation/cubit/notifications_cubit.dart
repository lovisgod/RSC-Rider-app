import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rsc_rider/core/storage/local_storage.dart';
import 'package:rsc_rider/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:rsc_rider/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:rsc_rider/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required this._getNotifications,
    required this._markNotificationRead,
    required this._localStorage,
  }) : super(const NotificationsState());

  final GetNotificationsUsecase _getNotifications;
  final MarkNotificationReadUsecase _markNotificationRead;
  final LocalStorage _localStorage;

  Future<void> loadNotifications() async {
    // Never hit the notifications endpoint without a rider session — the
    // call would just 401.
    final riderId = await _localStorage.getRiderId();
    if (riderId == null) return;

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final notifications = await _getNotifications();
      emit(state.copyWith(notifications: notifications, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  // Optimistic — the UI updates immediately, the API call happens silently
  // in the background and never surfaces an error (see repository impl).
  void markAsRead(String notificationId) {
    final updated = [
      for (final n in state.notifications)
        n.id == notificationId ? n.copyWith(isRead: true) : n,
    ];
    emit(state.copyWith(notifications: updated));
    _markNotificationRead(notificationId);
  }

  void markAllAsRead() {
    final unreadIds = state.notifications
        .where((n) => !n.isRead)
        .map((n) => n.id)
        .toList();

    final updated = [
      for (final n in state.notifications) n.copyWith(isRead: true),
    ];
    emit(state.copyWith(notifications: updated));

    for (final id in unreadIds) {
      _markNotificationRead(id);
    }
  }
}
