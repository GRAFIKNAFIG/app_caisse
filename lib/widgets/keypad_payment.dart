import 'package:flutter/material.dart';

class KeypadPayment extends StatelessWidget {
  final String display;
  final double total;
  final double change;
  final void Function(String key) onKeyPress;
  final VoidCallback onValidate;

  const KeypadPayment({
    super.key,
    required this.display,
    required this.total,
    required this.change,
    required this.onKeyPress,
    required this.onValidate,
  });

  @override
  Widget build(BuildContext context) {
    final keys = [
      '7', '8', '9',
      '4', '5', '6',
      '1', '2', '3',
      ',', '0', '←',
    ];

    return Center(
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E5EA)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              display.isEmpty ? "0" : display,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Total : ${total.toStringAsFixed(2)} €",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Rendu : ${change.toStringAsFixed(2)} €",
              style: TextStyle(
                fontSize: 14,
                color: change >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              itemCount: keys.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final key = keys[index];
                return ElevatedButton(
                  onPressed: () => onKeyPress(key),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: Color(0xFFE5E5EA)),
                  ),
                  child: Text(
                    key,
                    style: const TextStyle(fontSize: 20),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onKeyPress('C'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Color(0xFFE5E5EA)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("C"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onValidate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0070E0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Valider"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
