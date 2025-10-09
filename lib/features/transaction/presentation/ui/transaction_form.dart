import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/viewmodel/auth_viewmodel.dart';
import '../../../category/domain/entity/category.dart';
import '../../domain/entities/transaction.dart';
import '../viewmodel/transaction_view_model.dart';

class TransactionForm extends StatefulWidget {
  final Category category;
  const TransactionForm({super.key, required this.category});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _selectedDate;
  TransactionType _selectedType = TransactionType.Expense;
  bool _isSaving = false;
  late Category _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final authVm = context.read<AuthViewModel>();
      final userId = authVm.user?.uid ?? "";

      final tx = Transaction(
        id: UniqueKey().toString(),
        userId: userId,
        title: _titleController.text.trim(),
        price: double.tryParse(_priceController.text.replaceAll('.', '')) ?? 0,
        category: _selectedCategory,
        date: _selectedDate ?? DateTime.now(),
        note: _noteController.text.trim(),
        type: _selectedType,
      );

      await context.read<TransactionViewModel>().addTransaction(tx);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('❌ Error saving transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildIcon(String iconStr) {
    final codePoint = int.tryParse(iconStr);
    if (codePoint != null) {
      return Icon(
        IconData(codePoint, fontFamily: 'MaterialIcons'),
        size: 32,
        color: Colors.blue[700],
      );
    } else {
      return Text(iconStr, style: const TextStyle(fontSize: 32));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text("New transaction"),
        backgroundColor: const Color(0xFF00D09E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildIcon(_selectedCategory.icon),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedCategory.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 💸 Transaction type dropdown
              DropdownButtonFormField<TransactionType>(
                value: _selectedType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFDFF7E2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: TransactionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      type == TransactionType.Expense
                          ? l10n.expenses
                          : l10n.income,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),

              const SizedBox(height: 12),

              // 📝 Title
              TransactionFormTextField(
                controller: _titleController,
                hintText: l10n.title,
                prefixIcon: Icons.text_fields,
                validator: (value) =>
                value == null || value.isEmpty ? l10n.validate_title_empty : null,
              ),

              const SizedBox(height: 12),

              // 💰 Price
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

              // 📅 Date picker
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

              // 🗒️ Note
              TransactionFormTextField(
                controller: _noteController,
                hintText: l10n.note,
                prefixIcon: Icons.note,
              ),

              const SizedBox(height: 24),

              // 💾 Save button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D09E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    l10n.save,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
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