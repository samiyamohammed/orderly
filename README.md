# Orderly — Your orders, under control.

A Flutter mobile app built for Telegram and Instagram sellers who manage orders through chat. Orderly turns messy chat conversations into structured, trackable business data — fully offline, no account needed.

---

## The Problem

Small sellers on Telegram and Instagram take orders in chat, track them in their head or on paper, forget payments, miss deliveries, and have zero visibility into their business. Orderly solves that.

---

## Features

### Order Management
- Create orders manually in under 10 seconds
- Paste a message from Telegram or Instagram — Orderly auto-fills the fields
- Full order lifecycle: Pending → Paid → Dispatched → Delivered
- Track total price, amount paid, and remaining balance
- Set expected delivery dates
- Automatic date timestamps (paid on, dispatched on, delivered on)
- Edit or delete any order
- Swipe left to delete from the list

### Customer Tracking
- Customers are created automatically from orders — no manual entry
- View full order history per customer
- See total amount spent per customer
- Search customers by name

### Smart Reminders
- 6 automatic reminder scenarios:
  - Unpaid orders (2+ days old)
  - Partial payments with balance due
  - Paid but not dispatched (1+ day)
  - Dispatched but not delivered (3+ days)
  - Orders stuck in pending (7+ days)
  - Expected delivery date passed
- Urgency levels (medium / high) with color coding
- Live badge on the nav bar
- Daily push notification at 9 AM

### Dashboard
- Today's revenue at a glance
- Pending orders count
- Total revenue and order count
- Recent orders list
- Time-based greeting

### Data & Export
- Export all orders to a PDF report
- Backup all data as JSON and share it
- Restore from a backup
- Fully offline — all data stored locally with Hive

### Settings
- 22+ currencies including ETB (Ethiopian Birr), USD, EUR, SAR, AED, EGP and more
- Toggle daily notifications on/off

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| State Management | Provider |
| Local Database | Hive |
| Notifications | flutter_local_notifications |
| PDF Export | pdf + printing |
| Animations | animate_do |
| Unique IDs | uuid |

---

## Architecture

```
lib/
├── main.dart
├── models/
│   ├── order.dart
│   └── customer.dart
├── providers/
│   ├── order_provider.dart
│   ├── customer_provider.dart
│   └── settings_provider.dart
├── screens/
│   ├── onboarding_screen.dart
│   ├── home_shell.dart
│   ├── dashboard_screen.dart
│   ├── orders_screen.dart
│   ├── add_order_screen.dart
│   ├── edit_order_screen.dart
│   ├── order_detail_screen.dart
│   ├── customers_screen.dart
│   ├── reminders_screen.dart
│   └── settings_screen.dart
├── utils/
│   ├── chat_parser.dart
│   ├── reminder_engine.dart
│   ├── export_service.dart
│   ├── backup_service.dart
│   └── notification_service.dart
├── db/
│   └── hive_service.dart
└── theme/
    └── app_theme.dart
```

---

## Getting Started

### Prerequisites
- Flutter SDK 3.x
- Android Studio or VS Code
- Android device or emulator (Android 5.0+)

### Run locally

```bash
git clone https://github.com/yourusername/orderly.git
cd orderly
flutter pub get
flutter run
```

### Build release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Design

- Dark theme with deep purple-black background
- Purple gradient (`#6C63FF → #9B59B6`) as the primary brand color
- Single theme file (`app_theme.dart`) — change colors in one place to retheme the entire app
- Smooth slide and fade transitions between screens
- Animated stat cards, pulsing reminder badge, status flow indicator

---

## What I Learned Building This

- Offline-first architecture with Hive (no internet dependency)
- Provider pattern for clean state management across multiple screens
- Parsing unstructured text (chat messages) into structured data
- Scheduling local notifications with timezone support on Android
- PDF generation and file sharing on mobile
- Building a design system with a single theme file

---

## Author

Built by [Your Name] — Flutter Developer  
[LinkedIn](https://linkedin.com/in/yourprofile) · [Portfolio](https://yourportfolio.com)

---

## License

MIT
