import 'package:flutter_test/flutter_test.dart';
import 'package:rsc_rider/features/delivery/data/models/assigned_order_model.dart';

void main() {
  group('AssignedOrderModel', () {
    test('parses assigned-orders payload with minimal order details', () {
      final model = AssignedOrderModel.fromJson({
        'orderId': 'order-123',
        'status': 'READY',
        'deliveryCodeRequired': true,
        'outlets': [
          {
            'subOrderId': 'sub-order-123',
            'status': 'READY',
            'pickupCode': '741085',
            'items': [
              {'name': 'Chicken fritta', 'quantity': 1},
            ],
          },
        ],
      });

      final entity = model.toEntity();

      expect(entity.orderId, 'order-123');
      expect(entity.status, 'READY');
      expect(entity.deliveryCodeRequired, isTrue);
      expect(entity.outlets, hasLength(1));
      expect(entity.outlets.single.subOrderId, 'sub-order-123');
      expect(entity.outlets.single.status, 'READY');
      expect(entity.outlets.single.pickupCode, '741085');
      expect(entity.outlets.single.items, hasLength(1));
      expect(entity.outlets.single.items.single.name, 'Chicken fritta');
      expect(entity.outlets.single.items.single.quantity, 1);
    });
  });
}
