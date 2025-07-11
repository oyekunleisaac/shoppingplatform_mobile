class Product {
  final int id;
  final String name;
  final String image;
  final double price;
  final String category;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.category,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      category: json['category'],
      imageUrl: json['image_url'],
    );
  }
}
