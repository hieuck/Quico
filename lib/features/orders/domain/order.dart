class Order {
  final String id;
  final String storeId;
  final String? customerId;
  final String orderCode;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final int subtotal;
  final int discountAmount;
  final int totalAmount;
  final int costAmount;
  final int grossProfit;
  final int paidAmount;
  final String? note;
  final String source;
  final String? originalInput;
  final int createdAt;
  final int updatedAt;
  final int? completedAt;
  final int? cancelledAt;

  const Order({
    required this.id,
    required this.storeId,
    required this.orderCode,
    required this.status,
    required this.paymentStatus,
    required this.subtotal,
    required this.discountAmount,
    required this.totalAmount,
    required this.costAmount,
    required this.grossProfit,
    required this.paidAmount,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.customerId,
    this.paymentMethod,
    this.note,
    this.originalInput,
    this.completedAt,
    this.cancelledAt,
  });
}

class OrderItem {
  final String id;
  final String orderId;
  final String? productId;
  final String productName;
  final int quantity;
  final int unitPrice;
  final int costPrice;
  final int discountAmount;
  final int lineTotal;
  final int lineProfit;
  final String? note;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.costPrice,
    required this.discountAmount,
    required this.lineTotal,
    required this.lineProfit,
    this.productId,
    this.note,
  });
}

class OrderWithItems {
  final Order order;
  final List<OrderItem> items;

  const OrderWithItems({required this.order, required this.items});
}

class CartItem {
  final String? productId;
  String productName;
  int quantity;
  int unitPrice;
  int costPrice;
  int discountAmount;
  String? note;

  CartItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.productId,
    this.costPrice = 0,
    this.discountAmount = 0,
    this.note,
  });

  int get lineTotal => (quantity * unitPrice) - discountAmount;
  int get lineProfit => lineTotal - (quantity * costPrice);
}

class CreateOrderDraftInput {
  final String storeId;
  final String? customerId;
  final List<CartItem> items;
  final int discountAmount;
  final String? note;

  const CreateOrderDraftInput({
    required this.storeId,
    required this.items,
    this.customerId,
    this.discountAmount = 0,
    this.note,
  });
}

class CompleteOrderInput {
  final String storeId;
  final String? customerId;
  final List<CartItem> items;
  final int discountAmount;
  final String paymentStatus;
  final String? paymentMethod;
  final int paidAmount;
  final String source;
  final String? originalInput;
  final String? note;

  const CompleteOrderInput({
    required this.storeId,
    required this.items,
    required this.paymentStatus,
    required this.paidAmount,
    required this.source,
    this.customerId,
    this.discountAmount = 0,
    this.paymentMethod,
    this.originalInput,
    this.note,
  });
}

class OrderFilter {
  final String? status;
  final String? paymentStatus;
  final String? search;
  final int? limit;
  final int? offset;

  const OrderFilter({
    this.status,
    this.paymentStatus,
    this.search,
    this.limit,
    this.offset,
  });
}
