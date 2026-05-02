import 'package:flutter/material.dart';
import '../../theme/theme_premium.dart';

class CaisseCategories extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CaisseCategories({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: PremiumTheme.panelDecoration,
      padding: const EdgeInsets.all(8),
      child: ListView.separated(
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final name = categories[index];
          final isSelected = name == selectedCategory;

          return GestureDetector(
            onTap: () => onCategorySelected(name),
            child: Container(
              height: 42,
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
                name,
                style: PremiumTheme.buttonText,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }
}
