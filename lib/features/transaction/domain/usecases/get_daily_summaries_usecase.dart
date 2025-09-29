import '../entities/daily_summary.dart';
import '../repositories/transaction_repository.dart';

class GetDailySummariesUseCase {
  final TransactionRepository repository;

  GetDailySummariesUseCase(this.repository);

  Future<List<DailySummary>> call({String? userId}) {
    return repository.getDailySummaries(userId: userId);
  }
}