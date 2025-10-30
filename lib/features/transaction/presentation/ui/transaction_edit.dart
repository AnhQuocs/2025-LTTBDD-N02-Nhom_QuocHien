import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/transaction.dart';
import '../viewmodel/transaction_view_model.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _noteController;
  late TextEditingController _dateController;

  late TransactionType _type;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.transaction.title ?? '',
    );
    _priceController = TextEditingController(
      text: widget.transaction.price.toString(),
    );
    _noteController = TextEditingController(
      text: widget.transaction.note ?? '',
    );
    _type = widget.transaction.type;
    _selectedDate = widget.transaction.date;

    _dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(_selectedDate!),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.transaction.category;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.edit_transaction),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            Center(
              child: Column(
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Type
            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.currency_exchange, color: Colors.black87),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<TransactionType>(
                        isExpanded: true,
                        value: _type,
                        onChanged: (val) {
                          if (val != null) setState(() => _type = val);
                        },
                        items: TransactionType.values.map((type) {
                          return DropdownMenuItem<TransactionType>(
                            value: type,
                            child: Text(
                              type == TransactionType.Expense
                                  ? l10n.expenses
                                  : l10n.income,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),

                        iconStyleData: const IconStyleData(
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                        ),

                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          maxHeight: 200,
                          offset: const Offset(0, 4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.title,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Price
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.price,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                suffixText: "₫",
              ),
            ),
            const SizedBox(height: 16),

            // Date
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: l10n.date,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                FocusScope.of(context).unfocus();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    final now = DateTime.now();
                    _selectedDate = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      now.hour,
                      now.minute,
                      now.second,
                    );
                    _dateController.text = DateFormat(
                      'dd/MM/yyyy',
                    ).format(_selectedDate!);
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Note
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.note,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Nút lưu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  final vm = context.read<TransactionViewModel>();

                  final updatedTransaction = widget.transaction.copyWith(
                    title: _titleController.text.trim(),
                    price: double.tryParse(_priceController.text) ?? 0.0,
                    note: _noteController.text.trim(),
                    type: _type,
                    date: _selectedDate ?? widget.transaction.date,
                  );

                  await vm.updateTransaction(updatedTransaction);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.changes_success)),
                    );
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.save),
                label: Text(
                  l10n.confirm,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
