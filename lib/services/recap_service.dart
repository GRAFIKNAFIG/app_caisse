import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/sale_record.dart';

/// Service PRO pour charger les ventes entre deux dates.
/// Compatible export Excel + stats + récap période.
class RecapService {
  static final RecapService instance = RecapService._internal();
  RecapService._internal();

  /// Récupère le fichier ventes.csv
  Future<File> _getCsvFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final ventesDir = Directory(p.join(dir.path, 'ventes'));

    if (!await ventesDir.exists()) {
      await ventesDir.create(recursive: true);
    }

    return File(p.join(ventesDir.path, 'ventes.csv'));
  }

  /// Charge toutes les ventes entre deux dates
  Future<List<SaleRecord>> loadSalesBetween(
      DateTime startDate, DateTime endDate) async {
    final file = await _getCsvFile();

    if (!await file.exists()) return [];

    final content = await file.readAsString();
    final rows = const CsvToListConverter().convert(content);

    if (rows.length <= 1) return [];

    final List<SaleRecord> sales = [];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];

      final dateStr = row[1];
      final timeStr = row[2];

      final dt = DateFormat('yyyy-MM-dd HH:mm:ss').parse("$dateStr $timeStr");

      // Filtrage période
      if (dt.isBefore(startDate) || dt.isAfter(endDate)) {
        continue;
      }

      sales.add(
        SaleRecord(
          ticketId: row[0].toString(),
          dateTime: dt,
          category: row[3],
          subCategory: row[4],
          quantity: int.parse(row[5].toString()),
          unitPrice: double.parse(row[6].toString()),
          lineTotal: double.parse(row[7].toString()),
          isRefund: row[8] == 'REMBOURSEMENT',
          paymentMethod: row[9].toString(),
        ),
      );
    }

    return sales;
  }

  /// Total ventes (positif)
  double totalVentes(List<SaleRecord> list) {
    return list
        .where((e) => !e.isRefund)
        .fold(0.0, (s, e) => s + e.lineTotal);
  }

  /// Total remboursements (positif)
  double totalRemboursements(List<SaleRecord> list) {
    return list
        .where((e) => e.isRefund)
        .fold(0.0, (s, e) => s + e.lineTotal.abs());
  }

  /// Total net
  double totalNet(List<SaleRecord> list) {
    return totalVentes(list) - totalRemboursements(list);
  }
}
