import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/widgets/empty_state.dart';
import 'package:rsc_rider/core/widgets/error_view.dart';
import 'package:rsc_rider/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:rsc_rider/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:rsc_rider/features/notifications/presentation/widgets/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: GetIt.instance<NotificationsCubit>()..loadNotifications(),
        child: const _NotificationsView(),
      );
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.navyDark,
          centerTitle: true,
          title: Text(
            AppStrings.notifications,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textOnDark,
            ),
          ),
          actions: [
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                if (state.unreadCount == 0) return const SizedBox.shrink();
                return TextButton(
                  onPressed: () =>
                      context.read<NotificationsCubit>().markAllAsRead(),
                  child: Text(
                    AppStrings.markAllRead,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textOnDark,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state.isLoading && state.notifications.isEmpty) {
              return const _ShimmerList();
            }
            if (state.error != null && state.notifications.isEmpty) {
              return ErrorView(
                message: state.error!,
                onRetry: () =>
                    context.read<NotificationsCubit>().loadNotifications(),
              );
            }
            if (state.notifications.isEmpty) {
              return const EmptyState(
                icon: Icons.notifications_none,
                title: AppStrings.noNotificationsYet,
                subtitle: AppStrings.orderUpdatesHere,
              );
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  context.read<NotificationsCubit>().loadNotifications(),
              child: ListView.separated(
                itemCount: state.notifications.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return NotificationTile(
                    notification: notification,
                    onTap: () => context
                        .read<NotificationsCubit>()
                        .markAsRead(notification.id),
                  );
                },
              ),
            );
          },
        ),
      );
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        itemCount: 5,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.divider),
        itemBuilder: (context, index) => const _ShimmerTile(),
      );
}

class _ShimmerTile extends StatefulWidget {
  const _ShimmerTile();

  @override
  State<_ShimmerTile> createState() => _ShimmerTileState();
}

class _ShimmerTileState extends State<_ShimmerTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween(begin: 0.4, end: 1.0).animate(_controller),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.shimmer,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.shimmer,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.shimmer,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
