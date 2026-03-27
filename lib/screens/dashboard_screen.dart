import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../utils/reminder_engine.dart';
import '../models/order.dart';
import 'order_detail_screen.dart';
import 'reminders_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final fmt = NumberFormat('#,##0.00');
    final reminders = ReminderEngine.scan(provider.allOrders);
    final highUrgency = reminders.where((r) => r.urgencyLevel == 3).length;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          // Animated gradient app bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.gradientPrimary),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FadeInDown(
                          duration: const Duration(milliseconds: 500),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting(),
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 14),
                                  ),
                                  const Text(
                                    'Orderly',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              if (reminders.isNotEmpty)
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      _slideRoute(const RemindersScreen())),
                                  child: ScaleTransition(
                                    scale: _pulseAnim,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: highUrgency > 0
                                            ? AppTheme.danger
                                            : AppTheme.warning,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (highUrgency > 0
                                                    ? AppTheme.danger
                                                    : AppTheme.warning)
                                                .withOpacity(0.5),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          )
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.notifications_active,
                                              color: Colors.white, size: 16),
                                          const SizedBox(width: 4),
                                          Text('${reminders.length}',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: Text(
                            '\$${fmt.format(provider.todayRevenue)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        FadeInUp(
                          delay: const Duration(milliseconds: 100),
                          child: const Text("Today's revenue",
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: AppTheme.primary,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stat cards row
                  FadeInLeft(
                    duration: const Duration(milliseconds: 500),
                    child: Row(
                      children: [
                        _AnimatedStatCard(
                          label: 'Pending',
                          value: '${provider.pendingOrders.length}',
                          gradient: AppTheme.gradientWarning,
                          icon: Icons.pending_actions_rounded,
                          delay: 0,
                        ),
                        const SizedBox(width: 12),
                        _AnimatedStatCard(
                          label: 'Total Orders',
                          value: '${provider.allOrders.length}',
                          gradient: AppTheme.gradientPrimary,
                          icon: Icons.list_alt_rounded,
                          delay: 100,
                        ),
                        const SizedBox(width: 12),
                        _AnimatedStatCard(
                          label: 'Revenue',
                          value: '\$${NumberFormat('#,##0').format(provider.totalRevenue)}',
                          gradient: AppTheme.gradientSuccess,
                          icon: Icons.attach_money_rounded,
                          delay: 200,
                        ),
                      ],
                    ),
                  ),

                  // Reminders preview
                  if (reminders.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      child: _SectionHeader(
                        title: 'Reminders',
                        badge: '${reminders.length}',
                        badgeColor: highUrgency > 0
                            ? AppTheme.danger
                            : AppTheme.warning,
                        onTap: () => Navigator.push(
                            context,
                            _slideRoute(const RemindersScreen())),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...reminders.take(2).toList().asMap().entries.map((e) =>
                        FadeInUp(
                          delay: Duration(milliseconds: e.key * 80),
                          child: _ReminderPreviewTile(reminder: e.value),
                        )),
                    if (reminders.length > 2)
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context, _slideRoute(const RemindersScreen())),
                          child: Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'See all ${reminders.length} reminders →',
                              style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                  ],

                  // Recent orders
                  const SizedBox(height: 24),
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: const _SectionHeader(title: 'Recent Orders'),
                  ),
                  const SizedBox(height: 10),
                  if (provider.allOrders.isEmpty)
                    FadeIn(
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: AppTheme.cardDecoration,
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(Icons.inbox_rounded,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('No orders yet',
                                  style: TextStyle(color: Colors.grey)),
                              Text('Tap + in Orders to add one',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...provider.allOrders.take(8).toList().asMap().entries.map(
                          (e) => FadeInUp(
                            delay: Duration(milliseconds: e.key * 60),
                            child: _OrderTile(
                              order: e.value,
                              fmt: fmt,
                              onTap: () => Navigator.push(
                                context,
                                _slideRoute(
                                    OrderDetailScreen(orderId: e.value.id)),
                              ),
                            ),
                          ),
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

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 👋';
    if (h < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }
}

PageRouteBuilder _slideRoute(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback? onTap;

  const _SectionHeader(
      {required this.title, this.badge, this.badgeColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold)),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor ?? AppTheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badge!,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
        ],
        const Spacer(),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: const Text('See all',
                style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

class _AnimatedStatCard extends StatelessWidget {
  final String label;
  final String value;
  final LinearGradient gradient;
  final IconData icon;
  final int delay;

  const _AnimatedStatCard({
    required this.label,
    required this.value,
    required this.gradient,
    required this.icon,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FadeInUp(
        delay: Duration(milliseconds: delay),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: AppTheme.gradientCardDecoration(gradient),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderPreviewTile extends StatelessWidget {
  final dynamic reminder;
  const _ReminderPreviewTile({required this.reminder});

  @override
  Widget build(BuildContext context) {
    final color = reminder.urgencyLevel == 3 ? AppTheme.danger : AppTheme.warning;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reminder.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: color)),
                Text(reminder.subtitle,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Order order;
  final NumberFormat fmt;
  final VoidCallback onTap;

  const _OrderTile(
      {required this.order, required this.fmt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusColor(order.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: AppTheme.statusGradient(order.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(AppTheme.statusIcon(order.status),
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.customerName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(order.product,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${fmt.format(order.price)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(order.status,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
