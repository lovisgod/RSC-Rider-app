import 'package:cookie_jar/cookie_jar.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rsc_rider/core/network/dio_client.dart';
import 'package:rsc_rider/core/network/error_interceptor.dart';
import 'package:rsc_rider/core/network/socket_client.dart';
import 'package:rsc_rider/core/router/route_guards.dart';
import 'package:rsc_rider/core/services/deep_link_service.dart';
import 'package:rsc_rider/core/services/location_broadcasting_service.dart';
import 'package:rsc_rider/core/services/location_service.dart';
// import 'package:rsc_rider/core/services/notification_service.dart';
import 'package:rsc_rider/core/services/routing_service.dart';
import 'package:rsc_rider/core/storage/cache_manager.dart';
import 'package:rsc_rider/core/storage/local_storage.dart';
import 'package:rsc_rider/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rsc_rider/features/auth/data/repositories/auth_repository_impl.dart';
// MockAuthRepository kept as a fallback — see _registerAuth below.
// import 'package:rsc_rider/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:rsc_rider/features/auth/domain/repositories/auth_repository.dart';
import 'package:rsc_rider/features/auth/domain/usecases/login_use_case.dart';
import 'package:rsc_rider/features/auth/domain/usecases/logout_use_case.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_bloc.dart';
// Real dashboard data layer — unused while the dashboard runs on mock data.
// import 'package:rsc_rider/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
// import 'package:rsc_rider/features/dashboard/data/repositories/dashboard_repository_impl.dart';
// import 'package:rsc_rider/features/dashboard/domain/repositories/dashboard_repository.dart';
// import 'package:rsc_rider/features/dashboard/domain/usecases/get_dashboard_summary_use_case.dart';
// import 'package:rsc_rider/features/dashboard/domain/usecases/set_availability_use_case.dart';
import 'package:rsc_rider/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:rsc_rider/features/delivery/data/repositories/delivery_repository_impl.dart';
import 'package:rsc_rider/features/delivery/data/repositories/rider_location_repository_impl.dart';
import 'package:rsc_rider/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:rsc_rider/features/delivery/domain/repositories/rider_location_repository.dart';
import 'package:rsc_rider/features/delivery/domain/usecases/complete_delivery_usecase.dart';
import 'package:rsc_rider/features/delivery/domain/usecases/get_assigned_orders_usecase.dart';
import 'package:rsc_rider/features/delivery/domain/usecases/record_rider_location_usecase.dart';
import 'package:rsc_rider/features/delivery/domain/usecases/reject_order_usecase.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/active_orders_cubit.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/delivery_cubit.dart';
import 'package:rsc_rider/features/history/data/repositories/delivery_history_repository_impl.dart';
import 'package:rsc_rider/features/history/domain/repositories/delivery_history_repository.dart';
import 'package:rsc_rider/features/history/domain/usecases/get_my_deliveries_usecase.dart';
import 'package:rsc_rider/features/history/presentation/cubit/history_cubit.dart';
import 'package:rsc_rider/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:rsc_rider/features/notifications/domain/repositories/notification_repository.dart';
import 'package:rsc_rider/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:rsc_rider/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:rsc_rider/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:rsc_rider/features/profile/data/repositories/rider_profile_repository_impl.dart';
import 'package:rsc_rider/features/profile/domain/repositories/rider_profile_repository.dart';
import 'package:rsc_rider/features/profile/domain/usecases/change_rider_password_usecase.dart';
import 'package:rsc_rider/features/profile/domain/usecases/get_rider_profile_usecase.dart';
import 'package:rsc_rider/features/profile/domain/usecases/update_rider_profile_usecase.dart';
import 'package:rsc_rider/features/profile/domain/usecases/upload_rider_avatar_usecase.dart';
import 'package:rsc_rider/features/profile/presentation/cubit/profile_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies({
  required CookieJar cookieJar,
  bool firebaseAvailable = false,
}) async {
  // ── Storage ────────────────────────────────────────────────────────────────
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  const localStorage = LocalStorage(secureStorage);
  final prefs = await SharedPreferences.getInstance();

  getIt
    ..registerSingleton<LocalStorage>(localStorage)
    ..registerSingleton<AppCacheManager>(AppCacheManager(prefs));

  // ── Network ────────────────────────────────────────────────────────────────
  // PersistCookieJar (created in main.dart, backed by a file on disk) so the
  // rider's session cookie survives an app restart, not just a single run.
  getIt.registerSingleton<CookieJar>(cookieJar);

  final dioClient = DioClient(
    errorInterceptor: ErrorInterceptor(),
    cookieJar: getIt<CookieJar>(),
  );

  getIt
    ..registerSingleton<DioClient>(dioClient)
    ..registerSingleton<SocketClient>(SocketClient(localStorage));

  // ── Services ───────────────────────────────────────────────────────────────
  // NotificationService requires Firebase — disabled for now, commented out.
  // if (firebaseAvailable) {
  //   getIt.registerSingleton<NotificationService>(
  //     NotificationService(FirebaseMessaging.instance),
  //   );
  // }
  getIt
    ..registerSingleton<LocationService>(LocationService())
    ..registerSingleton<DeepLinkService>(DeepLinkService())
    ..registerSingleton<RoutingService>(RoutingService());

  getIt
    ..registerLazySingleton<RiderLocationRepository>(
      () => RiderLocationRepositoryImpl(getIt<DioClient>()),
    )
    ..registerLazySingleton<RecordRiderLocationUsecase>(
      () => RecordRiderLocationUsecase(getIt<RiderLocationRepository>()),
    )
    ..registerLazySingleton<LocationBroadcastingService>(
      () => LocationBroadcastingService(
        getIt<RecordRiderLocationUsecase>(),
        getIt<LocationService>(),
      ),
    );

  // ── Router auth state ──────────────────────────────────────────────────────
  // AuthNotifier reads secure storage once on init. AuthBloc calls
  // getIt<AuthNotifier>().onLogin() / onLogout() to drive route redirects.
  getIt.registerSingleton<AuthNotifier>(AuthNotifier(localStorage));

  // ── Features ───────────────────────────────────────────────────────────────
  _registerAuth();
  _registerDashboard();
  _registerHistory();
  _registerProfile();
  _registerDelivery();
  _registerNotifications();
  // _registerDispatch();
}

