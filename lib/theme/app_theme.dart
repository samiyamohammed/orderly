import 'package:flutter/material.dart';

class AppTheme {
  // ─── Change these to retheme the entire app ───────────────────────────────
  static const primary       = Color(0xFF6C63FF);
  static const primaryDark   = Color(0xFF4B44CC);
  static const accent        = Color(0xFFFF6584);
  static const success       = Color(0xFF2ECC71);
  static const warning       = Color(0xFFF39C12);
  static const info          = Color(0xFF3498DB);
  static const danger        = Color(0xFFE74C3C);

  // Background & surface — tweak these for light/dark feel
  static const bg            = Color(0xFF13111C); // deep dark purple-black
  static const surface       = Color(0xFF1E1B2E); // card background
  static const surfaceLight  = Color(0xFF2A2640); // slightly lighter surface
  // ─────────────────────────────────────────────────────────────────────────

  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientWarm = LinearGradient(
    colors: [Color(0xFFFF6584), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSuccess = LinearGradient(
    colors: [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientWarning = LinearGradient(
    colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration gradientCardDecoration(LinearGradient gradient) =>
      BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        fontFamily: 'Roboto',
        // All app bars: transparent bg, white text, no shadow
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        // Tab bars
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
        ),
        // Bottom nav
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: primary,
          unselectedItemColor: Colors.grey.shade600,
          backgroundColor: surface,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        // Cards
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        // Input fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceLight,
          labelStyle: const TextStyle(color: Colors.white60),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          bodySmall: TextStyle(color: Colors.white60),
        ),
      );

  // ─── Status helpers ───────────────────────────────────────────────────────
  static Color statusColor(String status) {
    switch (status) {
      case 'paid':       return success;
      case 'dispatched': return info;
      case 'delivered':  return primary;
      default:           return warning;
    }
  }

  static LinearGradient statusGradient(String status) {
    switch (status) {
      case 'paid':       return gradientSuccess;
      case 'dispatched': return const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)]);
      case 'delivered':  return gradientPrimary;
      default:           return gradientWarning;
    }
  }

  static IconData statusIcon(String status) {
    switch (status) {
      case 'paid':       return Icons.check_circle_rounded;
      case 'dispatched': return Icons.local_shipping_rounded;
      case 'delivered':  return Icons.done_all_rounded;
      default:           return Icons.hourglass_empty_rounded;
    }
  }
}
