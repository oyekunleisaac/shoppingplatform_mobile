import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/api_service.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../helpers/suggestion_helper.dart';
import 'login_screen.dart';
import 'cart_screen.dart';

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

  // Color scheme
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFF64B5F6);
  static const Color darkBlue = Color(0xFF1976D2);
  static const Color accentBlue = Color(0xFFE3F2FD);
  static const Color successGreen = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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

    // Auto-dismiss banner after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => bannerMessage = null);
      }
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue.withOpacity(0.1), accentBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lightBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: darkBlue,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3);
  }

  Widget _buildSuccessBanner() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [successGreen.withOpacity(0.1), Colors.green.shade50],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: successGreen.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: successGreen.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: successGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              bannerMessage!,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => bannerMessage = null),
            icon: const Icon(
              Icons.close,
              color: Colors.green,
              size: 20,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.5);
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accentBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Loading amazing products...",
            style: TextStyle(
              color: darkBlue,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: accentBlue,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No products available",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check back later for new arrivals",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.8, 0.8));
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: darkBlue,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue, lightBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Shopping App",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: accentBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: navigateToCart,
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: "View Cart",
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: handleLogout,
                icon: Icon(Icons.logout, color: Colors.red.shade600),
                tooltip: "Logout",
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            if (bannerMessage != null) _buildSuccessBanner(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchProducts,
                color: primaryBlue,
                backgroundColor: Colors.white,
                child: loading
                    ? _buildLoadingIndicator()
                    : products.isEmpty
                    ? _buildEmptyState()
                    : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 8),
                    _buildSectionHeader("Suggested for You", Icons.recommend),
                    ...suggestions.asMap().entries.map(
                          (entry) => Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ProductCard(
                          product: entry.value,
                          onTap: () => handleAddToCart(entry.value),
                          alreadyInCart: addedToCart.contains(entry.value.id),
                        ),
                      ).animate(delay: (entry.key * 100).ms)
                          .fadeIn(duration: 600.ms)
                          .slideX(begin: 0.3),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader("All Products", Icons.inventory),
                    ...products.asMap().entries.map(
                          (entry) => Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ProductCard(
                          product: entry.value,
                          onTap: () => handleAddToCart(entry.value),
                          alreadyInCart: addedToCart.contains(entry.value.id),
                        ),
                      ).animate(delay: (entry.key * 50).ms)
                          .fadeIn(duration: 600.ms)
                          .slideX(begin: 0.3),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}