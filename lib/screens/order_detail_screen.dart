import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';
import 'edit_order_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final order = provider.allOrders.firstWhere((o) => o.id == orderId);
    final fmt = NumberFormat('#,##0.00');
    final dateFmt = DateFormat('MMM d, yyyy – h:mm a');
    final statusColor = AppTheme.statusColor(order.status);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                    gradient: AppTheme.statusGradient(order.status)),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FadeInDown(
                          child: Text(order.customerName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ),
                        FadeInDown(
                          delay: const Duration(milliseconds: 80),
                          child: Text(order.product,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: statusColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'Copy confirmation',
                onPressed: () => _copyConfirmation(context, order),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditOrderScreen(order: order)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: const Text('Delete Order'),
                      content: const Text('This cannot be undone.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete',
                                style: TextStyle(color: AppTheme.danger))),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await context
                        .read<OrderProvider>()
                        .deleteOrder(orderId);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order info card
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: _InfoCard(children: [
                      _InfoRow(Icons.person_rounded, 'Customer',
                          order.customerName),
                      _InfoRow(Icons.shopping_bag_rounded, 'Product',
                          order.product),
                      _InfoRow(Icons.calendar_today_rounded, 'Created',
                          dateFmt.format(order.createdAt)),
                      if (order.expectedDeliveryDate != null)
                        _InfoRow(Icons.event_rounded, 'Expected Delivery',
                            dateFmt.format(order.expectedDeliveryDate!),
                            valueColor: order.expectedDeliveryDate!
                                    .isBefore(DateTime.now()) &&
                                order.status != 'delivered'
                                ? AppTheme.danger
                                : AppTheme.success),
                      if (order.notes != null && order.notes!.isNotEmpty)
                        _InfoRow(Icons.notes_rounded, 'Notes', order.notes!),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Timeline card
                  if (order.paidAt != null ||
                      order.dispatchedAt != null ||
                      order.deliveredAt != null)
                    FadeInUp(
                      delay: const Duration(milliseconds: 60),
                      child: _InfoCard(children: [
                        if (order.paidAt != null)
                          _InfoRow(Icons.check_circle_rounded, 'Paid on',
                              dateFmt.format(order.paidAt!),
                              valueColor: AppTheme.success),
                        if (order.dispatchedAt != null)
                          _InfoRow(Icons.local_shipping_rounded,
                              'Dispatched on',
                              dateFmt.format(order.dispatchedAt!),
                              valueColor: AppTheme.info),
                        if (order.deliveredAt != null)
                          _InfoRow(Icons.done_all_rounded, 'Delivered on',
                              dateFmt.format(order.deliveredAt!),
                              valueColor: AppTheme.primary),
                      ]),
                    ),
                  if (order.paidAt != null ||
                      order.dispatchedAt != null ||
                      order.deliveredAt != null)
                    const SizedBox(height: 14),

                  // Payment card
                  FadeInUp(
                    delay: const Duration(milliseconds: 80),
                    child: _InfoCard(children: [
                      _InfoRow(Icons.attach_money_rounded, 'Total Price',
                          '\$${fmt.format(order.price)}'),
                      _InfoRow(Icons.payments_rounded, 'Amount Paid',
                          '\$${fmt.format(order.amountPaid)}',
                          valueColor: AppTheme.success),
                      _InfoRow(
                        Icons.account_balance_wallet_rounded,
                        'Remaining',
                        '\$${fmt.format(order.remaining)}',
                        valueColor:
                            order.isPaid ? AppTheme.success : AppTheme.danger,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // Status flow
                  FadeInUp(
                    delay: const Duration(milliseconds: 120),
                    child: const Text('Order Status',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  FadeInUp(
                    delay: const Duration(milliseconds: 160),
                    child: _StatusFlow(
                        currentStatus: order.status, orderId: orderId),
                  ),
                  const SizedBox(height: 20),

                  // Update payment
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _UpdatePaymentSection(
                        order: order, orderId: orderId),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _copyConfirmation(BuildContext context, Order order) {
    final fmt = NumberFormat('#,##0.00');
    final statusEmoji = {
      'pending': '⏳',
      'paid': '✅',
      'dispatched': '🚚',
      'delivered': '📦',
    }[order.status] ?? '📋';

    final message =
        'Hi ${order.customerName}! $statusEmoji\n\n'
        'Your order has been confirmed:\n'
        '• Product: ${order.product}\n'
        '• Total: \$${fmt.format(order.price)}\n'
        '• Paid: \$${fmt.format(order.amountPaid)}\n'
        '${!order.isPaid ? '• Remaining: \$${fmt.format(order.remaining)}\n' : ''}'
        '• Status: ${order.status.toUpperCase()}\n\n'
        'Thank you for your order! 🙏';

    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Confirmation message copied — paste it in chat!'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _StatusFlow extends StatelessWidget {
  final String currentStatus;
  final String orderId;

  const _StatusFlow(
      {required this.currentStatus, required this.orderId});

  static const _steps = ['pending', 'paid', 'dispatched', 'delivered'];

  @override
  Widget build(BuildContext context) {
    final currentIdx = _steps.indexOf(currentStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          // Progress bar
          Row(
            children: _steps.asMap().entries.map((e) {
              final idx = e.key;
              final step = e.value;
              final isActive = idx <= currentIdx;
              final color = AppTheme.statusColor(step);

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive
                              ? color
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    if (idx < _steps.length - 1) const SizedBox(width: 2),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Step buttons
          Row(
            children: _steps.asMap().entries.map((e) {
              final idx = e.key;
              final step = e.value;
              final isActive = idx <= currentIdx;
              final isCurrent = idx == currentIdx;
              final color = AppTheme.statusColor(step);

              return Expanded(
                child: GestureDetector(
                  onTap: () => context
                      .read<OrderProvider>()
                      .updateOrderStatus(orderId, step),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isCurrent
                          ? AppTheme.statusGradient(step)
                          : null,
                      color: isCurrent ? null : isActive
                          ? color.withOpacity(0.12)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          AppTheme.statusIcon(step),
                          color: isCurrent
                              ? Colors.white
                              : isActive
                                  ? color
                                  : Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isCurrent
                                ? Colors.white
                                : isActive
                                    ? color
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
          children: children
              .expand((w) => [w, const Divider(height: 1, thickness: 0.5)])
              .toList()
            ..removeLast()),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(this.icon, this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary.withOpacity(0.7)),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _UpdatePaymentSection extends StatefulWidget {
  final Order order;
  final String orderId;
  const _UpdatePaymentSection(
      {required this.order, required this.orderId});

  @override
  State<_UpdatePaymentSection> createState() =>
      _UpdatePaymentSectionState();
}

class _UpdatePaymentSectionState extends State<_UpdatePaymentSection> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.order.amountPaid > 0
            ? widget.order.amountPaid.toStringAsFixed(2)
            : '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Update Payment',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount Paid',
                    prefixIcon: const Icon(Icons.payments_rounded,
                        color: AppTheme.primary),
                    filled: true,
                    fillColor: AppTheme.bg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  final val = double.tryParse(_ctrl.text);
                  if (val != null) {
                    context
                        .read<OrderProvider>()
                        .updatePayment(widget.orderId, val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment updated'),
                        backgroundColor: AppTheme.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: AppTheme.primary.withOpacity(0.4),
                ),
                child: const Text('Save',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
