import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/recap_service.dart';
import '../services/stats_service.dart';
import '../services/excel_export_service.dart';
import '../models/sale_record.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  List<SaleRecord> sales = [];
  bool loading = false;

  final recap = RecapService.instance;
  final stats = StatsService.instance;

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => endDate = picked);
    }
  }

  void _setToday() {
    final now = DateTime.now();
    setState(() {
      startDate = DateTime(now.year, now.month, now.day);
      endDate = startDate;
    });
  }

  void _setWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    setState(() {
      startDate = DateTime(monday.year, monday.month, monday.day);
      endDate = DateTime(sunday.year, sunday.month, sunday.day);
    });
  }

  void _setMonth() {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, 1);
    final last = DateTime(now.year, now.month + 1, 0);

    setState(() {
      startDate = first;
      endDate = last;
    });
  }

  void _setQuarter() {
    final now = DateTime.now();
    final q = ((now.month - 1) ~/ 3) + 1;

    final firstMonth = (q - 1) * 3 + 1;
    final lastMonth = firstMonth + 2;

    final first = DateTime(now.year, firstMonth, 1);
    final last = DateTime(now.year, lastMonth + 1, 0);

    setState(() {
      startDate = first;
      endDate = last;
    });
  }

  Future<void> _loadStats() async {
    setState(() => loading = true);

    final list = await recap.loadSalesBetween(startDate, endDate);

    setState(() {
      sales = list;
      loading = false;
    });
  }

  Future<void> _exportExcel() async {
    await ExcelExportService.instance.exportExcel(
      records: sales,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');

    final totalVentes = stats.totalVentes(sales);
    final totalRemb = stats.totalRemboursements(sales);
    final totalNet = stats.totalNet(sales);
    final nbTickets = stats.nombreTickets(sales);

    final topCat = stats.topCategories(sales);
    final topSub = stats.topSousCategories(sales);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Statistiques"),
        backgroundColor: Colors.blue.shade300,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Sélecteurs de dates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _pickStartDate,
                  child: Text("Début : ${df.format(startDate)}"),
                ),
                ElevatedButton(
                  onPressed: _pickEndDate,
                  child: Text("Fin : ${df.format(endDate)}"),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Boutons rapides
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(onPressed: _setToday, child: const Text("Aujourd’hui")),
                ElevatedButton(onPressed: _setWeek, child: const Text("Semaine")),
                ElevatedButton(onPressed: _setMonth, child: const Text("Mois")),
                ElevatedButton(onPressed: _setQuarter, child: const Text("Trimestre")),
              ],
            ),

            const SizedBox(height: 12),

            // Boutons Charger + Export
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _loadStats,
                  child: const Text("Charger"),
                ),
                ElevatedButton(
                  onPressed: sales.isEmpty ? null : _exportExcel,
                  child: const Text("Télécharger Excel"),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Totaux
            if (!loading) Column(
              children: [
                Text("Ventes : ${totalVentes.toStringAsFixed(2)} €",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Remboursements : ${totalRemb.toStringAsFixed(2)} €",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Net : ${totalNet.toStringAsFixed(2)} €",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Tickets : $nbTickets",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 16),

            // TOP catégories + sous-catégories
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        const Text("Top catégories",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        ...topCat.entries.map((e) => ListTile(
                              title: Text(e.key),
                              trailing: Text(
                                  "${e.value.toStringAsFixed(2)} €",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            )),

                        const SizedBox(height: 20),

                        const Text("Top sous-catégories",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        ...topSub.entries.map((e) => ListTile(
                              title: Text(e.key),
                              trailing: Text(
                                  "${e.value.toStringAsFixed(2)} €",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            )),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
