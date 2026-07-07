import 'package:rsc_rider/features/delivery/domain/entities/assigned_modifier_entity.dart';

class AssignedModifierModel {
  const AssignedModifierModel({
    required this.id,
    required this.name,
    required this.priceDeltaMinor,
  });

  factory AssignedModifierModel.fromJson(Map<String, dynamic> json) =>
      AssignedModifierModel(
        id: json['id'] as String,
        name: json['name'] as String,
        priceDeltaMinor: (json['priceDeltaMinor'] as num).toInt(),
      );

  final String id;
  final String name;
  final int priceDeltaMinor;

  AssignedModifierEntity toEntity() => AssignedModifierEntity(
        id: id,
        name: name,
        priceDelta: priceDeltaMinor / 100,
      );
}
