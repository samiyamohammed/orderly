import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsProvider extends ChangeNotifier {
  static const _boxName = 'settings';
  static const _currencyKey = 'currency';
  static const _notificationsKey = 'notifications_enabled';
  static const _onboardingKey = 'has_seen_onboarding';

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);

  // ─── Onboarding ──────────────────────────────────────────────────────────
  bool get hasSeenOnboarding =>
      _box.get(_onboardingKey, defaultValue: false) as bool;

  Future<void> completeOnboarding() async {
    await _box.put(_onboardingKey, true);
    notifyListeners();
  }

  // ─── Currency ─────────────────────────────────────────────────────────────
  String get currency => _box.get(_currencyKey, defaultValue: 'ETB') as String;

  String get currencySymbol => _currencies[currency] ?? '\$';

  Future<void> setCurrency(String code) async {
    await _box.put(_currencyKey, code);
    notifyListeners();
  }

  static const Map<String, String> _currencies = {
    'ETB': 'Br',  // Ethiopian Birr — first so it's at the top
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'SAR': '﷼',
    'AED': 'د.إ',
    'EGP': 'E£',
    'MAD': 'MAD',
    'TRY': '₺',
    'DZD': 'DA',
    'TND': 'DT',
    'LYD': 'LD',
    'IQD': 'IQD',
    'JOD': 'JD',
    'KWD': 'KD',
    'QAR': 'QR',
    'BHD': 'BD',
    'OMR': 'OMR',
    'NGN': '₦',
    'GHS': '₵',
    'KES': 'KSh',
    'INR': '₹',
    'PKR': '₨',
  };

  static List<MapEntry<String, String>> get allCurrencies =>
      _currencies.entries.toList();

  // ─── Notifications ────────────────────────────────────────────────────────
  bool get notificationsEnabled =>
      _box.get(_notificationsKey, defaultValue: true) as bool;

  Future<void> setNotifications(bool value) async {
    await _box.put(_notificationsKey, value);
    notifyListeners();
  }
}
