import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://shoppingapp-interview.enclinks.com/api";

  static Future<http.Response> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");
    final res = await http.post(url, body: {
      "email": email,
      "password": password,
    });
    print("Login status: ${res.statusCode}");
    print("Login response: ${res.body}");
    return res;
  }

  static Future<http.Response> register(String name, String email, String password) async {
    final url = Uri.parse("$baseUrl/register");
    try {
      final res = await http.post(url, body: {
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": password,
      });
      print("Register status: ${res.statusCode}");
      print("Register response: ${res.body}");
      return res;
    } catch (e) {
      print("Error registering user: $e");
      rethrow;
    }
  }

  static Future<http.Response> fetchProducts() async {
    final url = Uri.parse("$baseUrl/products");
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Token not found in local storage.");
      }

      final res = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("Products fetch status: ${res.statusCode}");
      print("Products fetch response: ${res.body}");
      return res;
    } catch (e) {
      print("Error fetching products: $e");
      rethrow;
    }
  }

  static Future<http.Response> addToCart(String token, int userId, int productId, int qty) async {
    final url = Uri.parse("$baseUrl/cart");
    try {
      final res = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {
          "user_id": userId.toString(),
          "product_id": productId.toString(),
          "quantity": qty.toString(),
        },
      );
      print("Add to cart status: ${res.statusCode}");
      print("Add to cart response: ${res.body}");
      return res;
    } catch (e) {
      print("Error adding to cart: $e");
      rethrow;
    }
  }

  static Future<http.Response> fetchCart(String token) async {
    final url = Uri.parse("$baseUrl/cart");
    try {
      final res = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
      print("Fetch cart status: ${res.statusCode}");
      print("Fetch cart response: ${res.body}");
      return res;
    } catch (e) {
      print("Error fetching cart: $e");
      rethrow;
    }
  }

  static Future<http.Response> checkout(String token) async {
    final url = Uri.parse("$baseUrl/checkout");
    try {
      final res = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
      print("Checkout status: ${res.statusCode}");
      print("Checkout response: ${res.body}");
      return res;
    } catch (e) {
      print("Error during checkout: $e");
      rethrow;
    }
  }
}
