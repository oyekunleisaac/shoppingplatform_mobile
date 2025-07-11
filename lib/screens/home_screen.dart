import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/api_service.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../helpers/suggestion_helper.dart';
import 'login_screen.dart';
import 'cart_screen.dart'; // Make sure this exists

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Product> products = [];
  List<Product> suggestions = [];
  Set<int> addedToCart = {};
  bool loading = true;
  String category = "Snacks";
  String? bannerMessage;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.forward();
    fetchProducts();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    setState(() {
      loading = true;
      bannerMessage = null;
    });
    try {
      final res = await ApiService.fetchProducts();

      if (!mounted) return;

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final fetched = data.map((e) => Product.fromJson(e)).toList();

        setState(() {
          products = fetched;
          suggestions = SuggestionHelper.getSuggestions(fetched, category);
          loading = false;
        });
      } else {
        setState(() => loading = false);
        print("Bad status or empty body: ${res.statusCode}");
      }
    } catch (e) {
      print("Exception in fetchProducts: $e");
      setState(() => loading = false);
    }
  }

  void handleAddToCart(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token')!;
    final userId = prefs.getInt('user_id')!;

    await ApiService.addToCart(token, userId, product.id, 1);

    if (!mounted) return;
    setState(() {
      addedToCart.add(product.id);
      bannerMessage = "${product.name} added to cart";
    });
  }

  void handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Shopping App 🛍️"),
          actions: [
            IconButton(
              onPressed: navigateToCart,
              icon: const Icon(Icons.shopping_cart_outlined),
              tooltip: "View Cart",
            ),
            IconButton(
              onPressed: handleLogout,
              icon: const Icon(Icons.logout),
              tooltip: "Logout",
            ),
          ],
        ),
        body: Column(
          children: [
            if (bannerMessage != null)
              MaterialBanner(
                backgroundColor: Colors.green.shade50,
                content: Text(
                  bannerMessage!,
                  style: const TextStyle(color: Colors.black87),
                ),
                actions: [
                  TextButton(
                    onPressed: () => setState(() => bannerMessage = null),
                    child: const Text("Dismiss"),
                  )
                ],
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchProducts,
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : products.isEmpty
                    ? const Center(child: Text("No products available"))
                    : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        "Suggested for You 🍪",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...suggestions.map(
                          (p) => ProductCard(
                        product: p,
                        onTap: () => handleAddToCart(p),
                        alreadyInCart: addedToCart.contains(p.id),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        "All Products 🛒",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...products.map(
                          (p) => ProductCard(
                        product: p,
                        onTap: () => handleAddToCart(p),
                        alreadyInCart: addedToCart.contains(p.id),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
