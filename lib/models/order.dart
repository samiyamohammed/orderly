import 'package:hive/hive.dart';

part 'order.g.dart';

@HiveType(typeId: 1)
class Order extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String customerId;

  @HiveField(2)
  late String customerName;

  @HiveField(3)
  late String product;

  @HiveField(4)
  late double price;

  @HiveField(5)
  late double amountPaid;

  @HiveField(6)
  late String status; // pending, paid, delivered

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  String? notes;

  @HiveField(9)
  DateTime? expectedDeliveryDate;

  @HiveField(10)
  DateTime? paidAt;

  @HiveField(11)
  DateTime? dispatchedAt;

  @HiveField(12)
  DateTime? deliveredAt;

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.product,
    required this.price,
    this.amountPaid = 0,
    this.status = 'pending',
    required this.createdAt,
    this.notes,
    this.expectedDeliveryDate,
    this.paidAt,
    this.dispatchedAt,
    this.deliveredAt,
  });

  bool get isPaid => amountPaid >= price;
  double get remaining => price - amountPaid;
  int get daysOld => DateTime.now().difference(createdAt).inDays;
  bool get isPartiallyPaid => amountPaid > 0 && amountPaid < price;
}
