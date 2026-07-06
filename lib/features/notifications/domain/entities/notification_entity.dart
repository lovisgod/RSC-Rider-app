import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/utils/formatters.dart';

class NotificationEntity extends Equatable {
  const NotificationEntity({
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

  bool get isOrderStatus => type == 'ORDER_STATUS';

  IconData get notificationIcon =>
      isOrderStatus ? Icons.delivery_dining : Icons.notifications;

  String get displayTime {
    final now = DateTime.now();
    final isToday = createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
    if (isToday) return AppFormatters.time(createdAt);

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = createdAt.year == yesterday.year &&
        createdAt.month == yesterday.month &&
        createdAt.day == yesterday.day;
    if (isYesterday) return AppStrings.yesterday;

    return AppFormatters.shortDate(createdAt);
  }

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
        id: id,
        recipientId: recipientId,
        recipientRole: recipientRole,
        type: type,
        title: title,
        body: body,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        recipientId,
        recipientRole,
        type,
        title,
        body,
        isRead,
        createdAt,
      ];
}
