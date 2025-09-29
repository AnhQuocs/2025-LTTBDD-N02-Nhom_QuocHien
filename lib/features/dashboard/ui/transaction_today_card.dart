import 'package:fin_track/features/dashboard/ui/expense_progress_bar.dart';
import 'package:fin_track/features/transaction/presentation/viewmodel/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../transaction/domain/entities/daily_summary.dart';

class TransactionTodayCard extends StatelessWidget {
  const TransactionTodayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final transactionViewModel = context.watch<TransactionViewModel>();
    final today = DateTime.now();

    final summary = transactionViewModel.summaries.firstWhere(
        (s) =>
            s.date.year == today.year &&
            s.date.month == today.month &&
            s.date.day == today.day,
      orElse: () => DailySummary(date: today, income: 0, expense: 0),
    );

    final total = summary.income - summary.expense;

    return SizedBox(
      height: 180,
      child: Card(
        elevation: 3,
        color: Color(0xFF00D09E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(32)),
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.total,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500
                      ),
                    ),

                    Text(
                      currencyFormat.format(total),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
              ),

              Container(
                width: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.white,
              ),

              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.attach_money, size: 32,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.income,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500
                              ),
                            ),

                            Text(
                              currencyFormat.format(summary.income),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),
                            )
                          ],
                        ),
                      ],
                    ),

                    Container(
                      height: 2,
                      color: Colors.white,
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.money_off, size: 32,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.expenses,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500
                              ),
                            ),

                            Text(
                              "-${currencyFormat.format(summary.expense)}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),
                            )
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}