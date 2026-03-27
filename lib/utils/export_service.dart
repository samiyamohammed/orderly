import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order.dart';

class ExportService {
  static Future<void> exportOrdersToPdf({
    required BuildContext context,
    required List<Order> orders,
    String title = 'My World — Orders Report',
  }) async {
    final pdf = pw.Document();
    final fmt = NumberFormat('#,##0.00');
    final dateFmt = DateFormat('MMM d, yyyy');
    final now = dateFmt.format(DateTime.now());

    final totalRevenue = orders.fold(0.0, (s, o) => s + o.amountPaid);
    final pending = orders.where((o) => o.status == 'pending').length;
    final delivered = orders.where((o) => o.status == 'delivered').length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(title,
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text('Generated: $now',
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey)),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(),
            pw.SizedBox(height: 8),
            // Summary row
            pw.Row(
              children: [
                _summaryBox('Total Orders', '${orders.length}'),
                pw.SizedBox(width: 16),
                _summaryBox('Revenue', '\$${fmt.format(totalRevenue)}'),
                pw.SizedBox(width: 16),
                _summaryBox('Pending', '$pending'),
                pw.SizedBox(width: 16),
                _summaryBox('Delivered', '$delivered'),
              ],
            ),
            pw.SizedBox(height: 16),
          ],
        ),
        build: (_) => [
          pw.TableHelper.fromTextArray(
            headers: [
              'Customer', 'Product', 'Price', 'Paid', 'Remaining', 'Status', 'Date'
            ],
            data: orders.map((o) => [
              o.customerName,
              o.product,
              '\$${fmt.format(o.price)}',
              '\$${fmt.format(o.amountPaid)}',
              '\$${fmt.format(o.remaining)}',
              o.status.toUpperCase(),
              dateFmt.format(o.createdAt),
            ]).toList(),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.indigo100),
            rowDecoration: const pw.BoxDecoration(),
            oddRowDecoration:
                const pw.BoxDecoration(color: PdfColors.grey100),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.center,
              6: pw.Alignment.center,
            },
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'my_world_orders_$now.pdf',
    );
  }

  static pw.Widget _summaryBox(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColors.indigo50,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: const pw.TextStyle(
                    fontSize: 8, color: PdfColors.grey700)),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 13, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
