import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rsc_rider/core/network/auth_interceptor.dart';
import 'package:rsc_rider/core/network/dio_client.dart';
import 'package:rsc_rider/core/network/error_interceptor.dart';
import 'package:rsc_rider/core/network/socket_client.dart';
import 'package:rsc_rider/core/router/route_guards.dart';
import 'package:rsc_rider/core/services/deep_link_service.dart';
import 'package:rsc_rider/core/services/location_service.dart';
import 'package:rsc_rider/core/services/notification_service.dart';
import 'package:rsc_rider/core/storage/cache_manager.dart';
import 'package:rsc_rider/core/storage/local_storage.dart';
import 'package:rsc_rider/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rsc_rider/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rsc_rider/features/auth/domain/repositories/auth_repository.dart';
import 'package:rsc_rider/features/auth/domain/usecases/login_use_case.dart';
import 'package:rsc_rider/features/auth/domain/usecases/logout_use_case.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies({bool firebaseAvailable = false}) async {
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
  // refreshDio is interceptor-free — used only by AuthInterceptor for token
  // refresh calls, preventing the auth interceptor from triggering itself.
  final refreshDio = DioClient.buildRefreshDio();
  final dioClient = DioClient(
    authInterceptor: AuthInterceptor(localStorage, refreshDio),
    errorInterceptor: ErrorInterceptor(),
  );

  getIt
    ..registerSingleton<DioClient>(dioClient)
    ..registerSingleton<SocketClient>(SocketClient(localStorage));

  // ── Services ───────────────────────────────────────────────────────────────
  // NotificationService requires Firebase — skip if flutterfire not configured.
  if (firebaseAvailable) {
    getIt.registerSingleton<NotificationService>(
      NotificationService(FirebaseMessaging.instance),
    );
  }
  getIt
    ..registerSingleton<LocationService>(LocationService())
    ..registerSingleton<DeepLinkService>(DeepLinkService());

  // ── Router auth state ──────────────────────────────────────────────────────
  // AuthNotifier reads secure storage once on init. AuthBloc calls
  // getIt<AuthNotifier>().onLogin() / onLogout() to drive route redirects.
  getIt.registerSingleton<AuthNotifier>(AuthNotifier(localStorage));

  // ── Features ───────────────────────────────────────────────────────────────
  _registerAuth();
  // _registerDashboard();
  // _registerDispatch();
  // _registerDelivery();
  // _registerHistory();
  // _registerProfile();
  // _registerNotifications();
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
