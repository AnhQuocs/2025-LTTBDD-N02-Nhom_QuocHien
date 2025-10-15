import 'package:fin_track/features/dashboard/ui/chart/summary_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/presentation/viewmodel/auth_viewmodel.dart';
import '../../../../transaction/presentation/viewmodel/transaction_view_model.dart';

class WeeklyLayout extends StatefulWidget {
  const WeeklyLayout({super.key});

  @override
  State<WeeklyLayout> createState() => _WeeklyLayoutState();
}

class _WeeklyLayoutState extends State<WeeklyLayout> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final viewModel = context.read<TransactionViewModel>();
      final authViewModel = context.read<AuthViewModel>();

      if (authViewModel.user != null) {
        viewModel.loadWeeklySummaries(userId: authViewModel.user!.uid);
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
      key: const ValueKey('weekly'),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: viewModel.loading
          ? const Center(child: CircularProgressIndicator())
          : SummaryChart(
        period: SummaryPeriod.weekly,
        summaries: viewModel.weeklySummaries,
        startDate: viewModel.startOfMonth ?? DateTime.now(),
        endDate: viewModel.endOfMonth ?? DateTime.now(),
        onSelectPeriod: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: viewModel.startOfMonth ?? DateTime.now(),
            firstDate: DateTime(2024, 1),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            await viewModel.loadWeeklySummaries(
              userId: user.uid,
              month: picked,
            );
          }
        },
      ),
    );

  }
}