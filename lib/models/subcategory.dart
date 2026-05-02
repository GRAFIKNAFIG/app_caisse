class SubCategory {
  final String label;
  final double? fixedPrice;
  final bool isVariable;

  const SubCategory({
    required this.label,
    this.fixedPrice,
    this.isVariable = false,
  });
}
