import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/viewmodel/auth_viewmodel.dart';
import '../../domain/entities/transaction.dart';
import '../viewmodel/transaction_view_model.dart';

class TransactionForm extends StatefulWidget {
  const TransactionForm({super.key});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _dateController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _selectedDate;
  TransactionType _selectedType = TransactionType.Expense;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final authVm = context.read<AuthViewModel>();
      final userId = authVm.user?.uid ?? "";

      final tx = Transaction(
        id: UniqueKey().toString(),
        userId: userId,
        title: _titleController.text.trim(),
        price: double.tryParse(_priceController.text.replaceAll('.', '')) ?? 0,
        category: _categoryController.text.trim(),
        date: _selectedDate ?? DateTime.now(),
        note: _noteController.text.trim(),
        type: _selectedType,
      );

      context.read<TransactionViewModel>().addTransaction(tx);

      _titleController.clear();
      _priceController.clear();
      _categoryController.clear();
      _dateController.clear();
      _noteController.clear();
      setState(() {
        _selectedDate = null;
        _selectedType = TransactionType.Expense;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<TransactionType>(
              value: _selectedType,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFDFF7E2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.category),
              ),
              items: TransactionType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type == TransactionType.Expense ? l10n.expenses : l10n.income,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedType = value);
              },
            ),

            const SizedBox(height: 12),

            // Title
            TransactionFormTextField(
              controller: _titleController,
              hintText: l10n.title,
              prefixIcon: Icons.text_fields,
              validator: (value) =>
              value == null || value.isEmpty ? l10n.validate_title_empty : null,
            ),

            const SizedBox(height: 12),

            // Price
            TransactionFormTextField(
              controller: _priceController,
              hintText: l10n.price,
              prefixIcon: Icons.account_balance_wallet,
              suffixText: '₫',
              keyboardType: TextInputType.number,
              validator: (value) =>
              value == null || value.isEmpty ? l10n.validate_price_empty : null,
            ),

            const SizedBox(height: 12),

            // Category
            TransactionFormTextField(
              controller: _categoryController,
              hintText: l10n.category,
              prefixIcon: Icons.category,
            ),

            const SizedBox(height: 12),

            // Date
            TransactionFormTextField(
              controller: _dateController,
              hintText: l10n.date,
              prefixIcon: Icons.calendar_today,
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                    _dateController.text =
                        DateFormat('dd/MM/yyyy').format(picked);
                  });
                }
              },
            ),

            const SizedBox(height: 12),

            // Note
            TransactionFormTextField(
              controller: _noteController,
              hintText: l10n.note,
              prefixIcon: Icons.note,
            ),

            const SizedBox(height: 20),

            // Save button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        l10n.save,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionFormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? suffixText;

  const TransactionFormTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixText: suffixText,
        filled: true,
        fillColor: const Color(0xFFDFF7E2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none
        )
      ),
    );
  }
}