import 'package:dropdown_button2/dropdown_button2.dart';
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

    _selectedDate = DateTime.now();
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
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

      await context.read<TransactionViewModel>().addTransaction(
        tx,
        widget.category.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving transaction: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildIcon(String iconStr) {
    final codePoint = int.tryParse(iconStr);
    if (codePoint != null) {
      return Icon(
        IconData(codePoint, fontFamily: 'MaterialIcons'),
        size: 48,
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
                height: 100,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildIcon(_selectedCategory.icon),
                    const SizedBox(width: 12),
                    Text(
                      _selectedCategory.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Transaction type dropdown
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.currency_exchange, color: Colors.black87),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<TransactionType>(
                          isExpanded: true,
                          value: _selectedType,
                          onChanged: (value) {
                            if (value != null) setState(() => _selectedType = value);
                          },
                          items: TransactionType.values.map((type) {
                            return DropdownMenuItem<TransactionType>(
                              value: type,
                              child: Text(
                                (type == TransactionType.Expense
                                    ? l10n.expenses
                                    : l10n.income).toUpperCase(),
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

              const SizedBox(height: 20),

              // Title
              TransactionFormTextField(
                controller: _titleController,
                hintText: l10n.title,
                prefixIcon: Icons.text_fields,
                validator: (value) => value == null || value.isEmpty
                    ? l10n.validate_title_empty
                    : null,
              ),

              const SizedBox(height: 20),

              // Price
              TransactionFormTextField(
                controller: _priceController,
                hintText: l10n.price,
                prefixIcon: Icons.account_balance_wallet,
                suffixText: '₫',
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? l10n.validate_price_empty
                    : null,
              ),

              const SizedBox(height: 20),

              // Date picker
              TransactionFormTextField(
                controller: _dateController,
                hintText: l10n.date,
                prefixIcon: Icons.calendar_today,
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    final now = DateTime.now();
                    _selectedDate = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      now.hour,
                      now.minute,
                      now.second,
                    );

                    setState(() {
                      _dateController.text = DateFormat(
                        'dd/MM/yyyy',
                      ).format(_selectedDate!);
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // Note
              TextFormField(
                controller: _noteController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 5,
                decoration: InputDecoration(
                  hintText: l10n.note,
                  filled: true,
                  fillColor: const Color(0xFFDFF7E2),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              Center(
                child: Container(
                  width: 180,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D09E), Color(0xFF00A67E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32),
                      onTap: _isSaving ? null : _submit,
                      child: Center(
                        child: Text(
                          l10n.save,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
