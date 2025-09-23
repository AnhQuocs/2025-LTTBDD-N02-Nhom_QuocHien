import 'package:hive/hive.dart';
part 'daily_budget.g.dart';

@HiveType(typeId: 2)
class DailyBudget extends HiveObject {
  @HiveField(0)
  DateTime date;
  @HiveField(1)
  double limit;
  @HiveField(2)
  double spent;

  DailyBudget({required this.date, required this.limit, this.spent = 0});
}