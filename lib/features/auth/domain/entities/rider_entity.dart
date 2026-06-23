import 'package:equatable/equatable.dart';

class RiderEntity extends Equatable {
  const RiderEntity({required this.riderId, required this.email});

  final String riderId;
  final String email;

  @override
  List<Object> get props => [riderId, email];
}