void _registerAuth() {
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(getIt<DioClient>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        getIt<AuthRemoteDataSource>(),
        getIt<LocalStorage>(),
      ),
    )
    ..registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(getIt<AuthRepository>()),
    )
    ..registerFactory<AuthBloc>(
      () => AuthBloc(
        loginUseCase: getIt<LoginUseCase>(),
        logoutUseCase: getIt<LogoutUseCase>(),
      ),
    );
}

void _registerDashboard() {
  // Mock for now — swap back to the real repository/usecases above once the
  // dashboard summary endpoint is confirmed. The rider's name comes from the
  // real GET /users/me profile endpoint, registered in _registerProfile().
  getIt.registerFactory<DashboardBloc>(
    () => DashboardBloc(
      localStorage: getIt<LocalStorage>(),
      locationService: getIt<LocationService>(),
      locationBroadcastingService: getIt<LocationBroadcastingService>(),
      getRiderProfile: getIt<GetRiderProfileUsecase>(),
    ),
  );
}

void _registerHistory() {
  getIt
    ..registerLazySingleton<DeliveryHistoryRepository>(
      () => DeliveryHistoryRepositoryImpl(getIt<DioClient>()),
    )
    ..registerLazySingleton<GetMyDeliveriesUsecase>(
      () => GetMyDeliveriesUsecase(getIt<DeliveryHistoryRepository>()),
    )
    // Singleton (not factory) — CompleteDeliveryScreen lives on a separate
    // top-level route outside the shell, so it can't reach the History tab's
    // Cubit via BuildContext. It refreshes this shared instance directly via
    // GetIt after a successful delivery completion.
    ..registerLazySingleton<HistoryCubit>(
      () => HistoryCubit(getIt<GetMyDeliveriesUsecase>()),
    );
}

