import 'package:flutter/material.dart';
import '../services/recap_service.dart';
import 'recap_details_page.dart';

class RecapTicketsPage extends StatefulWidget {
  final String date;

  const RecapTicketsPage({super.key, required this.date});

  @override
  State<RecapTicketsPage> createState() => _RecapTicketsPageState();
}

class _RecapTicketsPageState extends State<RecapTicketsPage> {
  Map<String, double> tickets = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    tickets = await RecapService.instance.getTicketsForDate(widget.date);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final ids = tickets.keys.toList();

    return Scaffold(
      appBar: AppBar(title: Text("Tickets du ${widget.date}")),
      body: ListView.builder(
        itemCount: ids.length,
        itemBuilder: (context, index) {
          final id = ids[index];
          final total = tickets[id]!;

          return Card(
            child: ListTile(
              title: Text("Ticket $id"),
              trailing: Text(
                "${total.toStringAsFixed(2)} €",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecapDetailsPage(ticketId: id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
