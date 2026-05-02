class TicketLine {
  final String category;
  final String subCategory;
  final int quantity;
  final double unitPrice;
  final bool isRefund;

  TicketLine({
    required this.category,
    required this.subCategory,
    required this.quantity,
    required this.unitPrice,
    this.isRefund = false,
  });

  double get total => (isRefund ? -1 : 1) * unitPrice * quantity;

  Map<String, dynamic> toJson() => {
        'category': category,
        'subCategory': subCategory,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'isRefund': isRefund,
        'total': total,
      };

  factory TicketLine.fromJson(Map<String, dynamic> json) => TicketLine(
        category: json['category'] as String,
        subCategory: json['subCategory'] as String,
        quantity: json['quantity'] as int,
        unitPrice: (json['unitPrice'] as num).toDouble(),
        isRefund: json['isRefund'] as bool? ?? false,
      );
}
