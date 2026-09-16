import 'package:rsc_rider/features/delivery/domain/entities/assigned_modifier_entity.dart';

class AssignedItemEntity {
  const AssignedItemEntity({
    required this.id,
    required this.name,
    required this.quantity,
    required this.modifiers,
  });

  final String id;
  final String name;
  final int quantity;
  final List<AssignedModifierEntity> modifiers;

  String get displayName => '${quantity}x $name';

  String get modifiersSummary => modifiers.map((m) => m.name).join(', ');
}
