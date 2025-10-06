import 'package:fin_track/features/dashboard/ui/chart/summary_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/presentation/viewmodel/auth_viewmodel.dart';
import '../../../../transaction/presentation/viewmodel/transaction_view_model.dart';

class DailyLayout extends StatefulWidget {
  const DailyLayout({super.key});

  @override
  State<DailyLayout> createState() => _DailyLayoutState();
}

class _DailyLayoutState extends State<DailyLayout> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final viewModel = context.read<TransactionViewModel>();
      final authViewModel = context.read<AuthViewModel>();

      if (authViewModel.user != null) {
        // 🔹 Load dữ liệu 7 ngày gần nhất
        viewModel.loadDailySummaries(userId: authViewModel.user!.uid);
      }
      _initialized = true;
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
      key: const ValueKey('daily'),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: viewModel.loading
          ? const Center(child: CircularProgressIndicator())
          : SummaryChart(
        period: SummaryPeriod.daily,
        summaries: viewModel.summaries,
        startDate: viewModel.startOfWeek,
        endDate: viewModel.endOfWeek,
        onSelectPeriod: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2024, 1),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            await viewModel.loadDailySummaries(
              userId: user.uid,
              date: picked,
            );
          }
        },
      )
    );
  }
}