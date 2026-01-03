import 'package:rechoice_app/models/model/items_model.dart';

class SearchArguments {
  final String? searchQuery;
  final int? categoryId;
  final String? categoryName;
  final List<Items> searchResults;

  SearchArguments({
    this.searchQuery,
    this.categoryId,
    this.categoryName,
    required this.searchResults,
  });
}
