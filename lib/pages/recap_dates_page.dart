import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/recap_service.dart';
import '../models/sale_record.dart';

class RecapDatesPage extends StatefulWidget {
  const RecapDatesPage({super.key});

  @override
  State<RecapDatesPage> createState() => _RecapDatesPageState();
}

class _RecapDatesPageState extends State<RecapDatesPage> {
  DateTime selectedDate = DateTime.now();
  List<SaleRecord> sales = [];

  Future<void> _load() async {
    final data = await RecapService.instance.loadSalesForDate(selectedDate);
    setState(() => sales = data);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final total = sales.fold(0.0, (sum, s) => sum + s.lineTotal);

    return Column(
      children: [
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() => selectedDate = picked);
              _load();
            }
          },
          child: Text(
            "Date : ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: sales.length,
            itemBuilder: (context, i) {
              final s = sales[i];
              final color = s.isRefund ? Colors.red : Colors.black87;

              return ListTile(
                title: Text(
                  s.subCategory,
                  style: TextStyle(color: color),
                ),
                subtitle: Text(
                  "${s.unitPrice.toStringAsFixed(2)} € x ${s.quantity}",
                  style: TextStyle(color: color.withOpacity(0.7)),
                ),
                trailing: Text(
                  "${s.lineTotal.toStringAsFixed(2)} €",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            "Total : ${total.toStringAsFixed(2)} €",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}
