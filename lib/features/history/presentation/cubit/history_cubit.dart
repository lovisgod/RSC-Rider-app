import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rsc_rider/features/history/domain/usecases/get_my_deliveries_usecase.dart';
import 'package:rsc_rider/features/history/presentation/cubit/history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._getMyDeliveries) : super(const HistoryState());

  final GetMyDeliveriesUsecase _getMyDeliveries;

  Future<void> loadDeliveries() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final response = await _getMyDeliveries();
      final deliveries =
          response.deliveries.map((model) => model.toEntity()).toList()
            ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
      emit(
        HistoryState(
          deliveries: deliveries,
          totalEarned: response.totalEarned,
          totalFromApi: response.total,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
