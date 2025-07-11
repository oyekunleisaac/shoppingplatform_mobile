import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool alreadyInCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.alreadyInCart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            product.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
          ),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${product.category} · \$${product.price.toStringAsFixed(2)}"),
        trailing: alreadyInCart
            ? const Icon(Icons.check_circle, color: Colors.grey)
            : IconButton(
          icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.green),
          onPressed: onTap,
        ),
      ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.2),
    );
  }
}
