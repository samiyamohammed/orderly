import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';

class EditOrderScreen extends StatefulWidget {
  final Order order;
  const EditOrderScreen({super.key, required this.order});

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _productCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _paidCtrl;
  late TextEditingController _notesCtrl;
  DateTime? _expectedDelivery;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.order.customerName);
    _productCtrl = TextEditingController(text: widget.order.product);
    _priceCtrl = TextEditingController(text: widget.order.price.toString());
    _paidCtrl = TextEditingController(text: widget.order.amountPaid.toString());
    _notesCtrl = TextEditingController(text: widget.order.notes ?? '');
    _expectedDelivery = widget.order.expectedDeliveryDate;
  }

  Future<void> _pickDeliveryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expectedDelivery ??
          DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
            surface: AppTheme.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expectedDelivery = picked);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _productCtrl.dispose();
    _priceCtrl.dispose();
    _paidCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final price = double.parse(_priceCtrl.text);
    final paid = double.tryParse(_paidCtrl.text) ?? 0;

    await context.read<OrderProvider>().editOrder(
          orderId: widget.order.id,
          customerName: _nameCtrl.text.trim(),
          product: _productCtrl.text.trim(),
          price: price,
          amountPaid: paid,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          expectedDeliveryDate: _expectedDelivery,
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
            decoration:
                const BoxDecoration(gradient: AppTheme.gradientPrimary)),
        title: const Text('Edit Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _Field(controller: _nameCtrl, label: 'Customer Name',
                  icon: Icons.person_rounded,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 14),
              _Field(controller: _productCtrl, label: 'Product / Item',
                  icon: Icons.shopping_bag_rounded,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 14),
              _Field(
                controller: _priceCtrl,
                label: 'Total Price',
                icon: Icons.attach_money_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _Field(
                controller: _paidCtrl,
                label: 'Amount Paid',
                icon: Icons.payments_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _Field(
                  controller: _notesCtrl,
                  label: 'Notes (optional)',
                  icon: Icons.notes_rounded,
                  maxLines: 3),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _pickDeliveryDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppTheme.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _expectedDelivery == null
                              ? 'Expected delivery date (optional)'
                              : 'Delivery: ${DateFormat('MMM d, yyyy').format(_expectedDelivery!)}',
                          style: TextStyle(
                            color: _expectedDelivery == null
                                ? Colors.white38
                                : Colors.white,
                          ),
                        ),
                      ),
                      if (_expectedDelivery != null)
                        GestureDetector(
                          onTap: () =>
                              setState(() => _expectedDelivery = null),
                          child: const Icon(Icons.clear_rounded,
                              color: Colors.white38, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientPrimary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Changes',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primary),
      ),
    );
  }
}
