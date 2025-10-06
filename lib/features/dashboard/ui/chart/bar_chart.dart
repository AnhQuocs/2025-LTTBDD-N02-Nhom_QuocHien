import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/viewmodel/auth_viewmodel.dart';
import '../../../transaction/domain/entities/daily_summary.dart';
import '../../../transaction/presentation/viewmodel/transaction_view_model.dart';

class DailySummaryChart extends StatelessWidget {
  final List<DailySummary> summaries;
  final VoidCallback onSelectWeek;

  const DailySummaryChart({
    super.key,
    required this.summaries,
    required this.onSelectWeek,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<TransactionViewModel>();
    String _fmt(DateTime d) => '${d.day}/${d.month}';

    final barGroups = summaries.map((day) {
      return BarChartGroupData(
        x: day.date.weekday - 1,
        barRods: [
          BarChartRodData(
            toY: day.income.abs().toDouble(),
            color: const Color(0xFF00D09E),
            width: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: day.expense.abs().toDouble(),
            color: const Color(0xFF2F80ED),
            width: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        barsSpace: 4,
      );
    }).toList();

    final maxY = (summaries.isEmpty
        ? 10000
        : summaries
        .map((e) => [e.income.abs(), e.expense.abs()].reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b) *
        1.2);

    final safeMaxY = maxY < 1000 ? 1000 : maxY;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF8E3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (viewModel.startOfWeek != null && viewModel.endOfWeek != null)
                    Text(
                      "${_fmt(viewModel.startOfWeek!)} - ${_fmt(viewModel.endOfWeek!)}",
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  Text(
                    "${l10n.income} & ${l10n.expenses}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month_rounded, color: Colors.black87, size: 22),
                onPressed: onSelectWeek,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Chart
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: safeMaxY / 3,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: safeMaxY / 3,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value ~/ 1000)}k',
                          style: const TextStyle(color: Colors.black54, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        return Text(
                          days[value.toInt() % 7],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: barGroups,
                maxY: safeMaxY.toDouble(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}