import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/api_service.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../helpers/suggestion_helper.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];
  List<Product> suggestions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() async {
    try {
      final res = await ApiService.fetchProducts();
      print("Product Fetch Response: ${res.statusCode}");

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        print("Product Data: $data");

        final fetched = data.map((e) => Product.fromJson(e)).toList();

        setState(() {
          products = fetched;
          suggestions = SuggestionHelper.getSuggestions(fetched, "Snacks");
          loading = false;
        });
      } else {
        print("Failed to fetch products: ${res.body}");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load products")),
        );
        setState(() => loading = false);
      }
    } catch (e) {
      print("Product fetch error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      setState(() => loading = false);
    }
  }

  void handleAddToCart(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('user_id');
    if (token == null || userId == null) return;

    await ApiService.addToCart(token, userId, product.id, 1);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${product.name} added to cart")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shopping App")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text("Suggested for You 🍪",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...suggestions
              .map((product) => ProductCard(
            product: product,
            onTap: () => handleAddToCart(product),
          ))
              .toList()
              .animate(interval: 150.ms)
              .fadeIn()
              .slideY(begin: 0.1),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text("All Products 🛒",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...products
              .map((product) => ProductCard(
            product: product,
            onTap: () => handleAddToCart(product),
          ))
              .toList()
              .animate(interval: 150.ms)
              .fadeIn()
              .slideY(begin: 0.1),
        ],
      ),
    );
  }
}
