import 'package:equatable/equatable.dart';

class RiderStatusEntity extends Equatable {
  const RiderStatusEntity({required this.isOnline});

  final bool isOnline;

  @override
  List<Object> get props => [isOnline];
}
