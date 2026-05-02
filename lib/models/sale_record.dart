import 'package:intl/intl.dart';

/// Modèle PRO d'une ligne de vente.
/// Compatible avec :
/// - recap_service
/// - stats_service
/// - excel_export_service
/// - recap_page
/// - stats_page
/// - storage_service
class SaleRecord {
  final String ticketId;
  final DateTime dateTime;
  final String category;
  final String subCategory;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final bool isRefund;
  final String paymentMethod; // CB / Espèces / Chèque / Remboursement

  SaleRecord({
    required this.ticketId,
    required this.dateTime,
    required this.category,
    required this.subCategory,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.isRefund,
    required this.paymentMethod,
  });

  /// Format AAAA-MM-JJ
  String get dateString {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  /// Format HH:mm:ss
  String get timeString {
    return DateFormat('HH:mm:ss').format(dateTime);
  }
}
