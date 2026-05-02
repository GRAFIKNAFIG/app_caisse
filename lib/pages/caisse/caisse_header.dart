import 'package:flutter/material.dart';
import '../../theme/theme_premium.dart';

class CaisseHeaderBar extends StatelessWidget {
  final bool isRefund;
  final VoidCallback onToggleRefund;

  const CaisseHeaderBar({
    super.key,
    required this.isRefund,
    required this.onToggleRefund,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Caisse', style: PremiumTheme.title),
        const Spacer(),
        TextButton(
          onPressed: onToggleRefund,
          child: Text(
            isRefund ? 'Mode remboursement' : 'Mode vente',
            style: PremiumTheme.label,
          ),
        ),
      ],
    );
  }
}
