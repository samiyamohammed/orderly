import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/order.dart';
import '../models/customer.dart';
import '../db/hive_service.dart';

class OrderProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  List<Order> get allOrders => HiveService.orders.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Order> get pendingOrders =>
      allOrders.where((o) => o.status != 'delivered').toList();

  List<Order> get todayOrders {
    final now = DateTime.now();
    return allOrders.where((o) =>
      o.createdAt.year == now.year &&
      o.createdAt.month == now.month &&
      o.createdAt.day == now.day).toList();
  }

  double get todayRevenue =>
      todayOrders.fold(0, (sum, o) => sum + o.amountPaid);

  double get totalRevenue =>
      allOrders.fold(0, (sum, o) => sum + o.amountPaid);

  List<Order> ordersForCustomer(String customerId) =>
      allOrders.where((o) => o.customerId == customerId).toList();

  Future<void> addOrder({
    required String customerName,
    required String product,
    required double price,
    double amountPaid = 0,
    String? notes,
    DateTime? expectedDeliveryDate,
  }) async {
    // find or create customer
    final customers = HiveService.customers;
    Customer? customer = customers.values
        .cast<Customer?>()
        .firstWhere((c) => c!.name.toLowerCase() == customerName.toLowerCase(),
            orElse: () => null);

    if (customer == null) {
      customer = Customer(
        id: _uuid.v4(),
        name: customerName,
        createdAt: DateTime.now(),
      );
      await customers.put(customer.id, customer);
    }

    final order = Order(
      id: _uuid.v4(),
      customerId: customer.id,
      customerName: customerName,
      product: product,
      price: price,
      amountPaid: amountPaid,
      status: amountPaid >= price ? 'paid' : 'pending',
      createdAt: DateTime.now(),
      notes: notes,
      expectedDeliveryDate: expectedDeliveryDate,
      paidAt: amountPaid >= price ? DateTime.now() : null,
    );

    await HiveService.orders.put(order.id, order);
    notifyListeners();
  }

  Future<void> editOrder({
    required String orderId,
    required String customerName,
    required String product,
    required double price,
    required double amountPaid,
    String? notes,
    DateTime? expectedDeliveryDate,
  }) async {
    final order = HiveService.orders.get(orderId);
    if (order == null) return;
    order.customerName = customerName;
    order.product = product;
    order.price = price;
    order.amountPaid = amountPaid;
    order.notes = notes;
    order.expectedDeliveryDate = expectedDeliveryDate;
    if (amountPaid >= price && order.paidAt == null) {
      order.status = 'paid';
      order.paidAt = DateTime.now();
    }
    await order.save();
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final order = HiveService.orders.get(orderId);
    if (order != null) {
      order.status = status;
      final now = DateTime.now();
      if (status == 'paid' && order.paidAt == null) order.paidAt = now;
      if (status == 'dispatched' && order.dispatchedAt == null) order.dispatchedAt = now;
      if (status == 'delivered' && order.deliveredAt == null) order.deliveredAt = now;
      await order.save();
      notifyListeners();
    }
  }

  Future<void> updatePayment(String orderId, double amount) async {
    final order = HiveService.orders.get(orderId);
    if (order != null) {
      order.amountPaid = amount;
      if (amount >= order.price) order.status = 'paid';
      await order.save();
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String orderId) async {
    await HiveService.orders.delete(orderId);
    notifyListeners();
  }
}
