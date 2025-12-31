class ItemCategoryModel {
  final int categoryID;
  final String name;
  final String iconName;

  ItemCategoryModel({
    required this.categoryID,
    required this.name,
    required this.iconName,
  });

  //Empty Helper Function
  static ItemCategoryModel empty() =>
      ItemCategoryModel(categoryID: -1, name: '', iconName: 'default_icon');

  // Helper method to get icon
  String getIconPath() {
    return 'assets/icons/$iconName.png';
  }

  // Copy with method
  ItemCategoryModel copyWith({
    int? categoryID,
    String? name,
    String? iconName,
  }) {
    return ItemCategoryModel(
      categoryID: categoryID ?? this.categoryID,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
    );
  }

  //Factory Method to create model instance from Json map
  factory ItemCategoryModel.fromJson(Map<String, dynamic> json) {
    return ItemCategoryModel(
      categoryID: json['categoryID'] as int,
      name: json['name'] as String,
      iconName: json['iconName'] as String,
    );
  }

  //Factory Method to convert model to Json structure for data storage in firebase
  Map<String, dynamic> toJson() {
    return {'categoryID': categoryID, 'name': name, 'iconName': iconName};
  }
}
