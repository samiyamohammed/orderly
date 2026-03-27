import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db/hive_service.dart';
import 'providers/order_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';
import 'utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await SettingsProvider.init();
  await NotificationService.init();
  await NotificationService.requestPermissions();
  runApp(const OrderlyApp());
}

class OrderlyApp extends StatelessWidget {
  const OrderlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Orderly',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _RootRouter(),
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return settings.hasSeenOnboarding
        ? const HomeShell()
        : const OnboardingScreen();
  }
}
