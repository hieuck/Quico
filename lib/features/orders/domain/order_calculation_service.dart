import 'order.dart';

class OrderCalculationService {
  int calculateLineTotal(int quantity, int unitPrice, int discountAmount) {
    final total = quantity * unitPrice - discountAmount;
    return total >= 0 ? total : 0;
  }

  int calculateLineProfit(int lineTotal, int quantity, int costPrice) {
    return lineTotal - (quantity * costPrice);
  }

  int calculateSubtotal(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));
  }

  int calculateTotalAmount(int subtotal, int orderDiscount) {
    final total = subtotal - orderDiscount;
    return total >= 0 ? total : 0;
  }

  int calculateCostAmount(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + (item.quantity * item.costPrice));
  }

  int calculateGrossProfit(int totalAmount, int costAmount) {
    return totalAmount - costAmount;
  }

  void calculateCartItem(CartItem item) {
    final beforeDiscount = item.quantity * item.unitPrice;
    if (item.discountAmount > beforeDiscount) {
      item.discountAmount = beforeDiscount;
    }
  }

  bool canCompleteOrder(List<CartItem> items) {
    if (items.isEmpty) return false;
    return items.every((item) => item.quantity > 0 && item.unitPrice >= 0);
  }
}
