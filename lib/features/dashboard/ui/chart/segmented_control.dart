import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../transaction/presentation/viewmodel/transaction_view_model.dart';
import 'layout/daily_layout.dart';

class SegmentedControl extends StatefulWidget {
  const SegmentedControl({super.key});

  @override
  State<SegmentedControl> createState() => _SegmentedControlState();
}

class _SegmentedControlState extends State<SegmentedControl> {
  int groupValue = 0;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TransactionViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          CupertinoSlidingSegmentedControl<int>(
            backgroundColor: const Color(0xFFDFF7E2),
            thumbColor: const Color(0xFF00D09E),
            groupValue: groupValue,
            children: {
              0: buildSegment(l10n.daily),
              1: buildSegment(l10n.weekly),
              2: buildSegment(l10n.monthly),
            },
            onValueChanged: (value) {
              setState(() => groupValue = value!);
            },
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: buildContent(groupValue, viewModel),
          ),
        ],
      ),
    );
  }

  Widget buildSegment(String text) => Padding(
    padding: const EdgeInsets.all(12),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16),
    ),
  );

  Widget buildContent(int value, TransactionViewModel viewModel) {
    switch (value) {
      case 0:
        return const DailyLayout();
      case 1:
        return _buildWeeklyLayout();
      case 2:
        return _buildMonthlyLayout();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWeeklyLayout() => Container(
    key: const ValueKey('weekly'),
    alignment: Alignment.center,
    child: const Text(
      'Weekly Layout',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildMonthlyLayout() => Container(
    key: const ValueKey('monthly'),
    alignment: Alignment.center,
    child: const Text(
      'Monthly Layout',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );
}