class ItemCategoryModel {
  final int categoryID;
  final String name;

  ItemCategoryModel({required this.categoryID, required this.name});

  //Empty Helper Function
  static ItemCategoryModel empty() =>
      ItemCategoryModel(categoryID: -1, name: '');

  //Factory Method to create model instance from Json map
  factory ItemCategoryModel.fromJson(Map<String, dynamic> json) {
    return ItemCategoryModel(
      categoryID: json['categoryID'] as int,
      name: json['name'] as String,
    );
  }

  // // Map the Json oriented document snapshot from firebase to User Model
  // factory ItemCategoryModel.fromSnapshot(DocumentSnapshot <Map<String,dynamic>> document){
  //   if (document.data() != null){
  //     final data = document.data()!;

  // // Map Json Record to the model
  //   return ItemCategoryModel( categoryID: data['CategoryID'] ?? -1, name: data["Name"] ?? '');
  //   } else {
  //     return ItemCategoryModel.empty();
  //   }
  // }

  //Factory Method to convert model to Json structure for data storage in firebase
  Map<String, dynamic> toJson() {
    return {'categoryID': categoryID, 'name': name};
  }
}
