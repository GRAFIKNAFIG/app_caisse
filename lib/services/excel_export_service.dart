import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import '../models/sale_record.dart';

/// Service PRO pour générer un fichier Excel .xlsx
/// avec 5 onglets : Tickets, CA jour, CA semaine, CA mois, CA trimestre.
class ExcelExportService {
  static final ExcelExportService instance = ExcelExportService._internal();
  ExcelExportService._internal();

  /// Génère le fichier Excel complet
  Future<void> exportExcel({
    required List<SaleRecord> records,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Sélecteur de dossier natif
    final String? selectedDir = await FilePicker.platform.getDirectoryPath();

    if (selectedDir == null) {
      return; // utilisateur a annulé
    }

    // Déterminer nom du fichier
    final bool isSingleDay =
        startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day;

    final String fileName = isSingleDay
        ? "export_caisse_${DateFormat('yyyy-MM-dd').format(startDate)}.xlsx"
        : "caisse_du_${DateFormat('yyyy-MM-dd').format(startDate)}_au_${DateFormat('yyyy-MM-dd').format(endDate)}.xlsx";

    final String fullPath = "$selectedDir/$fileName";

    // Création du fichier Excel
    final excel = Excel.createExcel();

    _buildTicketsSheet(excel, records);
    _buildDailySheet(excel, records);
    _buildWeeklySheet(excel, records);
    _buildMonthlySheet(excel, records);
    _buildQuarterlySheet(excel, records);

    // Sauvegarde
    final fileBytes = excel.save();
    final file = File(fullPath);
    await file.writeAsBytes(fileBytes!);
  }

  // Onglet 1 — Tickets
  void _buildTicketsSheet(Excel excel, List<SaleRecord> records) {
    final sheet = excel['Tickets'];

    sheet.appendRow([
      'Date',
      'Heure',
      'Catégorie',
      'Sous-catégorie',
      'Quantité',
      'Prix unitaire',
      'Total ligne',
      'Type',
      'Mode paiement',
      'Ticket ID',
    ]);

    for (final r in records) {
      sheet.appendRow([
        r.dateString,
        r.timeString,
        r.category,
        r.subCategory,
        r.quantity,
        r.unitPrice.toStringAsFixed(2),
        r.lineTotal.toStringAsFixed(2),
        r.isRefund ? 'REMBOURSEMENT' : 'VENTE',
        r.paymentMethod,
        r.ticketId,
      ]);
    }
  }

  // Onglet 2 — CA par jour
  void _buildDailySheet(Excel excel, List<SaleRecord> records) {
    final sheet = excel['CA_jour'];

    sheet.appendRow([
      'Date',
      'CA ventes',
      'CA remboursements',
      'CA net',
      'Nombre tickets',
    ]);

    final Map<String, List<SaleRecord>> grouped = {};

    for (final r in records) {
      grouped.putIfAbsent(r.dateString, () => []).add(r);
    }

    grouped.forEach((date, list) {
      final double ventes = list
          .where((e) => !e.isRefund)
          .fold(0.0, (s, e) => s + e.lineTotal);

      final double remboursements = list
          .where((e) => e.isRefund)
          .fold(0.0, (s, e) => s + e.lineTotal.abs());

      final double net = ventes - remboursements;

      final int tickets = list.map((e) => e.ticketId).toSet().length;

      sheet.appendRow([
        date,
        ventes.toStringAsFixed(2),
        remboursements.toStringAsFixed(2),
        net.toStringAsFixed(2),
        tickets,
      ]);
    });
  }

  // Onglet 3 — CA par semaine
  void _buildWeeklySheet(Excel excel, List<SaleRecord> records) {
    final sheet = excel['CA_semaine'];

    sheet.appendRow([
      'Semaine',
      'CA ventes',
      'CA remboursements',
      'CA net',
      'Nombre tickets',
    ]);

    final Map<String, List<SaleRecord>> grouped = {};

    for (final r in records) {
      final week = _weekString(r.dateTime);
      grouped.putIfAbsent(week, () => []).add(r);
    }

    grouped.forEach((week, list) {
      final double ventes = list
          .where((e) => !e.isRefund)
          .fold(0.0, (s, e) => s + e.lineTotal);

      final double remboursements = list
          .where((e) => e.isRefund)
          .fold(0.0, (s, e) => s + e.lineTotal.abs());

      final double net = ventes - remboursements;

      final int tickets = list.map((e) => e.ticketId).toSet().length;

      sheet.appendRow([
        week,
        ventes.toStringAsFixed(2),
        remboursements.toStringAsFixed(2),
        net.toStringAsFixed(2),
        tickets,
      ]);
    });
  }

  // Onglet 4 — CA par mois
  void _buildMonthlySheet(Excel excel, List<SaleRecord> records) {
    final sheet = excel['CA_mois'];

    sheet.appendRow([
      'Mois',
      'CA ventes',
      'CA remboursements',
      'CA net',
      'Nombre tickets',
    ]);

    final Map<String, List<SaleRecord>> grouped = {};

    for (final r in records) {
      final month = DateFormat('yyyy-MM').format(r.dateTime);
      grouped.putIfAbsent(month, () => []).add(r);
    }

    grouped.forEach((month, list) {
      final double ventes = list
          .where((e) => !e.isRefund)
          .fold(0.0, (s, e) => s + e.lineTotal);

      final double remboursements = list
          .where((e) => e.isRefund)
          .fold(0.0, (s, e) => s + e.lineTotal.abs());

      final double net = ventes - remboursements;

      final int tickets = list.map((e) => e.ticketId).toSet().length;

      sheet.appendRow([
        month,
        ventes.toStringAsFixed(2),
        remboursements.toStringAsFixed(2),
        net.toStringAsFixed(2),
        tickets,
      ]);
    });
  }

  // Onglet 5 — CA par trimestre
  void _buildQuarterlySheet(Excel excel, List<SaleRecord> records) {
    final sheet = excel['CA_trimestre'];

    sheet.appendRow([
      'Trimestre',
      'CA ventes',
      'CA remboursements',
      'CA net',
      'Nombre tickets',
    ]);

    final Map<String, List<SaleRecord>> grouped = {};

    for (final r in records) {
      final quarter = _quarterString(r.dateTime);
      grouped.putIfAbsent(quarter, () => []).add(r);
    }

    grouped.forEach((quarter, list) {
      final double ventes = list
          .where((e) => !e.isRefund)
          .fold(0.0, (s, e) => s + e.lineTotal);

      final double remboursements = list
          .where((e) => e.isRefund)
          .fold(0.0, (s, e) => s + e.lineTotal.abs());

      final double net = ventes - remboursements;

      final int tickets = list.map((e) => e.ticketId).toSet().length;

      sheet.appendRow([
        quarter,
        ventes.toStringAsFixed(2),
        remboursements.toStringAsFixed(2),
        net.toStringAsFixed(2),
        tickets,
      ]);
    });
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
