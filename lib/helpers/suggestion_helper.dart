import '../models/product.dart';
import 'dart:developer';

class SuggestionHelper {
  static List<Product> getSuggestions(List<Product> products, String category) {
    log("🔍 Getting suggestions for category: $category");

    if (products.isEmpty) {
      log("⚠️ Product list is empty");
      return [];
    }

    final lowerCat = category.toLowerCase();
    final matching = products
        .where((p) => p.category.toLowerCase() == lowerCat)
        .toList();

    if (matching.isEmpty) {
      log("⚠️ No matching products found for category: $category");
      // Fallback: return top 3 products from the most common category
      final topCat = products.first.category;
      log("📌 Falling back to top category: $topCat");
      return products
          .where((p) => p.category == topCat)
          .take(3)
          .toList();
    }

    log("✅ Found ${matching.length} matching products, returning top 3");
    return matching.take(3).toList();
  }
}
