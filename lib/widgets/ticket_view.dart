import 'package:flutter/material.dart';
import '../models/ticket_line.dart';

class TicketView extends StatelessWidget {
  final List<TicketLine> lines;
  final void Function(int index) onDelete;

  const TicketView({
    super.key,
    required this.lines,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const Center(
        child: Text(
          "Aucun article",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return ListView.separated(
      itemCount: lines.length,
      separatorBuilder: (_, __) => const Divider(height: 8),
      itemBuilder: (context, index) {
        final line = lines[index];
        final color = line.isRefund ? Colors.red : Colors.black87;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.subCategory,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${line.unitPrice.toStringAsFixed(2)} € x ${line.quantity}",
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "${line.total.toStringAsFixed(2)} €",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: Colors.red,
              onPressed: () => onDelete(index),
            ),
          ],
        );
      },
    );
  }
}
