import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/models/route_result.dart';
import 'package:rsc_rider/core/services/location_service.dart';
import 'package:rsc_rider/core/utils/map_utils.dart';
import 'package:rsc_rider/core/services/routing_service.dart';
import 'package:rsc_rider/core/services/socket_service.dart';
import 'package:rsc_rider/core/widgets/app_button.dart';
import 'package:rsc_rider/core/widgets/app_snackbar.dart';
import 'package:rsc_rider/features/delivery/domain/entities/assigned_order_entity.dart';
import 'package:rsc_rider/features/delivery/domain/entities/assigned_outlet_entity.dart';
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
  GoogleMapController? _mapController;
  final LocationService _locationService = GetIt.instance<LocationService>();
  final RoutingService _routingService = GetIt.instance<RoutingService>();
  final SocketService _socketService = GetIt.instance<SocketService>();

  StreamSubscription<Position>? _positionSubscription;
  List<LatLng> _routePoints = [];
  RouteResult? _routeResult;
  LatLng? _riderPosition;

  String get _orderRoom => 'order:${widget.order.orderId}';

  LatLng get _destination =>
      LatLng(widget.order.deliveryLatitude, widget.order.deliveryLongitude);

  @override
  void initState() {
    super.initState();
    unawaited(_initRouteAndTracking());
    _socketService.subscribeToRoom(_orderRoom);
    _socketService.on('order:status_update', _onOrderStatusUpdate);
    debugPrint('[DineOut NG Rider Socket] Tracking order: ${widget.order.orderId}');
  }

  void _onOrderStatusUpdate(dynamic data) {
    try {
      final payload = data as Map<String, dynamic>;
      // The rider room delivers this same event for the rider's *other*
      // orders too — without this guard, cancelling order B would pop
      // order A's delivery screen.
      final masterOrderId =
          (payload['masterOrderId'] ?? payload['orderId']) as String?;
      if (masterOrderId != null && masterOrderId != widget.order.orderId) {
        return;
      }
      final status = (payload['status'] as String?)?.toUpperCase();

      if (status == 'CANCELLED') {
        if (mounted) {
          AppSnackbar.showError(context, AppStrings.orderCancelledAlert);
        }
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop();
        });
        debugPrint(
          '[DineOut NG Rider Socket] Active order cancelled — returning to '
          'dashboard',
        );
      } else if (status == 'DELIVERED') {
        // Should not happen mid-delivery, but handle gracefully.
        debugPrint(
          '[DineOut NG Rider Socket] Order marked delivered: '
          '${payload['masterOrderId']}',
        );
      }
    } catch (e) {
      debugPrint('[DineOut NG Rider Socket] Error handling status update: $e');
    }
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
      _fitMapToRoute();
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
    _socketService.off('order:status_update', _onOrderStatusUpdate);
    _socketService.unsubscribeFromRoom(_orderRoom);
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // The route may have resolved before the map finished creating.
    _fitMapToRoute();
  }

  // 80px padding keeps the endpoint markers fully visible.
  void _fitMapToRoute() {
    if (_routePoints.isEmpty) return;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        MapUtils.boundsFromPoints(_routePoints),
        80.0,
      ),
    );
  }

  void _centerOnRider() {
    if (_riderPosition != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(_riderPosition!));
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

  Set<Marker> _buildDeliveryMarkers() => {
        for (final outlet in widget.order.outlets)
          Marker(
            markerId: MarkerId('outlet_${outlet.outletId}'),
            position: LatLng(outlet.pickupLatitude, outlet.pickupLongitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
            infoWindow: InfoWindow(
              title: '🏪 ${outlet.outletName}',
              snippet: 'Code: ${outlet.pickupCode}',
            ),
          ),
        Marker(
          markerId: const MarkerId('destination'),
          position: _destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: '📍 Delivery',
            snippet: widget.order.deliveryAddress,
          ),
        ),
        if (_riderPosition != null)
          Marker(
            markerId: const MarkerId('rider'),
            position: _riderPosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: const InfoWindow(title: '🏍️ You'),
          ),
      };

  Widget _buildMap() => GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: _riderPosition ?? _destination,
          zoom: 13.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: true,
        onMapCreated: _onMapCreated,
        markers: _buildDeliveryMarkers(),
        polylines: {
          if (_routePoints.isNotEmpty)
            Polyline(
              polylineId: const PolylineId('route'),
              points: _routePoints,
              color: AppColors.primary,
              width: 4,
            ),
        },
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
                ConstrainedBox(
                  // Keeps the panel usable when an order has several outlets
                  // with long item lists — the map stays visible above.
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.32,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < order.outlets.length; i++) ...[
                          _OutletPickupCard(outlet: order.outlets[i]),
                          if (i < order.outlets.length - 1)
                            const Divider(
                              height: AppSpacing.sm,
                              thickness: 0.5,
                              color: AppColors.divider,
                            ),
                        ],
                      ],
                    ),
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

class _OutletPickupCard extends StatelessWidget {
  const _OutletPickupCard({required this.outlet});

  final AssignedOutletEntity outlet;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🏪', style: TextStyle(fontSize: 14)),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    outlet.outletName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _OutletStatusBadge(status: outlet.status),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  AppStrings.pickupCodeLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Large on purpose — the rider shows this to kitchen staff.
                Text(
                  outlet.pickupCode,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            if (outlet.hasPreparationNote) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📝', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      '${AppStrings.preparationNote}${outlet.preparationNote}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (outlet.items.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              for (final item in outlet.items) ...[
                Text(
                  item.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.modifiers.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: Text(
                      '+ ${item.modifiersSummary}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ],
          ],
        ),
      );
}

class _OutletStatusBadge extends StatelessWidget {
  const _OutletStatusBadge({required this.status});

  final String status;

  Color get _color {
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        return AppColors.info;
      case 'PREPARING':
        return AppColors.warning;
      case 'READY':
        return AppColors.success;
      case 'COLLECTED':
        return AppColors.navy;
      default:
        // PENDING and any unknown status.
        return AppColors.neutralGray;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          status.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textOnDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}
