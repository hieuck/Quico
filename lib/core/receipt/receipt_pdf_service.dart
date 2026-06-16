import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../utils/currency_formatter.dart';
import 'receipt_renderer.dart';
import '../../l10n/l10n_extension.dart';

class ReceiptPdfService {
  Future<File> generatePdf(ReceiptData receipt, String outputPath) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(child: pw.Text(receipt.storeName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 8),
            pw.Center(child: pw.Text(receipt.orderCode)),
            pw.Center(child: pw.Text(_formatDate(receipt.createdAt))),
            if (receipt.customerName != null) ...[
              pw.SizedBox(height: 8),
              pw.Text('Customer: ${receipt.customerName}'),
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
                pw.Text(context.l10n.subtotal),
                pw.Text(CurrencyFormatter.format(receipt.subtotal)),
              ],
            ),
            if (receipt.discountAmount > 0)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(context.l10n.discount),
                  pw.Text('-${CurrencyFormatter.format(receipt.discountAmount)}'),
                ],
              ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(context.l10n.total, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(CurrencyFormatter.format(receipt.totalAmount), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Text('Payment: ${_paymentStatusText(receipt.paymentStatus)}'),
            pw.Text('Method: ${_paymentMethodText(receipt.paymentMethod)}'),
            if (receipt.note != null) pw.Text('Note: ${receipt.note}'),
            pw.SizedBox(height: 16),
            pw.Center(child: pw.Text(context.l10n.receiptFooter)),
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

  String _paymentStatusText(String status) {
    switch (status) {
      case 'paid': return context.l10n.paid;
      case 'unpaid': return context.l10n.unpaid;
      case 'partial': return context.l10n.partial;
      default: return status;
    }
  }

  String _paymentMethodText(String method) {
    switch (method) {
      case 'cash': return context.l10n.cash;
      case 'bank_transfer': return context.l10n.bankTransfer;
      default: return 'Other';
    }
  }
}
