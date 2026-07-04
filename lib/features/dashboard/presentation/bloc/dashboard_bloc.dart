import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rsc_rider/features/dashboard/domain/usecases/get_dashboard_summary_use_case.dart';
import 'package:rsc_rider/features/dashboard/domain/usecases/set_availability_use_case.dart';
import 'package:rsc_rider/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:rsc_rider/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  // ignore: prefer_initializing_formals — named params need public names for DI callers.
  DashboardBloc({
    required GetDashboardSummaryUseCase getDashboardSummary,
    required SetAvailabilityUseCase setAvailability,
  })  : _getDashboardSummary = getDashboardSummary,
        _setAvailability = setAvailability,
        super(const DashboardInitial()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardRefreshRequested>(_onRefreshRequested);
    on<DashboardAvailabilityToggled>(_onAvailabilityToggled);
  }

  final GetDashboardSummaryUseCase _getDashboardSummary;
  final SetAvailabilityUseCase _setAvailability;

  Future<void> _onStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      final summary = await _getDashboardSummary();
      emit(DashboardLoaded(summary));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final summary = await _getDashboardSummary();
      emit(DashboardLoaded(summary));
    } catch (_) {
      // Keep showing existing data — the pull-to-refresh indicator just stops.
    }
  }

  Future<void> _onAvailabilityToggled(
    DashboardAvailabilityToggled event,
    Emitter<DashboardState> emit,
  ) async {
    final current = state;
    if (current is! DashboardLoaded) return;

    emit(current.copyWith(isUpdatingAvailability: true, clearError: true));
    try {
      final status = await _setAvailability(isOnline: event.isOnline);
      emit(
        current.copyWith(
          summary: current.summary.copyWith(status: status),
          isUpdatingAvailability: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        current.copyWith(
          isUpdatingAvailability: false,
          availabilityError: e.toString(),
        ),
      );
    }
  }
}
