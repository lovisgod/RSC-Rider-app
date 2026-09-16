import 'package:rsc_rider/features/delivery/data/models/assigned_modifier_model.dart';
import 'package:rsc_rider/features/delivery/domain/entities/assigned_item_entity.dart';

class AssignedItemModel {
  const AssignedItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.modifiers,
  });

  factory AssignedItemModel.fromJson(Map<String, dynamic> json) =>
      AssignedItemModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        modifiers: (json['modifiers'] as List<dynamic>? ?? [])
            .whereType<Map>()
            .map(
              (m) =>
                  AssignedModifierModel.fromJson(Map<String, dynamic>.from(m)),
            )
            .toList(),
      );

  final String id;
  final String name;
  final int quantity;
  final List<AssignedModifierModel> modifiers;

  AssignedItemEntity toEntity() => AssignedItemEntity(
    id: id,
    name: name,
    quantity: quantity,
    modifiers: modifiers.map((m) => m.toEntity()).toList(),
  );
}
