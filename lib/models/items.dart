//ITEM CLASS
import 'package:rechoice_app/models/category.dart';

class Items {
  final int itemID;
  final String title;
  final ItemCategory category;
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
}


