import 'package:fin_track/features/dashboard/ui/chart/summary_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/presentation/viewmodel/auth_viewmodel.dart';
import '../../../../transaction/presentation/viewmodel/transaction_view_model.dart';

class MonthlyLayout extends StatefulWidget {
  const MonthlyLayout({super.key});

  @override
  State<MonthlyLayout> createState() => _MonthlyLayoutState();
}

class _MonthlyLayoutState extends State<MonthlyLayout> {
  bool _initialized = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final viewModel = context.read<TransactionViewModel>();
      final authViewModel = context.read<AuthViewModel>();

      if (authViewModel.user != null) {
        viewModel.loadMonthlySummaries(userId: authViewModel.user!.uid).then((_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToCurrentMonth(viewModel);
          });
        });
      }
      _initialized = true;
    }
  }

  void _scrollToCurrentMonth(TransactionViewModel viewModel) {
    final currentMonth = DateTime.now().month;
    const double barWidth = 60;
    final targetOffset = (currentMonth - 1) * barWidth;

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TransactionViewModel>();
    final authViewModel = context.watch<AuthViewModel>();

    if (authViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (authViewModel.user == null) {
      return const Center(child: Text("Error"));
    }

    final user = authViewModel.user!;

    return Container(
      key: const ValueKey('monthly'),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: viewModel.loading
          ? const Center(child: CircularProgressIndicator())
          : SummaryChart(
        period: SummaryPeriod.monthly,
        summaries: viewModel.monthlySummaries,
        startDate: DateTime(DateTime.now().year, 1, 1),
        endDate: DateTime(DateTime.now().year, 12, 31),
        scrollController: _scrollController,
        onSelectPeriod: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2024, 1),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            await viewModel.loadMonthlySummaries(
              userId: user.uid,
              date: picked,
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToCurrentMonth(viewModel);
            });
          }
        },
      ),
    );
  }
}