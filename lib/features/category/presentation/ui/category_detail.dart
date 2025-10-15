import 'package:fin_track/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:fin_track/features/dashboard/ui/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TransactionViewModel>();
    final transactions = viewModel.categoryTransactions;

    // Tính tổng income/expense cho category hiện tại
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    for (var tx in transactions) {
      if (tx.type == TransactionType.Income) {
        totalIncome += tx.price;
      } else {
        totalExpense += tx.price;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: const Color(0xFF00D09E),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSummary(totalIncome, totalExpense),
          Divider(height: 1, color: Colors.grey[300]),
          Expanded(
            child: transactions.isEmpty
                ? Center(
              child: Text(
                "No transactions yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) =>
                  _buildTransactionItem(transactions[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TransactionForm(category: widget.category),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummary(double totalIncome, double totalExpense) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                'Total Income',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 4),
              Text(
                currencyFormat.format(totalIncome),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'Total Expense',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 4),
              Text(
                currencyFormat.format(totalExpense),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction tx) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onLongPress: () => _showDeleteDialog(tx),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tên transaction + date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              // Giá trị + loại
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
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Transaction tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Transaction'),
        content: Text('Are you sure you want to delete "${tx.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
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
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}