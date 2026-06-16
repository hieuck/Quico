import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  factory StatusBadge.paymentStatus(String status) {
    switch (status) {
      case 'paid': return StatusBadge(label: context.l10n.paid, color: const Color(0xFF16A34A));
      case 'unpaid': return StatusBadge(label: context.l10n.unpaid, color: const Color(0xFFD97706));
      case 'partial': return StatusBadge(label: context.l10n.partial, color: const Color(0xFF3B82F6));
      default: return StatusBadge(label: status, color: Colors.grey);
    }
  }

  factory StatusBadge.orderStatus(String status) {
    switch (status) {
      case 'paid': return StatusBadge(label: context.l10n.paid, color: const Color(0xFF16A34A));
      case 'unpaid': return StatusBadge(label: context.l10n.unpaid, color: const Color(0xFFD97706));
      case 'draft': return StatusBadge(label: 'Draft', color: Colors.grey);
      case 'cancelled': return StatusBadge(label: 'Cancelled', color: const Color(0xFFDC2626));
      case 'refunded': return StatusBadge(label: 'Refunded', color: const Color(0xFF9333EA));
      default: return StatusBadge(label: status, color: Colors.grey);
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
