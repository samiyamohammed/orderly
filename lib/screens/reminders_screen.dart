import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/order_provider.dart';
import '../utils/reminder_engine.dart';
import '../theme/app_theme.dart';
import 'order_detail_screen.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final reminders = ReminderEngine.scan(provider.allOrders);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.gradientPrimary,
                ),
              ),
              title: const Text('Reminders',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            backgroundColor: AppTheme.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: reminders.isEmpty
                ? FadeIn(
                    child: Container(
                      margin: const EdgeInsets.all(32),
                      padding: const EdgeInsets.all(32),
                      decoration: AppTheme.cardDecoration,
                      child: const Column(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 64, color: AppTheme.success),
                          SizedBox(height: 12),
                          Text('All clear!',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('No pending reminders right now.',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInDown(
                          child: _SummaryBar(reminders: reminders),
                        ),
                        const SizedBox(height: 20),
                        ...reminders.asMap().entries.map((e) => FadeInUp(
                              delay: Duration(milliseconds: e.key * 60),
                              child: _ReminderCard(
                                reminder: e.value,
                                onTap: () => Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) =>
                                        OrderDetailScreen(
                                            orderId: e.value.order.id),
                                    transitionsBuilder:
                                        (_, anim, __, child) =>
                                            SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1, 0),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                          parent: anim,
                                          curve: Curves.easeOutCubic)),
                                      child: child,
                                    ),
                                    transitionDuration:
                                        const Duration(milliseconds: 300),
                                  ),
                                ),
                              ),
                            )),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final List<Reminder> reminders;
  const _SummaryBar({required this.reminders});

  @override
  Widget build(BuildContext context) {
    final high = reminders.where((r) => r.urgencyLevel == 3).length;
    final med = reminders.where((r) => r.urgencyLevel == 2).length;

    return Row(
      children: [
        if (high > 0)
          _Chip(label: '$high Urgent', color: AppTheme.danger),
        if (high > 0 && med > 0) const SizedBox(width: 8),
        if (med > 0)
          _Chip(label: '$med Medium', color: AppTheme.warning),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onTap;
  const _ReminderCard({required this.reminder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color =
        reminder.urgencyLevel == 3 ? AppTheme.danger : AppTheme.warning;
    final order = reminder.order;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Colored top bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.5)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _iconForType(reminder.type),
                        color: color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(reminder.title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: color)),
                          const SizedBox(height: 3),
                          Text(reminder.subtitle,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${order.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.statusColor(order.status)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(order.status,
                              style: TextStyle(
                                  color: AppTheme.statusColor(order.status),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded,
                        color: Colors.grey.shade300),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(ReminderType type) {
    switch (type) {
      case ReminderType.unpaid: return Icons.money_off_rounded;
      case ReminderType.partialPayment: return Icons.account_balance_wallet_rounded;
      case ReminderType.paidNotDispatched: return Icons.inventory_2_rounded;
      case ReminderType.dispatchedNotDelivered: return Icons.local_shipping_rounded;
      case ReminderType.longPending: return Icons.hourglass_bottom_rounded;
    }
  }
}
