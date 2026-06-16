import 'package:flutter_test/flutter_test.dart';
import 'package:quico/features/orders/domain/order_calculation_service.dart';
import 'package:quico/features/orders/domain/order.dart';

void main() {
  late OrderCalculationService calc;

  setUp(() {
    calc = OrderCalculationService();
  });

  group('Line Total', () {
    test('calculates line total correctly', () {
      final item = CartItem(productName: 'Test', quantity: 2, unitPrice: 30000, discountAmount: 5000);
      calc.calculateCartItem(item);
      expect(item.lineTotal, 55000);
    });

    test('line total cannot be negative', () {
      final item = CartItem(productName: 'Test', quantity: 1, unitPrice: 10000, discountAmount: 20000);
      calc.calculateCartItem(item);
      expect(item.lineTotal, 0);
    });
  });

  group('Line Profit', () {
    test('calculates line profit correctly', () {
      final profit = calc.calculateLineProfit(60000, 2, 12000);
      expect(profit, 36000);
    });
  });

  group('Subtotal', () {
    test('calculates subtotal correctly', () {
      final items = [
        CartItem(productName: 'A', quantity: 2, unitPrice: 30000),
        CartItem(productName: 'B', quantity: 1, unitPrice: 35000),
      ];
      expect(calc.calculateSubtotal(items), 95000);
    });
  });

  group('Total Amount', () {
    test('calculates total with discount', () {
      expect(calc.calculateTotalAmount(95000, 5000), 90000);
    });

    test('total cannot be negative', () {
      expect(calc.calculateTotalAmount(5000, 10000), 0);
    });
  });

  group('Cost Amount', () {
    test('calculates cost amount correctly', () {
      final items = [
        CartItem(productName: 'A', quantity: 2, unitPrice: 30000, costPrice: 12000),
        CartItem(productName: 'B', quantity: 1, unitPrice: 35000, costPrice: 15000),
      ];
      expect(calc.calculateCostAmount(items), 39000);
    });
  });

  group('Gross Profit', () {
    test('calculates gross profit correctly', () {
      expect(calc.calculateGrossProfit(90000, 39000), 51000);
    });

    test('gross profit can be negative', () {
      expect(calc.calculateGrossProfit(30000, 50000), -20000);
    });
  });

  group('Can Complete Order', () {
    test('empty cart cannot complete', () {
      expect(calc.canCompleteOrder([]), false);
    });

    test('valid cart can complete', () {
      final items = [CartItem(productName: 'A', quantity: 1, unitPrice: 10000)];
      expect(calc.canCompleteOrder(items), true);
    });

    test('cart with zero quantity cannot complete', () {
      final items = [CartItem(productName: 'A', quantity: 0, unitPrice: 10000)];
      expect(calc.canCompleteOrder(items), false);
    });
  });
}
