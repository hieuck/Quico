import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expanded;
  final bool destructive;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.expanded = true,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
        : Text(label);
    final button = destructive
        ? ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: child,
          )
        : ElevatedButton(onPressed: loading ? null : onPressed, child: child);
    if (expanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
