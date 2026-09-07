import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/src/core/error/failures.dart';
import 'package:imaanly/src/features/azkar/domain/entities/azkar.dart';
import 'package:imaanly/src/features/azkar/domain/repositories/azkar_repository.dart';
import 'package:imaanly/src/features/azkar/presentation/azkar_bloc.dart';

class MockAzkarRepository implements AzkarRepository {
  final Either<Failure, List<AzkarCategory>> categoriesResponse;
  final Either<Failure, List<AzkarItem>> azkarByCategoryResponse;
  final Either<Failure, List<AzkarItem>> azkarByTypeResponse;
  final Either<Failure, int> remainingCountResponse;
  final Either<Failure, void> saveCountResponse;
  final Either<Failure, void> resetCountsResponse;
  int saveRemainingCountCalls = 0;
  int resetDailyCountsCalls = 0;
  MockAzkarRepository({required this.categoriesResponse, this.azkarByCategoryResponse = const Right([]), this.azkarByTypeResponse = const Right([]), this.remainingCountResponse = const Right(0), this.saveCountResponse = const Right(null), this.resetCountsResponse = const Right(null)});
  @override Future<Either<Failure, List<AzkarCategory>>> getCategories() async => categoriesResponse;
  @override Future<Either<Failure, List<AzkarItem>>> getAzkarByCategory(int categoryId) async => azkarByCategoryResponse;
  @override Future<Either<Failure, AzkarItem>> getAzkarItem(int id) async => throw UnimplementedError();
  @override Future<Either<Failure, List<AzkarItem>>> getAzkarByType(AzkarType type) async => azkarByTypeResponse;
  @override Future<Either<Failure, int>> getRemainingCount(int azkarId) async => remainingCountResponse;
  @override Future<Either<Failure, void>> saveRemainingCount({required int azkarId, required int remaining}) async { saveRemainingCountCalls++; return saveCountResponse; }
  @override Future<Either<Failure, void>> resetDailyCounts() async { resetDailyCountsCalls++; return resetCountsResponse; }
}

AzkarCategory _category(int id, String ar, String en, int count) => AzkarCategory(id: id, nameArabic: ar, nameEnglish: en, iconKey: 'wb_sunny', azkarCount: count);
AzkarItem _item() => AzkarItem(id: 1, categoryId: 1, textArabic: 'سبحان الله', textTranslation: 'Glory be to Allah', count: 33, reference: 'Muslim', type: AzkarType.morning);

void main() {
  group('AzkarBloc', () {
    late AzkarBloc bloc;
    setUp(() { bloc = AzkarBloc(azkarRepository: MockAzkarRepository(categoriesResponse: Right([_category(1, 'أذكار الصباح', 'Morning Azkar', 5), _category(2, 'أذكار المساء', 'Evening Azkar', 3)]), azkarByTypeResponse: Right([_item()]), remainingCountResponse: const Right(33))); });
    tearDown(() => bloc.close());
    test('initial state is AzkarState with status initial', () { expect(bloc.state.status, AzkarStatus.initial); expect(bloc.state.categories, isEmpty); expect(bloc.state.currentAzkar, isEmpty); });
    test('LoadCategories emits [loading, loaded] with categories', () async { final states = <AzkarState>[]; final subscription = bloc.stream.listen(states.add); bloc.add(const LoadCategories()); await bloc.stream.where((state) => state.status == AzkarStatus.loaded).first; await subscription.cancel(); expect(states.first.status, AzkarStatus.loading); expect(states.last.status, AzkarStatus.loaded); expect(states.last.categories.length, 2); expect(states.last.categories.first.nameArabic, 'أذكار الصباح'); });
    test('LoadCategories on error emits [loading, error]', () async { final errorBloc = AzkarBloc(azkarRepository: MockAzkarRepository(categoriesResponse: Left(const Failure.network(message: 'No connection')))); final states = <AzkarState>[]; final subscription = errorBloc.stream.listen(states.add); errorBloc.add(const LoadCategories()); await errorBloc.stream.where((state) => state.status == AzkarStatus.error).first; await subscription.cancel(); expect(states.first.status, AzkarStatus.loading); expect(states.last.status, AzkarStatus.error); expect(states.last.errorMessage, 'No connection'); await errorBloc.close(); });
    test('LoadAzkarByType sets selectedType and loads items', () async { final states = <AzkarState>[]; final subscription = bloc.stream.listen(states.add); bloc.add(const LoadAzkarByType(AzkarType.morning)); await bloc.stream.where((state) => state.status == AzkarStatus.loaded).first; await subscription.cancel(); expect(states.last.status, AzkarStatus.loaded); expect(states.last.selectedType, AzkarType.morning); expect(states.last.currentAzkar.length, 1); });
    test('DecrementAzkarCount decrements remaining count', () async { bloc.add(const LoadAzkarByType(AzkarType.morning)); await bloc.stream.where((state) => state.status == AzkarStatus.loaded).first; final states = <AzkarState>[]; final subscription = bloc.stream.listen(states.add); bloc.add(const DecrementAzkarCount(1)); await bloc.stream.where((state) => state.remainingCounts[1] == 32).first; await subscription.cancel(); expect(states.last.remainingCounts[1], 32); });
    test('DecrementAzkarCount does nothing when count is 0', () async { final zeroBloc = AzkarBloc(azkarRepository: MockAzkarRepository(categoriesResponse: const Right([]), azkarByTypeResponse: Right([_item()]), remainingCountResponse: const Right(0))); zeroBloc.add(const LoadAzkarByType(AzkarType.morning)); await zeroBloc.stream.where((state) => state.status == AzkarStatus.loaded).first; final stateBefore = zeroBloc.state.remainingCounts[1]; zeroBloc.add(const DecrementAzkarCount(1)); await Future.delayed(const Duration(milliseconds: 100)); expect(zeroBloc.state.remainingCounts[1], stateBefore); await zeroBloc.close(); });
    test('ResetDailyCounts resets counts to original item counts', () async { bloc.add(const LoadAzkarByType(AzkarType.morning)); await bloc.stream.where((state) => state.status == AzkarStatus.loaded).first; bloc.add(const ResetDailyCounts()); await bloc.stream.where((state) => state.remainingCounts[1] == 33).first; expect(bloc.state.remainingCounts[1], 33); });
  });
}
