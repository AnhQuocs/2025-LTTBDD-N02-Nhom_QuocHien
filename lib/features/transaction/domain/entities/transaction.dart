import 'package:hive/hive.dart';
part 'transaction.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  Income,
  @HiveField(1)
  Expense,
}

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String title;

  @HiveField(3)
  double price;

  @HiveField(4)
  String category;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String? note;

  @HiveField(7)
  TransactionType type;

  Transaction({
    required this.id,
    required this.userId,
    required this.title,
    required this.price,
    required this.category,
    required this.date,
    required this.note,
    required this.type,
  });
}
