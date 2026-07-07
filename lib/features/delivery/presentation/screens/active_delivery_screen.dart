import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/models/route_result.dart';
import 'package:rsc_rider/core/services/location_service.dart';
import 'package:rsc_rider/core/services/routing_service.dart';
import 'package:rsc_rider/core/widgets/app_button.dart';
import 'package:rsc_rider/features/delivery/domain/entities/assigned_order_entity.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/active_orders_cubit.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/delivery_cubit.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/delivery_state.dart';
import 'package:rsc_rider/features/delivery/presentation/widgets/delivery_code_sheet.dart';
import 'package:rsc_rider/features/delivery/presentation/widgets/delivery_success_sheet.dart';

class ActiveDeliveryScreen extends StatelessWidget {
  const ActiveDeliveryScreen({super.key, this.order});

  final AssignedOrderEntity? order;

  @override
  Widget build(BuildContext context) {
    final resolvedOrder =
        order ?? GetIt.instance<ActiveOrdersCubit>().state.activeDeliveryOrder;

    if (resolvedOrder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.activeDelivery)),
        body: const Center(child: Text(AppStrings.noAssignedOrders)),
      );
    }

    return BlocProvider(
      create: (_) => GetIt.instance<DeliveryCubit>(),
      child: _ActiveDeliveryView(order: resolvedOrder),
    );
  }
}

class _ActiveDeliveryView extends StatefulWidget {
  const _ActiveDeliveryView({required this.order});

  final AssignedOrderEntity order;

  @override
  State<_ActiveDeliveryView> createState() => _ActiveDeliveryViewState();
}

class _ActiveDeliveryViewState extends State<_ActiveDeliveryView> {
  final MapController _mapController = MapController();
  final LocationService _locationService = GetIt.instance<LocationService>();
  final RoutingService _routingService = GetIt.instance<RoutingService>();

  StreamSubscription<Position>? _positionSubscription;
  List<LatLng> _routePoints = [];
  RouteResult? _routeResult;
  LatLng? _riderPosition;

  LatLng get _destination =>
      LatLng(widget.order.deliveryLatitude, widget.order.deliveryLongitude);

  @override
  void initState() {
    super.initState();
    unawaited(_initRouteAndTracking());
  }

  Future<void> _initRouteAndTracking() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (!mounted) return;
      final riderPoint = LatLng(position.latitude, position.longitude);
      setState(() => _riderPosition = riderPoint);

      // Fetched once on open — never re-fetched on subsequent location ticks.
      final route = await _routingService.getRoute(
        position.latitude,
        position.longitude,
        widget.order.deliveryLatitude,
        widget.order.deliveryLongitude,
      );
      if (!mounted) return;
      setState(() {
        _routeResult = route;
        _routePoints = route?.points ?? [riderPoint, _destination];
      });
    } catch (_) {
      // Rider position unavailable — map still renders without a route.
    }

    _positionSubscription = _locationService.positionStream.listen((position) {
      if (!mounted) return;
      setState(() => _riderPosition = LatLng(position.latitude, position.longitude));
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _centerOnRider() {
    if (_riderPosition != null) {
      _mapController.move(_riderPosition!, _mapController.camera.zoom);
    }
  }

  Future<void> _confirmLeave() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: const Text(AppStrings.leaveDeliveryWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(AppStrings.stayOnDelivery),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(AppStrings.goBack),
          ),
        ],
      ),
    );
    if (shouldLeave == true && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) => BlocListener<DeliveryCubit, DeliveryState>(
        // Owns closing the (already-open) DeliveryCodeSheet and showing the
        // success sheet — kept in one place so only one listener ever pops
        // the Navigator for this event.
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == DeliveryStatus.completed,
        listener: (context, state) {
          final cubit = context.read<DeliveryCubit>();
          Navigator.of(context).pop();
          showModalBottomSheet<void>(
            context: context,
            isDismissible: false,
            enableDrag: false,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => DeliverySuccessSheet(
              delivery: state.completedDelivery!,
              onBackToDashboard: cubit.reset,
            ),
          );
        },
        child: Scaffold(
          body: Stack(
            children: [
              _buildMap(),
              _TopOverlayBar(
                order: widget.order,
                onBack: _confirmLeave,
                onCenter: _centerOnRider,
              ),
              _BottomDeliveryPanel(order: widget.order, routeResult: _routeResult),
            ],
          ),
        ),
      );

  Widget _buildMap() => FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _riderPosition ?? _destination,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.rsc.rsc_rider',
          ),
          if (_routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _routePoints,
                  color: AppColors.primary,
                  strokeWidth: 4.0,
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              for (final outlet in widget.order.outlets)
                Marker(
                  point: LatLng(outlet.pickupLatitude, outlet.pickupLongitude),
                  width: 72,
                  height: 58,
                  child: _PickupMarker(label: outlet.outletName),
                ),
              Marker(
                point: _destination,
                width: 44,
                height: 44,
                child: const _EmojiMarker(
                  emoji: '📍',
                  color: AppColors.error,
                  size: 44,
                ),
              ),
              if (_riderPosition != null)
                Marker(
                  point: _riderPosition!,
                  width: 44,
                  height: 44,
                  child: const _EmojiMarker(
                    emoji: '🏍️',
                    color: AppColors.navy,
                    size: 44,
                  ),
                ),
            ],
          ),
        ],
      );
}

class _EmojiMarker extends StatelessWidget {
  const _EmojiMarker({required this.emoji, required this.color, required this.size});

  final String emoji;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
      );
}

class _PickupMarker extends StatelessWidget {
  const _PickupMarker({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _EmojiMarker(emoji: '🏪', color: AppColors.primary, size: 36),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
            ),
          ),
        ],
      );
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: AppColors.navy, size: 20),
          ),
        ),
      );
}

class _TopOverlayBar extends StatelessWidget {
  const _TopOverlayBar({
    required this.order,
    required this.onBack,
    required this.onCenter,
  });

  final AssignedOrderEntity order;
  final VoidCallback onBack;
  final VoidCallback onCenter;

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
                  _CircleIconButton(icon: Icons.arrow_back, onTap: onBack),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.activeDelivery,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.textOnDark,
                          ),
                        ),
                        Text(
                          order.shortOrderId,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textOnDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CircleIconButton(
                    icon: Icons.my_location_rounded,
                    onTap: onCenter,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _BottomDeliveryPanel extends StatelessWidget {
  const _BottomDeliveryPanel({required this.order, required this.routeResult});

  final AssignedOrderEntity order;
  final RouteResult? routeResult;

  @override
  Widget build(BuildContext context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                Text(
                  AppStrings.pickupFrom,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final outlet in order.outlets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      children: [
                        const Text('🏪', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            outlet.outletName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${AppStrings.pickupCode}${outlet.pickupCode}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: AppSpacing.lg, color: AppColors.divider),
                Text(
                  AppStrings.deliverTo,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '📍 ${order.deliveryAddress}',
                  style: AppTextStyles.bodyMedium,
                ),
                if (routeResult != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '~${routeResult!.displayDistance} · ~${routeResult!.displayDuration}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: AppStrings.iVeArrived,
                  onPressed: () => showDeliveryCodeSheet(context, order: order),
                ),
              ],
            ),
          ),
        ),
      );
}
