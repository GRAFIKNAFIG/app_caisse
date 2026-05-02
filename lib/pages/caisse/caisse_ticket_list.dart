import 'package:flutter/material.dart';
import '../../models/ticket_line.dart';
import '../../theme/theme_premium.dart';

class CaisseTicketList extends StatelessWidget {
  final List<TicketLine> lines;
  final double total;
  final void Function(int index) onRemoveLine;
  final VoidCallback onClearTicket;

  const CaisseTicketList({
    super.key,
    required this.lines,
    required this.total,
    required this.onRemoveLine,
    required this.onClearTicket,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: PremiumTheme.panelDecoration,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(flex: 4, child: Text('Article', style: PremiumTheme.label)),
              Expanded(flex: 2, child: Text('PU', style: PremiumTheme.label)),
              Expanded(flex: 2, child: Text('Qté', style: PremiumTheme.label)),
              Expanded(flex: 2, child: Text('Total', style: PremiumTheme.label)),
              SizedBox(
                width: 32,
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onClearTicket,
                ),
              ),
            ],
          ),

          const Divider(),

          Expanded(
            child: ListView.builder(
              itemCount: lines.length,
              itemBuilder: (context, index) {
                final l = lines[index];

                return Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        l.subCategory,
                        style: PremiumTheme.text,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        l.unitPrice.toStringAsFixed(2),
                        style: PremiumTheme.text,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${l.quantity}',
                        style: PremiumTheme.text,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        l.total.toStringAsFixed(2),
                        style: PremiumTheme.text,
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onRemoveLine(index),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const Divider(),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total ticket : ${total.toStringAsFixed(2)} €',
              style: PremiumTheme.totalText,
            ),
          ),
        ],
      ),
    );
  }
}
