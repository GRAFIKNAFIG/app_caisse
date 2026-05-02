import 'package:flutter/material.dart';
import '../theme/theme_premium.dart';

import '../models/ticket.dart';
import '../models/ticket_line.dart';
import '../models/subcategory.dart';
import '../services/storage_service.dart';
import '../data/categories_data.dart';

import 'caisse/caisse_categories.dart';
import 'caisse/caisse_subcategories.dart';
import 'caisse/caisse_ticket_list.dart';
import 'caisse/caisse_payment.dart';
import 'caisse/caisse_keypad_modal.dart';

class CaissePage extends StatefulWidget {
  const CaissePage({super.key});

  @override
  State<CaissePage> createState() => _CaissePageState();
}

class _CaissePageState extends State<CaissePage> {
  String? selectedCategory;
  SubCategory? selectedSubCategory;
  int quantity = 1;
  bool isRefund = false;

  String paymentMethod = 'Espèces';
  double? cashGiven;

  final List<TicketLine> lines = [];

  double get totalTicket =>
      lines.fold(0.0, (s, e) => s + e.total);

  double get changeDue =>
      cashGiven == null ? 0 : (cashGiven! - totalTicket);

  // CLAVIER MODAL — VERSION FINALE
  void _openKeypadModal({
    required String title,
    required double? initialValue,
    required String? extraInfo,
    required void Function(double value) onValidate,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => CaisseKeypadModal(
        title: title,
        initialValue: initialValue,
        extraInfo: extraInfo,
        onValidate: onValidate,
      ),
    );
  }

  void _onCategorySelected(String name) {
    setState(() {
      selectedCategory = name;
      selectedSubCategory = null;
      quantity = 1;
    });
  }

  void _onSubCategorySelected(SubCategory sub) {
    if (sub.isVariable) {
      setState(() {
        selectedSubCategory = sub;
      });

      _openKeypadModal(
        title: 'Prix variable',
        initialValue: null,
        extraInfo: 'Qté : $quantity',
        onValidate: (value) {
          final line = TicketLine(
            category: selectedCategory ?? '',
            subCategory: sub.label,
            quantity: quantity,
            unitPrice: value,
            isRefund: isRefund,
          );
          setState(() {
            lines.add(line);
            selectedSubCategory = null;
            quantity = 1;
          });
        },
      );
      return;
    }

    final line = TicketLine(
      category: selectedCategory ?? '',
      subCategory: sub.label,
      quantity: quantity,
      unitPrice: sub.fixedPrice ?? 0,
      isRefund: isRefund,
    );

    setState(() {
      lines.add(line);
      quantity = 1;
      selectedSubCategory = null;
    });
  }

  void _onPaymentChanged(String method) {
    setState(() {
      paymentMethod = method;
      if (method != 'Espèces') {
        cashGiven = null;
      }
    });

    if (method == 'Espèces') {
      _openKeypadModal(
        title: 'Montant reçu',
        initialValue: cashGiven,
        extraInfo: 'Total : ${totalTicket.toStringAsFixed(2)} €',
        onValidate: (value) {
          setState(() {
            cashGiven = value;
          });
        },
      );
    }
  }

  void _onQuantityChanged(int q) {
    setState(() {
      quantity = q.clamp(1, 10);
    });
  }

  void _removeLine(int index) {
    setState(() => lines.removeAt(index));
  }

  void _clearTicket() {
    setState(() {
      lines.clear();
      quantity = 1;
      selectedSubCategory = null;
      cashGiven = null;
    });
  }

  Future<void> _validateTicket() async {
    if (lines.isEmpty) return;

    if (paymentMethod == 'Espèces') {
      if (cashGiven == null || cashGiven! < totalTicket) {
        _openKeypadModal(
          title: 'Montant reçu',
          initialValue: cashGiven,
          extraInfo: 'Total : ${totalTicket.toStringAsFixed(2)} €',
          onValidate: (value) {
            setState(() {
              cashGiven = value;
            });
          },
        );
        return;
      }
    }

    final now = DateTime.now();

    final ticket = Ticket(
      id: now.millisecondsSinceEpoch.toString(),
      dateTime: now,
      lines: List<TicketLine>.from(lines),
      paymentMethod: paymentMethod,
    );

    await StorageService.instance.saveTicket(ticket);

    _clearTicket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Text('Caisse', style: PremiumTheme.title),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() => isRefund = !isRefund);
                    },
                    child: Text(
                      isRefund ? 'Mode remboursement' : 'Mode vente',
                      style: PremiumTheme.label,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CaisseCategories(
                        categories:
                            categories.map((c) => c.name).toList(),
                        selectedCategory: selectedCategory,
                        onCategorySelected: _onCategorySelected,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      flex: 4,
                      child: CaisseSubCategories(
                        categories: categories,
                        selectedCategory: selectedCategory,
                        selectedSubCategory: selectedSubCategory,
                        onSubCategorySelected: _onSubCategorySelected,
                        hide: selectedSubCategory != null &&
                            selectedSubCategory!.isVariable,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Expanded(
                            child: CaisseTicketList(
                              lines: lines,
                              total: totalTicket,
                              onRemoveLine: _removeLine,
                              onClearTicket: _clearTicket,
                            ),
                          ),

                          const SizedBox(height: 8),

                          SizedBox(
                            height: 180,
                            child: CaissePayment(
                              paymentMethod: paymentMethod,
                              onPaymentChanged: _onPaymentChanged,
                              onValidateTicket: _validateTicket,
                              quantity: quantity,
                              onQuantityChanged: _onQuantityChanged,
                              cashGiven: cashGiven,
                              changeDue: changeDue,
                              total: totalTicket,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
