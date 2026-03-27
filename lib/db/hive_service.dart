import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';
import '../models/order.dart';

class HiveService {
  static const String ordersBox = 'orders';
  static const String customersBox = 'customers';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CustomerAdapter());
    Hive.registerAdapter(OrderAdapter());
    await Hive.openBox<Customer>(customersBox);
    await Hive.openBox<Order>(ordersBox);
  }
  static Box<Order> get orders => Hive.box<Order>(ordersBox);
  static Box<Customer> get customers => Hive.box<Customer>(customersBox);
}
