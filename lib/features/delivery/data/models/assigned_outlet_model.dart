import 'package:rsc_rider/features/delivery/data/models/assigned_item_model.dart';
import 'package:rsc_rider/features/delivery/domain/entities/assigned_outlet_entity.dart';

class AssignedOutletModel {
  const AssignedOutletModel({
    required this.subOrderId,
    required this.outletId,
    required this.outletName,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupCode,
    required this.status,
    required this.items,
    this.preparationNote,
    this.rejectionReason,
  });

  factory AssignedOutletModel.fromJson(Map<String, dynamic> json) =>
      AssignedOutletModel(
        subOrderId: json['subOrderId'] as String,
        outletId: json['outletId'] as String? ?? '',
        outletName:
            json['outletName'] as String? ?? json['name'] as String? ?? '',
        pickupAddress: json['pickupAddress'] as String?,
        pickupLatitude: (json['pickupLatitude'] as num?)?.toDouble() ?? 0,
        pickupLongitude: (json['pickupLongitude'] as num?)?.toDouble() ?? 0,
        pickupCode: json['pickupCode'] as String? ?? '',
        status: json['status'] as String? ?? '',
        items: (json['items'] as List<dynamic>? ?? [])
            .whereType<Map>()
            .map(
              (item) =>
                  AssignedItemModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(),
        preparationNote: json['preparationNote'] as String?,
        rejectionReason: json['rejectionReason'] as String?,
      );

  final String subOrderId;
  final String outletId;
  final String outletName;
  final String? pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupCode;
  final String status;
  final List<AssignedItemModel> items;
  final String? preparationNote;
  final String? rejectionReason;

  AssignedOutletEntity toEntity() => AssignedOutletEntity(
    subOrderId: subOrderId,
    outletId: outletId,
    outletName: outletName,
    pickupAddress: pickupAddress,
    pickupLatitude: pickupLatitude,
    pickupLongitude: pickupLongitude,
    pickupCode: pickupCode,
    status: status,
    items: items.map((item) => item.toEntity()).toList(),
    preparationNote: preparationNote,
    rejectionReason: rejectionReason,
  );
}
