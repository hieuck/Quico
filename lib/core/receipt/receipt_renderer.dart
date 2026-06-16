class ReceiptData {
  final String storeName;
  final String orderCode;
  final int createdAt;
  final String? customerName;
  final List<ReceiptItem> items;
  final int subtotal;
  final int discountAmount;
  final int totalAmount;
  final String paymentStatus;
  final String paymentMethod;
  final String? note;

  const ReceiptData({
    required this.storeName,
    required this.orderCode,
    required this.createdAt,
    this.customerName,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    this.note,
  });
}

class ReceiptItem {
  final String productName;
  final int quantity;
  final int unitPrice;
  final int lineTotal;

  const ReceiptItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });
}
