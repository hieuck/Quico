import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../utils/currency_formatter.dart';
import 'receipt_renderer.dart';

class ReceiptPdfService {
  Future<File> generatePdf(
    ReceiptData receipt,
    String outputPath, {
    String subtotalLabel = 'Subtotal',
    String discountLabel = 'Discount',
    String totalLabel = 'Total',
    String paymentLabel = 'Payment',
    String methodLabel = 'Method',
    String noteLabel = 'Note',
    String footerLabel = 'Thank you!',
    String customerLabel = 'Customer',
    String paidLabel = 'Paid',
    String unpaidLabel = 'Unpaid',
    String partialLabel = 'Partial',
    String cashLabel = 'Cash',
    String bankTransferLabel = 'Bank Transfer',
    String otherLabel = 'Other',
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(child: pw.Text(receipt.storeName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 8),
            pw.Center(child: pw.Text(receipt.orderCode)),
            pw.Center(child: pw.Text(_formatDate(receipt.createdAt))),
            if (receipt.customerName != null) ...[
              pw.SizedBox(height: 8),
              pw.Text('$customerLabel: ${receipt.customerName}'),
            ],
            pw.Divider(),
            ...receipt.items.map((item) => pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(child: pw.Text('${item.productName} x${item.quantity}')),
                pw.Text(CurrencyFormatter.format(item.lineTotal)),
              ],
            )),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(subtotalLabel),
                pw.Text(CurrencyFormatter.format(receipt.subtotal)),
              ],
            ),
            if (receipt.discountAmount > 0)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(discountLabel),
                  pw.Text('-${CurrencyFormatter.format(receipt.discountAmount)}'),
                ],
              ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(totalLabel, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(CurrencyFormatter.format(receipt.totalAmount), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Text('$paymentLabel: ${_paymentStatusText(receipt.paymentStatus, paidLabel, unpaidLabel, partialLabel)}'),
            pw.Text('$methodLabel: ${_paymentMethodText(receipt.paymentMethod, cashLabel, bankTransferLabel, otherLabel)}'),
            if (receipt.note != null) pw.Text('$noteLabel: ${receipt.note}'),
            pw.SizedBox(height: 16),
            pw.Center(child: pw.Text(footerLabel)),
          ],
        ),
      ),
    );
    final file = File(outputPath);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  String _formatDate(int millis) {
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ${date.day}/${date.month}/${date.year}';
  }

  String _paymentStatusText(String status, String paid, String unpaid, String partial) {
    switch (status) {
      case 'paid': return paid;
      case 'unpaid': return unpaid;
      case 'partial': return partial;
      default: return status;
    }
  }

  String _paymentMethodText(String method, String cash, String bankTransfer, String other) {
    switch (method) {
      case 'cash': return cash;
      case 'bank_transfer': return bankTransfer;
      default: return other;
    }
  }
}
