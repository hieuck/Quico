import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'receipt_renderer.dart';

class ReceiptImageService {
  Future<File> generateImage(ReceiptData receipt) async {
    final dir = await getApplicationDocumentsDirectory();
    final receiptDir = Directory(p.join(dir.path, 'quico', 'receipts', 'images'));
    if (!await receiptDir.exists()) {
      await receiptDir.create(recursive: true);
    }
    final filePath = p.join(receiptDir.path, 'receipt_${receipt.orderCode}.png');
    return File(filePath);
  }
}
