import 'package:flutter/material.dart';

class SubCategoryButton extends StatelessWidget {
  final String label;
  final bool selected;
  final String? priceText;
  final VoidCallback onTap;

  const SubCategoryButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.priceText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selected ? const Color(0xFF0070E0) : Colors.white,
          foregroundColor: selected ? Colors.white : Colors.black87,
          elevation: selected ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(
            color: selected
                ? const Color(0xFF0070E0)
                : const Color(0xFFE5E5EA),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (priceText != null)
                Text(
                  priceText!,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected ? Colors.white70 : Colors.black54,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
