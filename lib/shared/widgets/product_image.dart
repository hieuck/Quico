import 'dart:io' show File;
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String? imagePath;
  final double size;

  const ProductImage({super.key, this.imagePath, this.size = 60});

  @override
  Widget build(BuildContext context) {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(imagePath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.inventory_2, color: Colors.grey.shade400, size: size * 0.5),
    );
  }
}
