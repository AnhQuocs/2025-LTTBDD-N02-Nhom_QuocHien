import 'package:fin_track/features/dashboard/ui/chart/segmented_control.dart';
import 'package:fin_track/features/dashboard/ui/transaction_today_card.dart';
import 'package:fin_track/features/transaction/presentation/viewmodel/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/viewmodel/auth_viewmodel.dart';
import '../../transaction/domain/entities/daily_budget.dart';
import 'expense_progress_bar.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(Locale locale)? onLocaleChange;

  const DashboardScreen({super.key, this.onLocaleChange});

  @override
  State<StatefulWidget> createState() => _DashboardScreen();
}

class _DashboardScreen extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final transactionViewModel = Provider.of<TransactionViewModel>(context, listen: false);
      transactionViewModel.loadDailyBudget();
      transactionViewModel.loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final transactionViewModel = Provider.of<TransactionViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);

    if (authViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (authViewModel.user == null) {
      return const Center(child: Text("Error"));
    } else {
      final user = authViewModel.user;

      return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xFF00D09E),
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SingleChildScrollView(
                    child: Padding(
                        padding: EdgeInsets.only(top: 48),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${l10n.hi}! ${l10n.welcome_back}",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),

                                      Text(
                                        "${user!.displayName}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            height: 0.5
                                        ),
                                      )
                                    ],
                                  ),

                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(100)
                                    ),
                                    child: Icon(Icons.settings, color: Colors.black.withOpacity(0.7),),
                                  )
                                ],
                              ),
                            ),

                            SizedBox(height: 24,),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.arrow_circle_up, color: Colors.black, size: 20,),
                                        SizedBox(width: 4,),
                                        Text(
                                          l10n.total_balance,
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        )
                                      ],
                                    ),

                                    Text(
                                      "${transactionViewModel.totalBalance.toStringAsFixed(0)} ₫",
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500
                                      ),
                                    )
                                  ],
                                ),

                                Container(
                                  width: 1,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8)
                                  ),
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.arrow_circle_down, color: Colors.black, size: 20,),
                                        SizedBox(width: 4,),
                                        Text(
                                          l10n.total_expense,
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        )
                                      ],
                                    ),

                                    Text(
                                      "${transactionViewModel.totalExpense.toStringAsFixed(0)} ₫",
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: Color(0xFF0068FF),
                                          fontWeight: FontWeight.w500
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),

                            SizedBox(height: 16,),

                            if (transactionViewModel.todayBudget == null ||
                                transactionViewModel.todayBudget?.limit == 0)
                              Column(
                                children: [
                                  Text(
                                    l10n.set_goal,
                                    style: TextStyle(
                                        fontSize: 16
                                    ),
                                  ),

                                  SizedBox(height: 8,),

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
                                                l10n.set_now,
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
                              )
                            else
                              ExpenseProgressBar(
                                spent: transactionViewModel.todayBudget?.spent ?? 0,
                                limit: transactionViewModel.todayBudget?.limit ?? 0,
                              )
                          ],
                        )
                    ),
                  )
              ),
            ),

            Expanded(
              flex: 6,
              child: SafeArea(
                top: false,
                bottom: false,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1FFF3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch, // cho full width
                            children: [
                              TransactionTodayCard(),

                              const SizedBox(height: 8),

                              SegmentedControl(),

                              SizedBox(height: 80,)
                            ],
                          ),
                        ),
                      )
                  ),
                ),
              )
            )
          ],
        ),
      );
    }
  }
}

Future<void> showDailyBudgetDialog(BuildContext context) async {
  final _formKey = GlobalKey<FormState>();
  final l10n = AppLocalizations.of(context)!;
  double? limit;

  final vm = Provider.of<TransactionViewModel>(context, listen: false);

  return showDialog(
    context: context,
    builder: (context) {
      final currentLimit = vm.todayBudget?.limit;

      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          l10n.set_daily_spending,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black
          ),
        ),
        content: Form(
          key: _formKey,
          child: TextFormField(
            initialValue: currentLimit != null && currentLimit > 0
                ? NumberFormat.decimalPattern('vi').format(currentLimit)
                : "",
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.daily_spending_limit,
              labelStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.account_balance_wallet, color: Colors.black),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 12, top: 12),
                child: Text(
                  "₫",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return l10n.invalid_number;
              try {
                NumberFormat.decimalPattern('vi').parse(val.trim());
                return null;
              } catch (_) {
                return l10n.invalid_number;
              }
            },
            onSaved: (val) {
              if (val == null) return;
              limit = NumberFormat.decimalPattern('vi').parse(val.trim()).toDouble();
            },
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: TextStyle(color: Colors.black)),
          ),

          TextButton(
            onPressed: (currentLimit == null || currentLimit == 0)
                ? null
                : () async {
              await vm.updateDailyBudget(
                DailyBudget(
                  date: DateTime.now(),
                  limit: 0,
                  spent: 0,
                ),
              );
              Navigator.pop(context);
            },
            child: Text(
              l10n.delete,
              style: TextStyle(color: Colors.red),
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00D09E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                final dailyBudget = DailyBudget(
                  date: DateTime.now(),
                  limit: limit!,
                  spent: 0.0,
                );
                await vm.updateDailyBudget(dailyBudget);

                Navigator.pop(context);
              }
            },
            child: Text(l10n.save, style: TextStyle(color: Colors.white),),
          ),
        ],
      );
    },
  );
}