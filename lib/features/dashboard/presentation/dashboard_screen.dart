import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/router/route_names.dart';
import 'package:rsc_rider/core/widgets/app_loader.dart';
import 'package:rsc_rider/core/widgets/app_snackbar.dart';
import 'package:rsc_rider/core/widgets/error_view.dart';
import 'package:rsc_rider/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:rsc_rider/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:rsc_rider/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:rsc_rider/features/dashboard/presentation/widgets/active_delivery_banner.dart';
import 'package:rsc_rider/features/dashboard/presentation/widgets/availability_toggle_card.dart';
import 'package:rsc_rider/features/dashboard/presentation/widgets/earnings_summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) =>
            GetIt.instance<DashboardBloc>()..add(const DashboardStarted()),
        child: const _DashboardView(),
      );
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashboardState>(
      listenWhen: (previous, current) =>
          current is DashboardLoaded && current.availabilityError != null,
      listener: (context, state) {
        final message = (state as DashboardLoaded).availabilityError;
        if (message != null) AppSnackbar.showError(context, message);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.appName)),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            return switch (state) {
              DashboardInitial() || DashboardLoading() => const AppLoader(),
              DashboardError(:final message) => ErrorView(
                  message: message,
                  onRetry: () => context
                      .read<DashboardBloc>()
                      .add(const DashboardStarted()),
                ),
              DashboardLoaded() => _DashboardContent(state: state),
            };
          },
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.state});

  final DashboardLoaded state;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;

    return RefreshIndicator(
      onRefresh: () async => context
          .read<DashboardBloc>()
          .add(const DashboardRefreshRequested()),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          AvailabilityToggleCard(
            isOnline: summary.status.isOnline,
            isUpdating: state.isUpdatingAvailability,
            onChanged: (isOnline) => context
                .read<DashboardBloc>()
                .add(DashboardAvailabilityToggled(isOnline: isOnline)),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          if (summary.activeDelivery != null) ...[
            ActiveDeliveryBanner(
              delivery: summary.activeDelivery!,
              onTap: () => context.push(RouteNames.activeDelivery),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
          ],
          EarningsSummaryCard(earnings: summary.earnings),
        ],
      ),
    );
  }
}
