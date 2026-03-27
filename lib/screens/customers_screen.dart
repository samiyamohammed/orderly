import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/customer_provider.dart';
import '../providers/order_provider.dart';
import '../models/customer.dart';
import '../theme/app_theme.dart';
import 'order_detail_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();
    final customers = _query.isEmpty
        ? provider.allCustomers
        : provider.allCustomers
            .where((c) =>
                c.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 56,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                  decoration: const BoxDecoration(
                      gradient: AppTheme.gradientPrimary)),
            ),
            title: const Text('Customers'),
            backgroundColor: AppTheme.primary,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search customers...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Colors.white54),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                color: Colors.white54),
                            onPressed: () =>
                                setState(() {
                                  _query = '';
                                  _searchCtrl.clear();
                                }),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
          ),
          customers.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: FadeIn(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline_rounded,
                              size: 56, color: Colors.grey.shade600),
                          const SizedBox(height: 8),
                          const Text('No customers yet.',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final customer = customers[index];
                        return FadeInUp(
                          delay: Duration(milliseconds: index * 50),
                          child: _CustomerCard(customer: customer),
                        );
                      },
                      childCount: customers.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  const _CustomerCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final orders = orderProvider.ordersForCustomer(customer.id);
    final fmt = NumberFormat('#,##0.00');
    final totalSpent = orders.fold(0.0, (sum, o) => sum + o.amountPaid);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppTheme.cardDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.gradientPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                customer.name[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            title: Text(customer.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: Text(
                '${orders.length} orders · \$${fmt.format(totalSpent)}',
                style: const TextStyle(fontSize: 12, color: Colors.white60)),
            iconColor: Colors.white60,
            collapsedIconColor: Colors.white60,
            children: orders.isEmpty
                ? [
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('No orders yet.',
                          style: TextStyle(color: Colors.grey)),
                    )
                  ]
                : orders
                    .map((order) => Container(
                          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      OrderDetailScreen(orderId: order.id)),
                            ),
                            child: Row(
                              children: [
                                Icon(AppTheme.statusIcon(order.status),
                                    color: AppTheme.statusColor(order.status),
                                    size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(order.product,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600)),
                                      Text('\$${fmt.format(order.price)}',
                                          style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.statusColor(order.status)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(order.status,
                                      style: TextStyle(
                                          color: AppTheme.statusColor(
                                              order.status),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
          ),
        ),
      ),
    );
  }
}
