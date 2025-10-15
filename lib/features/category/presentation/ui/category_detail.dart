import 'package:fin_track/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../transaction/presentation/viewmodel/transaction_view_model.dart';

class CategoryDetail extends StatefulWidget {
  final String categoryName;
  final String categoryId;

  const CategoryDetail({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  @override
  State<CategoryDetail> createState() => _CategoryDetail();
}

class _CategoryDetail extends State<CategoryDetail> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<TransactionViewModel>();
      final authViewModel = context.read<AuthViewModel>();

      if (authViewModel.user != null) {
        viewModel.loadTransactionsByCategory(
          widget.categoryId,
          authViewModel.user!.uid,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<TransactionViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    final categories = viewModel.categoryTransactions;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: const Color(0xFF00D09E),
        foregroundColor: Colors.white,
      ),
    );
  }
}