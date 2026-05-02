import 'package:flutter/material.dart';
import '../services/recap_service.dart';
import '../models/sale_record.dart';

class RecapDetailsPage extends StatefulWidget {
  final String ticketId;

  const RecapDetailsPage({super.key, required this.ticketId});

  @override
  State<RecapDetailsPage> createState() => _RecapDetailsPageState();
}

class _RecapDetailsPageState extends State<RecapDetailsPage> {
  List<SaleRecord> records = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    records = await RecapService.instance.getDetailsForTicket(widget.ticketId);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text("Ticket ${widget.ticketId}")),
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final r = records[index];

          return Card(
            child: ListTile(
              title: Text(r.subCategory),
              subtitle: Text(
                "${r.unitPrice.toStringAsFixed(2)} € x ${r.quantity} (${r.type})",
              ),
              trailing: Text(
                "${r.total.toStringAsFixed(2)} €",
                style: TextStyle(
                  color: r.total < 0 ? Colors.red : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
