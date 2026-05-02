import 'package:intl/intl.dart';
import '../models/sale_record.dart';

/// Service PRO pour calculer toutes les statistiques.
/// Compatible export Excel + page Stats + analyses avancées.
class StatsService {
  static final StatsService instance = StatsService._internal();
  StatsService._internal();

  /// CA ventes (positif)
  double totalVentes(List<SaleRecord> list) {
    return list
        .where((e) => !e.isRefund)
        .fold(0.0, (s, e) => s + e.lineTotal);
  }

  /// CA remboursements (positif)
  double totalRemboursements(List<SaleRecord> list) {
    return list
        .where((e) => e.isRefund)
        .fold(0.0, (s, e) => s + e.lineTotal.abs());
  }

  /// CA net
  double totalNet(List<SaleRecord> list) {
    return totalVentes(list) - totalRemboursements(list);
  }

  /// Nombre de tickets uniques
  int nombreTickets(List<SaleRecord> list) {
    return list.map((e) => e.ticketId).toSet().length;
  }

  /// CA par jour
  Map<String, double> caParJour(List<SaleRecord> list) {
    final Map<String, double> map = {};

    for (final r in list) {
      map.putIfAbsent(r.dateString, () => 0.0);
      map[r.dateString] = map[r.dateString]! + r.lineTotal;
    }

    return map;
  }

  /// CA par semaine ISO
  Map<String, double> caParSemaine(List<SaleRecord> list) {
    final Map<String, double> map = {};

    for (final r in list) {
      final week = _weekString(r.dateTime);
      map.putIfAbsent(week, () => 0.0);
      map[week] = map[week]! + r.lineTotal;
    }

    return map;
  }

  /// CA par mois
  Map<String, double> caParMois(List<SaleRecord> list) {
    final Map<String, double> map = {};

    for (final r in list) {
      final month = DateFormat('yyyy-MM').format(r.dateTime);
      map.putIfAbsent(month, () => 0.0);
      map[month] = map[month]! + r.lineTotal;
    }

    return map;
  }

  /// CA par trimestre
  Map<String, double> caParTrimestre(List<SaleRecord> list) {
    final Map<String, double> map = {};

    for (final r in list) {
      final quarter = _quarterString(r.dateTime);
      map.putIfAbsent(quarter, () => 0.0);
      map[quarter] = map[quarter]! + r.lineTotal;
    }

    return map;
  }

  /// Top catégories
  Map<String, double> topCategories(List<SaleRecord> list) {
    final Map<String, double> map = {};

    for (final r in list) {
      map.putIfAbsent(r.category, () => 0.0);
      map[r.category] = map[r.category]! + r.lineTotal;
    }

    return map;
  }

  /// Top sous-catégories
  Map<String, double> topSousCategories(List<SaleRecord> list) {
    final Map<String, double> map = {};

    for (final r in list) {
      map.putIfAbsent(r.subCategory, () => 0.0);
      map[r.subCategory] = map[r.subCategory]! + r.lineTotal;
    }

    return map;
  }

  // Format semaine ISO
  String _weekString(DateTime dt) {
    final week = int.parse(DateFormat('w').format(dt));
    final year = dt.year;
    return "$year-S$week";
  }

  // Format trimestre
  String _quarterString(DateTime dt) {
    final q = ((dt.month - 1) ~/ 3) + 1;
    return "${dt.year}-T$q";
  }
}
