import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/subcategory.dart';
import '../models/ticket_line.dart';
import '../services/storage_service.dart';

import '../widgets/category_button.dart';
import '../widgets/subcategory_button.dart';
import '../widgets/ticket_view.dart';
import '../widgets/keypad_pv.dart';
import '../widgets/keypad_payment.dart';

class CaissePage extends StatefulWidget {
  final List<Category> categories;

  const CaissePage({super.key, required this.categories});

  @override
  State<CaissePage> createState() => _CaissePageState();
}

class _CaissePageState extends State<CaissePage> {
  int selectedCategoryIndex = 0;
  SubCategory? selectedSubCategory;
  int quantity = 1;

  final List<TicketLine> ticketLines = [];

  bool refundMode = false;

  // PV keypad
  bool showPVKeypad = false;
  String pvText = '';
  double? pvValue;

  // Payment keypad
  bool showPaymentKeypad = false;
  String payText = '';
  double? payValue;

  double get total =>
      ticketLines.fold(0.0, (sum, line) => sum + line.total);

  double get change =>
      payValue == null ? 0 : payValue! - total;

  void _addProduct() {
    if (selectedSubCategory == null) return;

    double price = selectedSubCategory!.isVariable
        ? (pvValue ?? 0)
        : selectedSubCategory!.fixedPrice!;

    if (price <= 0) return;

    final bool isRefund = refundMode;

    if (isRefund) {
      price = -price;
    }

    setState(() {
      ticketLines.add(
        TicketLine(
          category: widget.categories[selectedCategoryIndex].name,
          subCategory: selectedSubCategory!.label,
          unitPrice: price,
          quantity: quantity,
          isRefund: isRefund,
        ),
      );

      selectedSubCategory = null;
      pvText = '';
      pvValue = null;
      refundMode = false;
    });
  }

  void _onPVKey(String key) {
    setState(() {
      if (key == 'C') {
        pvText = '';
        pvValue = null;
        return;
      }
      if (key == '←') {
        if (pvText.isNotEmpty) {
          pvText = pvText.substring(0, pvText.length - 1);
          pvValue = double.tryParse(pvText.replaceAll(',', '.'));
        }
        return;
      }

      pvText += key;
      pvValue = double.tryParse(pvText.replaceAll(',', '.'));
    });
  }

  void _validatePV() {
    _addProduct();
    setState(() => showPVKeypad = false);
  }

  void _onPayKey(String key) {
    setState(() {
      if (key == 'C') {
        payText = '';
        payValue = null;
        return;
      }
      if (key == '←') {
        if (payText.isNotEmpty) {
          payText = payText.substring(0, payText.length - 1);
          payValue = double.tryParse(payText.replaceAll(',', '.'));
        }
        return;
      }

      payText += key;
      payValue = double.tryParse(payText.replaceAll(',', '.'));
    });
  }

  Future<void> _validatePayment() async {
    await StorageService.instance.saveTicket(ticketLines);

    setState(() {
      ticketLines.clear();
      showPaymentKeypad = false;
      payText = '';
      payValue = null;
      refundMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCategory = widget.categories[selectedCategoryIndex];

    return Stack(
      children: [
        Row(
          children: [
            // COLONNE GAUCHE : CATÉGORIES
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: widget.categories.length,
                itemBuilder: (context, index) {
                  return CategoryButton(
                    label: widget.categories[index].name,
                    selected: index == selectedCategoryIndex,
                    onTap: () {
                      setState(() {
                        selectedCategoryIndex = index;
                        selectedSubCategory = null;
                      });
                    },
                  );
                },
              ),
            ),

            // COLONNE CENTRALE : SOUS-CATÉGORIES
            Expanded(
              flex: 5,
              child: ListView(
                children: currentCategory.subCategories.map((sub) {
                  return SubCategoryButton(
                    label: sub.label,
                    selected: sub == selectedSubCategory,
                    priceText: sub.isVariable ? null : "${sub.fixedPrice} €",
                    onTap: () {
                      setState(() {
                        selectedSubCategory = sub;
                        quantity = 1;

                        if (sub.isVariable) {
                          showPVKeypad = true;
                          pvText = '';
                          pvValue = null;
                        } else {
                          pvValue = sub.fixedPrice;
                          _addProduct();
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            // COLONNE DROITE : TICKET
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  if (refundMode)
                    Container(
                      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "MODE REMBOURSEMENT ACTIF : le prochain article sera enregistré en négatif.",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Expanded(
                    child: TicketView(
                      lines: ticketLines,
                      onDelete: (i) {
                        setState(() => ticketLines.removeAt(i));
                      },
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E5EA)),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "${total.toStringAsFixed(2)} €",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: total >= 0
                                      ? const Color(0xFF0070E0)
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // LIGNE 1 : CB + REMBOURSEMENT
                        SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () {
      setState(() {
        ticketLines.clear();
        refundMode = false;
      });
    },
    icon: const Icon(Icons.delete, color: Colors.red),
    label: const Text(
      "Annuler le ticket",
      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      side: const BorderSide(color: Colors.red),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  ),
),
const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: ticketLines.isEmpty
                                    ? null
                                    : () => setState(() {
                                          showPaymentKeypad = true;
                                          payText = '';
                                          payValue = null;
                                        }),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.7),
                                  foregroundColor: Colors.black,
                                  side: const BorderSide(color: Color(0xFFE5E5EA)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text("CB"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    refundMode = true;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.7),
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Color(0xFFE5E5EA)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text("Remboursement"),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // LIGNE 2 : ESPÈCES + CHÈQUE
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: ticketLines.isEmpty
                                    ? null
                                    : () => setState(() {
                                          showPaymentKeypad = true;
                                          payText = '';
                                          payValue = null;
                                        }),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.7),
                                  foregroundColor: Colors.black,
                                  side: const BorderSide(color: Color(0xFFE5E5EA)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text("Espèces"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: ticketLines.isEmpty
                                    ? null
                                    : () => setState(() {
                                          showPaymentKeypad = true;
                                          payText = '';
                                          payValue = null;
                                        }),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.7),
                                  foregroundColor: Colors.black,
                                  side: const BorderSide(color: Color(0xFFE5E5EA)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text("Chèque"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        if (showPVKeypad)
          KeypadPV(
            display: pvText,
            onKeyPress: _onPVKey,
            onValidate: _validatePV,
          ),

        if (showPaymentKeypad)
          KeypadPayment(
            display: payText,
            total: total,
            change: change,
            onKeyPress: _onPayKey,
            onValidate: _validatePayment,
          ),
      ],
    );
  }
}
