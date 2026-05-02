import 'package:flutter/material.dart';
import '../../theme/theme_premium.dart';

class CaissePayment extends StatelessWidget {
  final String paymentMethod;
  final ValueChanged<String> onPaymentChanged;
  final VoidCallback onValidateTicket;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final double? cashGiven;
  final double changeDue;
  final double total;

  const CaissePayment({
    super.key,
    required this.paymentMethod,
    required this.onPaymentChanged,
    required this.onValidateTicket,
    required this.quantity,
    required this.onQuantityChanged,
    required this.cashGiven,
    required this.changeDue,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: PremiumTheme.panelDecoration,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Mode de paiement', style: PremiumTheme.label),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            children: [
              _chip('CB'),
              _chip('Espèces'),
              _chip('Chèque'),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Text('Qté : ', style: PremiumTheme.label),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: quantity,
                onChanged: (v) {
                  if (v != null) onQuantityChanged(v);
                },
                items: List.generate(
                  10,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('${i + 1}'),
                  ),
                ),
              ),
            ],
          ),

          if (paymentMethod == 'Espèces') ...[
            const SizedBox(height: 4),

            if (cashGiven != null) ...[
              Text(
                'Reçu : ${cashGiven!.toStringAsFixed(2)} €',
                style: PremiumTheme.text,
              ),
              Text(
                'À rendre : ${changeDue.toStringAsFixed(2)} €',
                style: PremiumTheme.text,
              ),
            ] else ...[
              Text('Reçu : —', style: PremiumTheme.text),
              Text('À rendre : —', style: PremiumTheme.text),
            ],
          ] else ...[
            const SizedBox(height: 4),
            Text(
              'Total : ${total.toStringAsFixed(2)} €',
              style: PremiumTheme.text,
            ),
          ],

          const Spacer(),

          SizedBox(
            height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onValidateTicket,
              child: Text(
                'Valider le ticket',
                style: PremiumTheme.buttonText.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    final selected = paymentMethod == label;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onPaymentChanged(label),
    );
  }
}
