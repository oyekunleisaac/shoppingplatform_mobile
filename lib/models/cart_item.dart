class CartItem {
  final int productId;
  final String name;
  final double price;
  final int quantity;
  final double total;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'],
      total: double.parse(json['total'].toString()),
    );
  }
}
