import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  static Color paymentColor(String status) {
    switch (status) {
      case 'paid': return const Color(0xFF16A34A);
      case 'unpaid': return const Color(0xFFD97706);
      case 'partial': return const Color(0xFF3B82F6);
      default: return Colors.grey;
    }
  }

  static Color orderStatusColor(String status) {
    switch (status) {
      case 'paid': return const Color(0xFF16A34A);
      case 'unpaid': return const Color(0xFFD97706);
      case 'draft': return Colors.grey;
      case 'cancelled': return const Color(0xFFDC2626);
      case 'refunded': return const Color(0xFF9333EA);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }
}
