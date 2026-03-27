import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 0)
class Customer extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? phone;

  @HiveField(3)
  String? platform; // telegram, instagram, etc.

  @HiveField(4)
  late DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.platform,
    required this.createdAt,
  });
}
