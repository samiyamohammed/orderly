import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import '../utils/chat_parser.dart';
import '../theme/app_theme.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _productCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _expectedDelivery;
  bool _loading = false;

  Future<void> _pickDeliveryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
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

  Future<void> _pasteFromChat() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null || data.text == null || data.text!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clipboard is empty')),
        );
      }
      return;
    }

    final parsed = ChatParser.parse(data.text!);
    if (!parsed.hasAnyData) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Couldn't read order from clipboard. Fill manually.")),
        );
      }
      return;
    }

    setState(() {
      if (parsed.name != null) _nameCtrl.text = parsed.name!;
      if (parsed.product != null) _productCtrl.text = parsed.product!;
      if (parsed.price != null) _priceCtrl.text = parsed.price!.toString();
      if (parsed.amountPaid != null) _paidCtrl.text = parsed.amountPaid!.toString();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fields filled from clipboard. Review and save.'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    await context.read<OrderProvider>().addOrder(
          customerName: _nameCtrl.text.trim(),
          product: _productCtrl.text.trim(),
          price: double.parse(_priceCtrl.text),
          amountPaid: _paidCtrl.text.isEmpty ? 0 : double.parse(_paidCtrl.text),
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
        title: const Text('New Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Paste from chat button
              GestureDetector(
                onTap: _pasteFromChat,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.content_paste,
                          color: AppTheme.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Paste from Telegram / Instagram',
                          style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('or fill manually',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12)),
                ),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 14),
              _Field(controller: _nameCtrl, label: 'Customer Name', icon: Icons.person_rounded,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 14),
              _Field(controller: _productCtrl, label: 'Product / Item', icon: Icons.shopping_bag_rounded,
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
                label: 'Amount Paid (optional)',
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
              // Expected delivery date
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
                        : const Text('Save Order',
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
