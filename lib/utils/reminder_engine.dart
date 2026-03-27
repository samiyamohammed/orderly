import '../models/order.dart';

enum ReminderType {
  unpaid,
  partialPayment,
  paidNotDispatched,
  dispatchedNotDelivered,
  longPending,
}

class Reminder {
  final Order order;
  final ReminderType type;
  final String title;
  final String subtitle;
  final int urgencyLevel; // 1=low, 2=medium, 3=high

  const Reminder({
    required this.order,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.urgencyLevel,
  });
}

class ReminderEngine {
  static List<Reminder> scan(List<Order> orders) {
    final reminders = <Reminder>[];

    for (final order in orders) {
      final days = order.daysOld;

      // 1. Unpaid for 2+ days
      if (order.status == 'pending' && order.amountPaid == 0 && days >= 2) {
        reminders.add(Reminder(
          order: order,
          type: ReminderType.unpaid,
          title: '💸 Unpaid order',
          subtitle:
              '${order.customerName} hasn\'t paid for "${order.product}" — $days days ago',
          urgencyLevel: days >= 5 ? 3 : 2,
        ));
      }

      // 2. Partial payment — balance still due
      if (order.isPartiallyPaid && order.status != 'delivered' && days >= 1) {
        reminders.add(Reminder(
          order: order,
          type: ReminderType.partialPayment,
          title: '⚠️ Partial payment',
          subtitle:
              '${order.customerName} still owes \$${order.remaining.toStringAsFixed(2)} for "${order.product}"',
          urgencyLevel: days >= 4 ? 3 : 2,
        ));
      }

      // 3. Paid but not dispatched after 1+ day
      if (order.status == 'paid' && days >= 1) {
        reminders.add(Reminder(
          order: order,
          type: ReminderType.paidNotDispatched,
          title: '📦 Ready to ship?',
          subtitle:
              '${order.customerName} paid for "${order.product}" $days day${days == 1 ? '' : 's'} ago — not dispatched yet',
          urgencyLevel: days >= 3 ? 3 : 2,
        ));
      }

      // 4. Dispatched but not delivered after 3+ days
      if (order.status == 'dispatched' && days >= 3) {
        reminders.add(Reminder(
          order: order,
          type: ReminderType.dispatchedNotDelivered,
          title: '🚚 Still in transit?',
          subtitle:
              '"${order.product}" for ${order.customerName} was dispatched $days days ago — confirm delivery',
          urgencyLevel: days >= 7 ? 3 : 2,
        ));
      }

      // 5. Order stuck in pending for 7+ days
      if (order.status == 'pending' && days >= 7) {
        reminders.add(Reminder(
          order: order,
          type: ReminderType.longPending,
          title: '🕐 Forgotten order?',
          subtitle:
              'Order for ${order.customerName} has been pending for $days days',
          urgencyLevel: 3,
        ));
      }

      // 6. Expected delivery date passed and not delivered
      if (order.expectedDeliveryDate != null &&
          order.status != 'delivered' &&
          order.expectedDeliveryDate!.isBefore(DateTime.now())) {
        final overdueDays = DateTime.now()
            .difference(order.expectedDeliveryDate!)
            .inDays;
        reminders.add(Reminder(
          order: order,
          type: ReminderType.longPending,
          title: '📅 Delivery overdue!',
          subtitle:
              '${order.customerName}\'s "${order.product}" was due ${overdueDays == 0 ? 'today' : '$overdueDays day${overdueDays == 1 ? '' : 's'} ago'}',
          urgencyLevel: 3,
        ));
      }
    }

    // Sort by urgency (high first), then by days old
    reminders.sort((a, b) {
      if (b.urgencyLevel != a.urgencyLevel) {
        return b.urgencyLevel.compareTo(a.urgencyLevel);
      }
      return b.order.daysOld.compareTo(a.order.daysOld);
    });

    return reminders;
  }
}
