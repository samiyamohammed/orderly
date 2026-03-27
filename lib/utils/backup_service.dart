import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../db/hive_service.dart';
import '../models/order.dart';
import '../models/customer.dart';

class BackupService {
  static Map<String, dynamic> _orderToMap(Order o) => {
        'id': o.id,
        'customerId': o.customerId,
        'customerName': o.customerName,
        'product': o.product,
        'price': o.price,
        'amountPaid': o.amountPaid,
        'status': o.status,
        'createdAt': o.createdAt.toIso8601String(),
        'notes': o.notes,
      };

  static Map<String, dynamic> _customerToMap(Customer c) => {
        'id': c.id,
        'name': c.name,
        'phone': c.phone,
        'platform': c.platform,
        'createdAt': c.createdAt.toIso8601String(),
      };

  static Future<void> exportBackup(BuildContext context) async {
    final orders = HiveService.orders.values.map(_orderToMap).toList();
    final customers = HiveService.customers.values.map(_customerToMap).toList();

    final data = jsonEncode({
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'orders': orders,
      'customers': customers,
    });

    await Share.share(data, subject: 'My World Backup');
  }

  /// Import from JSON string — merges with existing data
  static Future<ImportResult> importBackup(String jsonStr) async {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final ordersJson = data['orders'] as List<dynamic>;
      final customersJson = data['customers'] as List<dynamic>;

      int importedOrders = 0;
      int importedCustomers = 0;

      for (final c in customersJson) {
        final id = c['id'] as String;
        if (!HiveService.customers.containsKey(id)) {
          final customer = Customer(
            id: id,
            name: c['name'] as String,
            phone: c['phone'] as String?,
            platform: c['platform'] as String?,
            createdAt: DateTime.parse(c['createdAt'] as String),
          );
          await HiveService.customers.put(id, customer);
          importedCustomers++;
        }
      }

      for (final o in ordersJson) {
        final id = o['id'] as String;
        if (!HiveService.orders.containsKey(id)) {
          final order = Order(
            id: id,
            customerId: o['customerId'] as String,
            customerName: o['customerName'] as String,
            product: o['product'] as String,
            price: (o['price'] as num).toDouble(),
            amountPaid: (o['amountPaid'] as num).toDouble(),
            status: o['status'] as String,
            createdAt: DateTime.parse(o['createdAt'] as String),
            notes: o['notes'] as String?,
          );
          await HiveService.orders.put(id, order);
          importedOrders++;
        }
      }

      return ImportResult(
          success: true,
          ordersImported: importedOrders,
          customersImported: importedCustomers);
    } catch (e) {
      return ImportResult(success: false, error: e.toString());
    }
  }
}

class ImportResult {
  final bool success;
  final int ordersImported;
  final int customersImported;
  final String? error;

  const ImportResult({
    required this.success,
    this.ordersImported = 0,
    this.customersImported = 0,
    this.error,
  });
}
