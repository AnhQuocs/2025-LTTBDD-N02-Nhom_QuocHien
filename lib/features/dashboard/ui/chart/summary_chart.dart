import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../transaction/domain/entities/daily_summary.dart';

enum SummaryPeriod { daily, weekly, monthly }

class SummaryChart extends StatelessWidget {
  final ScrollController? scrollController;
  final SummaryPeriod period;
  final List<DailySummary> summaries;
  final VoidCallback onSelectPeriod;
  final DateTime? startDate;
  final DateTime? endDate;

  const SummaryChart({
    super.key,
    required this.period,
    required this.summaries,
    required this.onSelectPeriod,
    this.startDate,
    this.endDate,
    this.scrollController,
  });

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _buildPeriodLabel(AppLocalizations l10n) {
    if (startDate == null || endDate == null) return '';

    switch (period) {
      case SummaryPeriod.daily:
        return '${_fmt(startDate!)} - ${_fmt(endDate!)}';
      case SummaryPeriod.weekly:
        return '${_fmt(startDate!)} - ${_fmt(endDate!)}';
      case SummaryPeriod.monthly:
        final start = '${startDate!.month}/${startDate!.year}';
        final end = '${endDate!.month}/${endDate!.year}';
        return '$start - $end';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final barGroups = _buildBarGroups();

    final maxY = (summaries.isEmpty
        ? 10000
        : summaries
        .map((e) => [e.income.abs(), e.expense.abs()]
        .reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b) *
        1.2);
    final safeMaxY = maxY < 1000 ? 1000 : maxY;

    final xLabels = _buildXLabels(l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF8E3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${l10n.income} & ${l10n.expenses}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (startDate != null && endDate != null)
                    Text(
                      _buildPeriodLabel(l10n),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2F80ED),
                      ),
                    ),
                ],
              ),
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onSelectPeriod,
                  child: const Icon(Icons.calendar_month_sharp, color: Colors.black87),
                ),
              )
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 220,
            child: period == SummaryPeriod.monthly
                ? SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              child: SizedBox(
                width: _chartWidth(),
                child: _buildBarChart(safeMaxY.toDouble(), xLabels, barGroups),
              ),
            )
                : _buildBarChart(safeMaxY.toDouble(), xLabels, barGroups),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return summaries.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.income.abs().toDouble(),
            color: const Color(0xFF00D09E),
            width: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: entry.value.expense.abs().toDouble(),
            color: const Color(0xFF2F80ED),
            width: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        barsSpace: 4,
      );
    }).toList();
  }

  List<String> _buildXLabels(AppLocalizations l10n) {
    switch (period) {
      case SummaryPeriod.daily:
        return [
          l10n.monday,
          l10n.tuesday,
          l10n.wednesday,
          l10n.thursday,
          l10n.friday,
          l10n.saturday,
          l10n.sunday,
        ];
      case SummaryPeriod.weekly:
        return ['W1', 'W2', 'W3', 'W4'];
      case SummaryPeriod.monthly:
        return [
          l10n.jan,
          l10n.feb,
          l10n.mar,
          l10n.apr,
          l10n.may,
          l10n.jun,
          l10n.jul,
          l10n.aug,
          l10n.sep,
          l10n.oct,
          l10n.nov,
          l10n.dec,
        ];
    }
  }

  Widget _buildBarChart(double safeMaxY, List<String> xLabels, List<BarChartGroupData> barGroups) {
    return BarChart(
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
                final index = value.toInt();
                if (index >= 0 && index < xLabels.length) {
                  return Text(
                    xLabels[index],
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 11,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: barGroups,
        maxY: safeMaxY.toDouble(),
      ),
    );
  }

  double _chartWidth() {
    switch (period) {
      case SummaryPeriod.daily:
        return double.infinity;
      case SummaryPeriod.weekly:
        return double.infinity;
      case SummaryPeriod.monthly:
        return 12 * 70;
    }
  }
}