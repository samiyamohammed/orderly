import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/settings_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../utils/export_service.dart';
import '../utils/backup_service.dart';
import '../utils/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final orders = context.read<OrderProvider>().allOrders;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                  decoration: const BoxDecoration(
                      gradient: AppTheme.gradientPrimary)),
              title: const Text('Settings',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            backgroundColor: AppTheme.primary,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Currency
                FadeInUp(
                  child: _SectionLabel('Currency'),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 60),
                  child: _SettingsCard(
                    child: ListTile(
                      leading: const Icon(Icons.currency_exchange_rounded,
                          color: AppTheme.primary),
                      title: const Text('Currency',
                          style: TextStyle(color: Colors.white)),
                      subtitle: Text(
                          '${settings.currency} (${settings.currencySymbol})',
                          style: const TextStyle(color: Colors.white60)),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: Colors.white38),
                      onTap: () => _showCurrencyPicker(context, settings),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Notifications
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: _SectionLabel('Notifications'),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 140),
                  child: _SettingsCard(
                    child: SwitchListTile(
                      secondary: const Icon(Icons.notifications_rounded,
                          color: AppTheme.primary),
                      title: const Text('Daily Reminders',
                          style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Get notified at 9 AM daily',
                          style: TextStyle(color: Colors.white60)),
                      value: settings.notificationsEnabled,
                      activeColor: AppTheme.primary,
                      onChanged: (v) async {
                        await settings.setNotifications(v);
                        if (v) {
                          await NotificationService.scheduleDailyReminder();
                        } else {
                          await NotificationService.cancelAll();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Export & Backup
                FadeInUp(
                  delay: const Duration(milliseconds: 180),
                  child: _SectionLabel('Data'),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 220),
                  child: _SettingsCard(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.picture_as_pdf_rounded,
                              color: AppTheme.success),
                          title: const Text('Export to PDF',
                              style: TextStyle(color: Colors.white)),
                          subtitle: const Text(
                              'Print or save all orders as PDF',
                              style: TextStyle(color: Colors.white60)),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: Colors.white38),
                          onTap: () => ExportService.exportOrdersToPdf(
                              context: context, orders: orders),
                        ),
                        const Divider(height: 1, color: AppTheme.surfaceLight),
                        ListTile(
                          leading: const Icon(Icons.backup_rounded,
                              color: AppTheme.info),
                          title: const Text('Backup Data',
                              style: TextStyle(color: Colors.white)),
                          subtitle: const Text(
                              'Share a JSON backup of all your data',
                              style: TextStyle(color: Colors.white60)),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: Colors.white38),
                          onTap: () =>
                              BackupService.exportBackup(context),
                        ),
                        const Divider(height: 1, color: AppTheme.surfaceLight),
                        ListTile(
                          leading: const Icon(Icons.restore_rounded,
                              color: AppTheme.warning),
                          title: const Text('Restore Backup',
                              style: TextStyle(color: Colors.white)),
                          subtitle: const Text('Paste your backup JSON to restore',
                              style: TextStyle(color: Colors.white60)),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: Colors.white38),
                          onTap: () => _showRestoreDialog(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  delay: const Duration(milliseconds: 260),
                  child: Center(
                    child: Text('My World v1.0.0',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(
      BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Select Currency',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: SettingsProvider.allCurrencies.map((e) {
                final isSelected = e.key == settings.currency;
                return ListTile(
                  title: Text('${e.key} (${e.value})',
                      style: TextStyle(
                          color: isSelected
                              ? AppTheme.primary
                              : Colors.white)),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: AppTheme.primary)
                      : null,
                  onTap: () {
                    settings.setCurrency(e.key);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Restore Backup',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          maxLines: 6,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: const InputDecoration(
            hintText: 'Paste your backup JSON here...',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary),
            onPressed: () async {
              Navigator.pop(context);
              final result =
                  await BackupService.importBackup(ctrl.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(result.success
                      ? 'Restored ${result.ordersImported} orders, ${result.customersImported} customers'
                      : 'Restore failed: ${result.error}'),
                  backgroundColor:
                      result.success ? AppTheme.success : AppTheme.danger,
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            child: const Text('Restore',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text.toUpperCase(),
          style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
