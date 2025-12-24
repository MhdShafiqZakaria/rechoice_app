import 'category.dart';

class Items {
  final int itemID;
  final String title;
  final Category category;
  final String brand;
  final String condition;
  final double price;
  final int quantity;
  final String description;
  final String status;
  final List<String> image;

  Items({
    required this.itemID,
    required this.title,
    required this.category,
    required this.brand,
    required this.condition,
    required this.price,
    required this.quantity,
    required this.description,
    required this.status,
    required this.image,
  });

  factory Items.fromJson(Map<String, dynamic> json) {
    final categoryData = json['category'] as Map<String, dynamic>;

    return Items(
      itemID: json['itemID'] as int,
      title: json['title'] as String,
      category: Category(
        categoryID: categoryData['categoryID'] as int,
        name: categoryData['name'] as String,
      ),
      brand: json['brand'] as String,
      condition: json['condition'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      description: json['description'] as String,
      status: json['status'] as String,
      image: List<String>.from(json['image'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemID': itemID,
      'title': title,
      'category': {'categoryID': category.categoryID, 'name': category.name},
      'brand': brand,
      'condition': condition,
      'price': price,
      'quantity': quantity,
      'description': description,
      'status': status,
      'image': image,
    };
  }
}
