import 'subcategory.dart';

class Category {
  final String name;
  final List<SubCategory> subCategories;

  const Category({
    required this.name,
    required this.subCategories,
  });
}
