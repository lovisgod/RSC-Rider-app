import 'package:equatable/equatable.dart';

class RiderEntity extends Equatable {
  const RiderEntity({required this.riderId, required this.role});

  final String riderId;
  final String role;

  @override
  List<Object> get props => [riderId, role];
}
