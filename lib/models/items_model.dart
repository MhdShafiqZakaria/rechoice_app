//ITEM CLASS
import 'package:rechoice_app/models/category_model.dart';

class Items {
  final int itemID;
  final String title;
  final ItemCategoryModel category;
  final String brand;
  final String condition;
  final double price;
  final int quantity;
  final String description;
  final String status;
  final String imagePath;

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
    required this.imagePath,
  });

  //Factory Method to create model instance from Json map

  factory Items.fromJson(Map<String, dynamic> json) {
    final categoryData = json['category'] as Map<String, dynamic>;

    return Items(
      itemID: json['itemID'] as int,
      title: json['title'] as String,
      category: ItemCategoryModel(
        categoryID: categoryData['categoryID'] as int,
        name: categoryData['name'] as String,
      ),
      brand: json['brand'] as String,
      condition: json['condition'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      description: json['description'] as String,
      status: json['status'] as String,
      imagePath: json['image'] as String,
    );
  }


  //Factory Method to convert model to Json structure for data storage in firebase

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
      'image': imagePath,
    };
  }

  //Getter Function
  
}
