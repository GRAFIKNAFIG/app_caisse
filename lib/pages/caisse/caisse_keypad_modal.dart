import 'package:flutter/material.dart';
import '../../theme/theme_premium.dart';

class CaisseKeypadModal extends StatefulWidget {
  final String title;
  final double? initialValue;
  final String? extraInfo;
  final void Function(double value) onValidate;

  const CaisseKeypadModal({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onValidate,
    this.extraInfo,
  });

  @override
  State<CaisseKeypadModal> createState() => _CaisseKeypadModalState();
}

class _CaisseKeypadModalState extends State<CaisseKeypadModal> {
  String buffer = '';
  static const int maxLen = 8;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      buffer = widget.initialValue!.toStringAsFixed(2);
    }
  }

  void _press(String char) {
    setState(() {
      if (char == 'C') {
        buffer = '';
      } else if (char == '←') {
        if (buffer.isNotEmpty) buffer = buffer.substring(0, buffer.length - 1);
      } else if (char == ',' || char == '.') {
        if (!buffer.contains('.')) {
          if (buffer.isEmpty) buffer = '0';
          buffer += '.';
        }
      } else {
        if (buffer.length >= maxLen) return;
        buffer += char;
      }
    });
  }

  void _validate() {
    if (buffer.isEmpty) return;
    final v = double.tryParse(buffer);
    if (v == null) return;
    widget.onValidate(v);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final display = buffer.isEmpty ? '0.00' : buffer;

    final keys = [
      '1','2','3',
      '4','5','6',
      '7','8','9',
      ',','0','←',
    ];

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SizedBox(
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titre + croix
              Row(
                children: [
                  Expanded(
                    child: Text(widget.title, style: PremiumTheme.label),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 18,
                  ),
                ],
              ),

              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('$display €', style: PremiumTheme.totalText),
              ),

              if (widget.extraInfo != null) ...[
                const SizedBox(height: 4),
                Text(widget.extraInfo!, style: PremiumTheme.text),
              ],

              const SizedBox(height: 10),

              // Pavé tactile compact
              SizedBox(
                height: 200,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: keys.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (_, i) {
                    final k = keys[i];
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.black26),
                        ),
                      ),
                      onPressed: () => _press(k),
                      child: Text(k, style: PremiumTheme.buttonText),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Annuler + Valider
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Annuler', style: PremiumTheme.buttonText),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _validate,
                      child: Text(
                        'Valider',
                        style: PremiumTheme.buttonText.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
