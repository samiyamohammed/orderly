/// Tries to extract order fields from a pasted chat message.
/// Handles common formats sellers use on Telegram/Instagram.
class ChatParser {
  static ParsedOrder parse(String text) {
    String? name;
    String? product;
    double? price;
    double? paid;

    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    // --- Label-based parsing (e.g. "Name: Ahmed", "Item: shoes", "Price: 50") ---
    for (final line in lines) {
      final lower = line.toLowerCase();

      if (name == null && _matchesLabel(lower, ['name', 'customer', 'client', 'اسم', 'العميل'])) {
        name = _extractValue(line);
      } else if (product == null && _matchesLabel(lower, ['item', 'product', 'order', 'منتج', 'طلب', 'بضاعة'])) {
        product = _extractValue(line);
      } else if (price == null && _matchesLabel(lower, ['price', 'total', 'amount', 'cost', 'سعر', 'المبلغ', 'التكلفة'])) {
        price = _extractNumber(line);
      } else if (paid == null && _matchesLabel(lower, ['paid', 'deposit', 'advance', 'مدفوع', 'عربون'])) {
        paid = _extractNumber(line);
      }
    }

    // --- Inline parsing fallback (e.g. "Ahmed - iPhone case - 15$") ---
    if (name == null || product == null || price == null) {
      _tryInlineParse(text, (n, p, pr) {
        name ??= n;
        product ??= p;
        price ??= pr;
      });
    }

    // --- Last resort: grab first number as price ---
    if (price == null) {
      price = _firstNumber(text);
    }

    return ParsedOrder(name: name, product: product, price: price, amountPaid: paid);
  }

  static bool _matchesLabel(String line, List<String> keywords) {
    return keywords.any((k) => line.startsWith(k));
  }

  static String? _extractValue(String line) {
    final idx = line.indexOf(RegExp(r'[:\-–]'));
    if (idx == -1) return null;
    final val = line.substring(idx + 1).trim();
    return val.isEmpty ? null : val;
  }

  static double? _extractNumber(String line) {
    final match = RegExp(r'[\d]+(?:[.,]\d+)?').firstMatch(line);
    if (match == null) return null;
    return double.tryParse(match.group(0)!.replaceAll(',', '.'));
  }

  static double? _firstNumber(String text) {
    final match = RegExp(r'[\d]+(?:[.,]\d+)?').firstMatch(text);
    if (match == null) return null;
    return double.tryParse(match.group(0)!.replaceAll(',', '.'));
  }

  static void _tryInlineParse(
      String text, void Function(String?, String?, double?) callback) {
    // Try separators: dash, comma, pipe, slash
    final separators = [' - ', ' – ', ' | ', ' / ', ', '];
    for (final sep in separators) {
      final parts = text.split(sep).map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
      if (parts.length >= 2) {
        String? n;
        String? p;
        double? pr;

        for (final part in parts) {
          final num = _extractNumber(part);
          if (num != null && pr == null) {
            pr = num;
          } else if (n == null && !part.contains(RegExp(r'\d'))) {
            n = part;
          } else if (p == null && !part.contains(RegExp(r'\d'))) {
            p = part;
          }
        }

        if (n != null || p != null || pr != null) {
          callback(n, p, pr);
          return;
        }
      }
    }
  }
}

class ParsedOrder {
  final String? name;
  final String? product;
  final double? price;
  final double? amountPaid;

  const ParsedOrder({this.name, this.product, this.price, this.amountPaid});

  bool get hasAnyData => name != null || product != null || price != null;
}
