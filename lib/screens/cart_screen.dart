import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> items = [];
  double total = 0.0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("Token not found.");
      return;
    }

    try {
      final res = await ApiService.fetchCart(token);
      final data = jsonDecode(res.body);
      print("Cart fetch response: $data");

      setState(() {
        items = data['items'] ?? [];
        total = data['total']?.toDouble() ?? 0.0;
        loading = false;
      });
    } catch (e) {
      print("Error fetching cart: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text("Qty: ${item['quantity']}"),
                  trailing: Text("\$${item['total'].toStringAsFixed(2)}"),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Total: \$${total.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
