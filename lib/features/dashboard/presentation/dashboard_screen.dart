import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/router/route_names.dart';
import 'package:rsc_rider/core/services/location_service.dart';
import 'package:rsc_rider/core/services/socket_service.dart';
import 'package:rsc_rider/core/widgets/app_loader.dart';
import 'package:rsc_rider/core/widgets/app_snackbar.dart';
import 'package:rsc_rider/core/widgets/error_view.dart';
import 'package:rsc_rider/core/widgets/logout_confirmation_sheet.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_state.dart';
import 'package:rsc_rider/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:rsc_rider/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:rsc_rider/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/active_orders_cubit.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/active_orders_state.dart';
import 'package:rsc_rider/features/delivery/presentation/widgets/assigned_order_card.dart';

// Victoria Island, Lagos — default map center until the rider's position loads.
const LatLng _defaultCenter = LatLng(6.4281, 3.4219);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => GetIt.instance<DashboardBloc>()
              ..add(const DashboardStarted()),
          ),
          BlocProvider(create: (_) => GetIt.instance<AuthBloc>()),
          // .value, not create: — ActiveOrdersCubit is a GetIt singleton that
          // must survive navigation away from the dashboard. BlocProvider
          // .create() takes ownership and closes it on unmount, which would
          // kill the shared instance and crash any later emit (e.g. from
          // SocketEventHandler or a push-notification reload).
          BlocProvider.value(value: GetIt.instance<ActiveOrdersCubit>()),
        ],
        child: const _DashboardView(),
      );
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  GoogleMapController? _mapController;
  late final ActiveOrdersCubit _activeOrdersCubit;

  @override
  void initState() {
    super.initState();
    _activeOrdersCubit = context.read<ActiveOrdersCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final dashboardState = context.read<DashboardBloc>().state;
      if (dashboardState is DashboardLoaded && dashboardState.isOnline) {
        unawaited(_activeOrdersCubit.loadAssignedOrders());
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _moveToRiderLocation();
  }

  void _moveToRiderLocation() {
    final state = context.read<DashboardBloc>().state;
    if (state is DashboardLoaded &&
        state.riderLatitude != null &&
        state.riderLongitude != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(state.riderLatitude!, state.riderLongitude!),
        ),
      );
    }
  }

  void _centerOnRider(DashboardLoaded state) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(state.riderLatitude!, state.riderLongitude!),
        14.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashboardState>(
      listenWhen: (previous, current) =>
          current is DashboardLoaded &&
          current.riderLatitude != null &&
          current.riderLongitude != null &&
          (previous is! DashboardLoaded ||
              previous.riderLatitude != current.riderLatitude ||
              previous.riderLongitude != current.riderLongitude),
      listener: (context, state) {
        final loaded = state as DashboardLoaded;
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(loaded.riderLatitude!, loaded.riderLongitude!),
          ),
        );
      },
      child: BlocListener<DashboardBloc, DashboardState>(
        // One-shot availability failure → snackbar (the toggle has already
        // been reverted by the bloc when this fires).
        listenWhen: (previous, current) =>
            current is DashboardLoaded &&
            current.availabilityError != null &&
            (previous is! DashboardLoaded ||
                previous.availabilityError != current.availabilityError),
        listener: (context, state) => AppSnackbar.showError(
          context,
          (state as DashboardLoaded).availabilityError!,
        ),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) context.go(RouteNames.login);
          },
          child: Scaffold(
            body: Stack(
              children: [
                BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    return switch (state) {
                      DashboardInitial() ||
                      DashboardLoading() =>
                        const AppLoader(),
                      DashboardError(:final message) => ErrorView(
                          message: message,
                          onRetry: () => context
                              .read<DashboardBloc>()
                              .add(const DashboardStarted()),
                        ),
                      DashboardLoaded() => _MapDashboard(
                          state: state,
                          onMapCreated: _onMapCreated,
                          onCenterOnRider: _centerOnRider,
                        ),
                    };
                  },
                ),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) => state is AuthLoading
                      ? const ColoredBox(
                          color: Color(0x33000000),
                          child: Center(child: AppLoader()),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapDashboard extends StatelessWidget {
  const _MapDashboard({
    required this.state,
    required this.onMapCreated,
    required this.onCenterOnRider,
  });

  final DashboardLoaded state;
  final void Function(GoogleMapController) onMapCreated;
  final void Function(DashboardLoaded) onCenterOnRider;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                unawaited(context.read<ActiveOrdersCubit>().loadAssignedOrders());
              },
              color: AppColors.primary,
              child: Stack(
                children: [
                  _MapLayer(state: state, onMapCreated: onMapCreated),
                  if (!state.isOnline) const _OfflineOverlay(),
                  _TopBar(state: state),
                  Positioned(
                    right: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: FloatingActionButton.small(
                      heroTag: 'center_on_me',
                      backgroundColor: AppColors.navy,
                      tooltip: AppStrings.centerOnMe,
                      onPressed: state.riderLatitude != null &&
                              state.riderLongitude != null
                          ? () => onCenterOnRider(state)
                          : null,
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _BottomPanel(state: state),
        ],
      );
}

class _MapLayer extends StatelessWidget {
  const _MapLayer({required this.state, required this.onMapCreated});

  final DashboardLoaded state;
  final void Function(GoogleMapController) onMapCreated;

  Set<Marker> _buildMarkers(BuildContext context) => {
        if (state.isOnline)
          for (final kitchen in state.nearbyKitchens)
            Marker(
              markerId: MarkerId(kitchen.id),
              position: LatLng(kitchen.latitude, kitchen.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange,
              ),
              infoWindow: InfoWindow(title: '${kitchen.emoji} ${kitchen.name}'),
              onTap: () => AppSnackbar.showInfo(context, kitchen.name),
            ),
        if (state.riderLatitude != null && state.riderLongitude != null)
          Marker(
            markerId: const MarkerId('rider'),
            position: LatLng(state.riderLatitude!, state.riderLongitude!),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
      };

  @override
  Widget build(BuildContext context) {
    final center = state.riderLatitude != null && state.riderLongitude != null
        ? LatLng(state.riderLatitude!, state.riderLongitude!)
        : _defaultCenter;

    // Non-interactive while offline — the grey _OfflineOverlay sits on top.
    return AbsorbPointer(
      absorbing: !state.isOnline,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(target: center, zoom: 14.5),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: true,
        onMapCreated: onMapCreated,
        markers: _buildMarkers(context),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.state});

  final DashboardLoaded state;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  String get _firstName {
    final parts = state.riderName.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : state.riderName;
  }

  @override
  Widget build(BuildContext context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.navyDark.withValues(alpha: 0.85),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.navy,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      state.riderInitials,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textOnDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_greeting, $_firstName!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.textOnDark,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          state.isOnline
                              ? '● ${AppStrings.youAreOnline}'
                              : '● ${AppStrings.youAreOffline}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: state.isOnline
                                ? AppColors.onlineGreen
                                : AppColors.offlineRed,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const _SocketStatusIndicator(),
                        if (state.isOnline) ...[
                          const SizedBox(height: AppSpacing.xs),
                          _BroadcastIndicator(
                            hasLocationError: state.locationError != null,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        AppSnackbar.showInfo(context, AppStrings.comingSoon),
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textOnDark,
                    ),
                  ),
                  IconButton(
                    onPressed: () => showLogoutConfirmationSheet(context),
                    icon: const Icon(
                      Icons.logout,
                      color: AppColors.textOnDark,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _SocketStatusIndicator extends StatelessWidget {
  const _SocketStatusIndicator();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: GetIt.instance<SocketService>().connectionStatus,
        builder: (context, connected, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: connected ? AppColors.success : AppColors.neutralGray,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              connected ? AppStrings.live : AppStrings.reconnecting,
              style: AppTextStyles.labelSmall.copyWith(
                color: connected ? AppColors.success : AppColors.neutralGray,
              ),
            ),
          ],
        ),
      );
}

class _BroadcastIndicator extends StatelessWidget {
  const _BroadcastIndicator({required this.hasLocationError});

  final bool hasLocationError;

  @override
  Widget build(BuildContext context) {
    if (hasLocationError) {
      return GestureDetector(
        onTap: () => GetIt.instance<LocationService>().openAppSettings(),
        child: Text(
          AppStrings.locationAccessNeeded,
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning),
        ),
      );
    }
    return _PulsingText(
      text: AppStrings.broadcastingLocation,
      style: AppTextStyles.labelSmall.copyWith(color: AppColors.onlineGreen),
    );
  }
}

class _PulsingText extends StatefulWidget {
  const _PulsingText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  State<_PulsingText> createState() => _PulsingTextState();
}

class _PulsingTextState extends State<_PulsingText>
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
        opacity: Tween(begin: 0.35, end: 1.0).animate(_controller),
        child: Text(widget.text, style: widget.style),
      );
}

class _OfflineOverlay extends StatelessWidget {
  const _OfflineOverlay();

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: IgnorePointer(
          child: Container(
            // Grey wash to simulate greyscale — Google Maps platform views
            // can't be wrapped in a ColorFiltered.
            color: const Color(0x80808080),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔴', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AppStrings.youAreOfflineMap,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppStrings.toggleToGoOnline,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({required this.state});

  final DashboardLoaded state;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusXl),
            topRight: Radius.circular(AppSpacing.radiusXl),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.availability,
                          style: AppTextStyles.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          state.isOnline
                              ? AppStrings.onlineSubtitle
                              : AppStrings.offlineSubtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: state.isOnline
                                ? AppColors.onlineGreen
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Orders are loaded by DashboardBloc once the backend
                  // confirms the rider is online — not here on tap.
                  _AvailabilitySwitch(
                    isOnline: state.isOnline,
                    isToggling: state.isTogglingAvailability,
                    onTap: () => context.read<DashboardBloc>().add(
                          DashboardAvailabilityToggled(
                            isOnline: !state.isOnline,
                          ),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: AppSpacing.md),
              BlocBuilder<ActiveOrdersCubit, ActiveOrdersState>(
                builder: (context, activeOrdersState) {
                  if (activeOrdersState.orders.isEmpty &&
                      !activeOrdersState.isLoading) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              AppStrings.noAssignedOrders,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          _RefreshButton(
                            onPressed: () => unawaited(
                              context.read<ActiveOrdersCubit>().loadAssignedOrders(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (activeOrdersState.isLoading && activeOrdersState.orders.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            AppStrings.checkingForOrders,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                            child: Text(
                              '🛵 ${activeOrdersState.orders.length} ${AppStrings.assignedOrders}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textOnDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          _RefreshButton(
                            onPressed: () => unawaited(
                              context.read<ActiveOrdersCubit>().loadAssignedOrders(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: activeOrdersState.orders.length,
                          itemBuilder: (context, index) => AssignedOrderCard(
                            order: activeOrdersState.orders[index],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.refresh, size: 16),
        label: const Text(AppStrings.refresh),
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      );
}

class _AvailabilitySwitch extends StatelessWidget {
  const _AvailabilitySwitch({
    required this.isOnline,
    required this.isToggling,
    required this.onTap,
  });

  final bool isOnline;
  // While the availability API call is in flight: taps are ignored and a
  // small spinner shows next to the switch.
  final bool isToggling;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isToggling) ...[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          _SwitchTrack(isOnline: isOnline, onTap: isToggling ? null : onTap),
        ],
      );
}

class _SwitchTrack extends StatelessWidget {
  const _SwitchTrack({required this.isOnline, required this.onTap});

  final bool isOnline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          height: 28,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isOnline ? AppColors.onlineGreen : AppColors.neutralGray,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: isOnline ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
}
