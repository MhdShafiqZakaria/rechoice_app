class ItemCategory {
  final int categoryID;
  final String name;

  ItemCategory({required this.categoryID, required this.name});
}

List<ItemCategory> categories = [
  ItemCategory(categoryID: 0, name: 'Electronics'),
  ItemCategory(categoryID: 1, name: 'Fashion'),
  ItemCategory(categoryID: 2, name: 'Personal care'),
  ItemCategory(categoryID: 3, name: 'Book/Study'),
  ItemCategory(categoryID: 4, name: 'Home/Living'),
];