void _registerProfile() {
  getIt
    ..registerLazySingleton<RiderProfileRepository>(
      () => RiderProfileRepositoryImpl(getIt<DioClient>()),
    )
    ..registerLazySingleton<GetRiderProfileUsecase>(
      () => GetRiderProfileUsecase(getIt<RiderProfileRepository>()),
    )
    ..registerLazySingleton<UpdateRiderProfileUsecase>(
      () => UpdateRiderProfileUsecase(getIt<RiderProfileRepository>()),
    )
    ..registerLazySingleton<UploadRiderAvatarUsecase>(
      () => UploadRiderAvatarUsecase(getIt<RiderProfileRepository>()),
    )
    ..registerLazySingleton<ChangeRiderPasswordUsecase>(
      () => ChangeRiderPasswordUsecase(getIt<RiderProfileRepository>()),
    )
    ..registerFactory<ProfileCubit>(
      () => ProfileCubit(
        getProfile: getIt<GetRiderProfileUsecase>(),
        updateProfile: getIt<UpdateRiderProfileUsecase>(),
        uploadAvatar: getIt<UploadRiderAvatarUsecase>(),
        changePassword: getIt<ChangeRiderPasswordUsecase>(),
      ),
    );
}

void _registerDelivery() {
  getIt
    ..registerLazySingleton<DeliveryRepository>(
      () => DeliveryRepositoryImpl(getIt<DioClient>()),
    )
    ..registerLazySingleton<CompleteDeliveryUsecase>(
      () => CompleteDeliveryUsecase(getIt<DeliveryRepository>()),
    )
    ..registerLazySingleton<GetAssignedOrdersUsecase>(
      () => GetAssignedOrdersUsecase(getIt<DeliveryRepository>()),
    )
    ..registerLazySingleton<RejectOrderUsecase>(
      () => RejectOrderUsecase(getIt<DeliveryRepository>()),
    )
    // Singleton — polling and the active delivery must survive navigation
    // away from the dashboard (e.g. onto ActiveDeliveryScreen).
    ..registerLazySingleton<ActiveOrdersCubit>(
      () => ActiveOrdersCubit(
        getIt<GetAssignedOrdersUsecase>(),
        getIt<RejectOrderUsecase>(),
        getIt<LocationBroadcastingService>(),
      ),
    )
    ..registerFactory<DeliveryCubit>(
      () => DeliveryCubit(
        completeDelivery: getIt<CompleteDeliveryUsecase>(),
        locationBroadcastingService: getIt<LocationBroadcastingService>(),
        activeOrdersCubit: getIt<ActiveOrdersCubit>(),
      ),
    );
}

void _registerNotifications() {
  getIt
    ..registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(getIt<DioClient>()),
    )
    ..registerLazySingleton<GetNotificationsUsecase>(
      () => GetNotificationsUsecase(getIt<NotificationRepository>()),
    )
    ..registerLazySingleton<MarkNotificationReadUsecase>(
      () => MarkNotificationReadUsecase(getIt<NotificationRepository>()),
    )
    // Singleton — the unread badge on the bottom nav (built in app_router.dart,
    // outside any single screen's widget tree) reads this same instance via
    // GetIt, and AuthBloc kicks off the initial load right after login.
    ..registerLazySingleton<NotificationsCubit>(
      () => NotificationsCubit(
        getNotifications: getIt<GetNotificationsUsecase>(),
        markNotificationRead: getIt<MarkNotificationReadUsecase>(),
      ),
    );
}
