import 'package:fin_track/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:fin_track/features/dashboard/ui/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../transaction/domain/entities/transaction.dart';
import '../../../transaction/presentation/ui/transaction_form.dart';
import '../../../transaction/presentation/viewmodel/transaction_view_model.dart';
import '../../domain/entity/category.dart';

class CategoryDetail extends StatefulWidget {
  final Category category;

  const CategoryDetail({super.key, required this.category});

  @override
  State<CategoryDetail> createState() => _CategoryDetail();
}

class _CategoryDetail extends State<CategoryDetail> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = context.read<TransactionViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    if (authViewModel.user != null) {
      viewModel.loadTransactionsByCategory(
        widget.category.id,
        authViewModel.user!.uid,
      );
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

  TransactionType? _selectedType;
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TransactionViewModel>();
    final l10n = AppLocalizations.of(context)!;

    final allTransactions = viewModel.categoryTransactions;

    final filteredTransactions = _selectedType == null
        ? allTransactions
        : allTransactions.where((tx) => tx.type == _selectedType).toList();

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    for (var tx in allTransactions) {
      if (tx.type == TransactionType.Income) {
        totalIncome += tx.price;
      } else {
        totalExpense += tx.price;
      }
    }

    double totalBalance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: const Color(0xFF00D09E),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF00D09E),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF7E2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.total_balance,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        currencyFormat.format(totalBalance),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 4,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          setState(() {
                            _selectedType = _selectedType == TransactionType.Income
                                ? null
                                : TransactionType.Income;
                          });
                        },
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: _selectedType == TransactionType.Income
                                ? const Color(0xFFB8F5D3)
                                : const Color(0xFFDFF7E2),
                            border: Border.all(
                              color: _selectedType == TransactionType.Income
                                  ? Color(0xFF009970)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.arrow_circle_up,
                                  size: 32,
                                  color: Color(0xFF00D09E),
                                ),
                                Text(
                                  l10n.income,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(totalIncome),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Flexible(
                      flex: 4,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          setState(() {
                            _selectedType = _selectedType == TransactionType.Expense
                                ? null
                                : TransactionType.Expense;
                          });
                        },
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: _selectedType == TransactionType.Expense
                                ? const Color(0xFFB8D9FF)
                                : const Color(0xFFDFF7E2),
                            border: Border.all(
                              color: _selectedType == TransactionType.Expense
                                  ? const Color(0xFF0068FF)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.arrow_circle_down,
                                  size: 32,
                                  color: Color(0xFF0068FF),
                                ),
                                Text(
                                  l10n.expenses,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(totalExpense),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF1FFF3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        l10n.summary,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    Expanded(
                      child: filteredTransactions.isEmpty
                          ? Center(
                        child: Text(
                          l10n.no_transaction,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                          : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) => _buildTransactionItem(
                          filteredTransactions[index],
                          widget.category.icon,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: Container(
        width: 180,
        height: 44,
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionForm(category: widget.category),
                ),
              );
            },
            child: Center(
              child: Text(
                l10n.add_transaction,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTransactionItem(Transaction tx, icon) {
    final timeString = DateFormat('HH:mm').format(tx.date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onLongPress: () => _showDeleteDialog(tx),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF6DB6FE).withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.white10,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildIcon(icon),

              SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "$timeString - ${tx.date.day}/${tx.date.month}/${tx.date.year}",
                    style: TextStyle(
                      color: Color(0xFF0068FF),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Spacer(),

              Text(
                '${tx.type == TransactionType.Expense ? "-" : "+"} ${currencyFormat.format(tx.price)}',
                style: TextStyle(
                  color: tx.type == TransactionType.Income
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey.withOpacity(0.6),
                ),
              ),

              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  // TODO: handle tap
                },
                child: Icon(Icons.edit, color: Color(0xFF00D09E), size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Transaction tx) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.transaction_delete_title),
        content: Text(l10n.transaction_delete_message(tx.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final viewModel = context.read<TransactionViewModel>();
              await viewModel.deleteTransaction(
                tx.id,
                userId: tx.userId,
                categoryId: widget.category.id,
              );
              Navigator.pop(context);
            },
            child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
