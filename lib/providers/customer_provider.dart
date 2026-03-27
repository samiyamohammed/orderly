import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../db/hive_service.dart';

class CustomerProvider extends ChangeNotifier {
  List<Customer> get allCustomers => HiveService.customers.values.toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  Future<void> updateCustomer(Customer customer) async {
    await customer.save();
    notifyListeners();
  }

  Future<void> deleteCustomer(String customerId) async {
    await HiveService.customers.delete(customerId);
    notifyListeners();
  }
}
