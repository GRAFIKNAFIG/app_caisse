import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/subcategory.dart';
import '../../theme/theme_premium.dart';

class CaisseSubCategories extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategory;
  final SubCategory? selectedSubCategory;
  final ValueChanged<SubCategory> onSubCategorySelected;
  final bool hide;

  const CaisseSubCategories({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.selectedSubCategory,
    required this.onSubCategorySelected,
    required this.hide,
  });

  @override
  Widget build(BuildContext context) {
    if (hide) {
      return Container(
        decoration: PremiumTheme.panelDecoration,
        alignment: Alignment.center,
        child: const Text(''),
      );
    }

    final category = categories.firstWhere(
      (c) => c.name == selectedCategory,
      orElse: () => Category(name: '', subCategories: const []),
    );

    if (category.name.isEmpty) {
      return Container(
        decoration: PremiumTheme.panelDecoration,
        alignment: Alignment.center,
        child: Text(
          'Sélectionnez une catégorie',
          style: PremiumTheme.label,
        ),
      );
    }

    return Container(
      decoration: PremiumTheme.panelDecoration,
      padding: const EdgeInsets.all(8),
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 3.2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: category.subCategories.map((sub) {
          final isSelected = sub == selectedSubCategory;

          return GestureDetector(
            onTap: () => onSubCategorySelected(sub),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? PremiumTheme.panelSelected
                    : PremiumTheme.panelBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black26,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                sub.label,
                style: PremiumTheme.buttonText,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
