import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import 'dashboard_screen.dart';

class ExpenseProgressBar extends StatelessWidget {
  final double spent;
  final double limit;

  const ExpenseProgressBar({
    super.key,
    required this.spent,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = (limit > 0) ? (spent / limit) : 0.0;
    final percentValue = progress * 100;
    final percent = percentValue.toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16)
              ),
            ),

            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 22,
                        decoration: BoxDecoration(
                          // gradient: const LinearGradient(
                          //   colors: [Colors.deepPurple, Colors.teal],
                          //   begin: Alignment.centerLeft,
                          //   end: Alignment.centerRight,
                          // ),
                          color: Colors.black,
                          borderRadius: BorderRadius.horizontal(
                            left: const Radius.circular(16),
                            right: value >= 1
                                ? const Radius.circular(16)
                                : Radius.zero,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),

                      if (value > 0 && value < 1)
                        Positioned(
                          right: -10,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: TextStyle(
                        color: Color(0xFF3299FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                    currencyFormat.format(limit),
                      style: TextStyle(
                        color: Color(0xFF00D09E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              if(percentValue <= 30)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.check_box_outlined, size: 18,),
                    SizedBox(width: 4,),
                    Text("$percent% ${l10n.expense_looks_good}",
                        style: Theme.of(context).textTheme.bodyMedium
                    )
                  ],
                )

              else if(percentValue > 30 && percentValue <= 50)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility, size: 18,),
                    SizedBox(width: 4,),
                    Text(
                      "$percent% ${l10n.expense_keep_an_eye}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  ],
                )

              else if(percentValue > 50 && percentValue <= 80)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_outlined, size: 18,),
                      SizedBox(width: 4,),
                      Text(
                        "$percent% ${l10n.expense_slowing_down}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  )
                else if (percentValue > 80 && percentValue < 100)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 18,),
                        SizedBox(width: 4,),
                        Text(
                          "$percent% ${l10n.expense_almost_limit}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.block, size: 18, color: Colors.red),
                        SizedBox(width: 4,),
                        Text(
                          "$percent% ${l10n.expense_over_limit}",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                        )
                      ],
                    ),

              SizedBox(height: 12,),

              InkWell(
                onTap: () {
                  showDailyBudgetDialog(context);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF00416A),
                          Color(0xFF26B47E),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF00416A).withOpacity(0.4),
                          blurRadius: 4,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wallet, size: 18, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            l10n.update,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

final currencyFormat = NumberFormat.currency(
  locale: 'vi_VN',
  symbol: '₫',
  decimalDigits: 0,
);