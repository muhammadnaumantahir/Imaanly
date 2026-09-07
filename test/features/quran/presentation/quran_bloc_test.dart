import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:imaanly/src/core/error/failures.dart';
import 'package:imaanly/src/features/quran/domain/entities/entities.dart';
import 'package:imaanly/src/features/quran/domain/repositories/quran_repository.dart';
import 'package:imaanly/src/features/quran/domain/usecases/get_all_surahs.dart';
import 'package:imaanly/src/features/quran/domain/usecases/get_quran_page.dart';
import 'package:imaanly/src/features/quran/domain/usecases/search_ayahs.dart';
import 'package:imaanly/src/features/quran/presentation/quran_bloc.dart';

class _FakeQuranRepository implements QuranRepository {
  ({int page, String ayahKey}) lastRead = (page: 7, ayahKey: '2:12');

  @override
  Future<Either<Failure, List<Surah>>> getAllSurahs() async => const Right([]);

  @override
  Future<Either<Failure, Surah>> getSurah(int surahId) async =>
      Left(Failure.unknown(message: 'unused'));

  @override
  Future<Either<Failure, List<Ayah>>> getAyahsBySurah(int surahId) async =>
      const Right([]);

  @override
  Future<Either<Failure, Ayah>> getAyah(String ayahKey) async =>
      Left(Failure.unknown(message: 'unused'));

  @override
  Future<Either<Failure, QuranPage>> getPage(int pageNumber) async =>
      Left(Failure.unknown(message: 'unused'));

  @override
  Future<Either<Failure, List<QuranPage>>> getPages(int start, int end) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<Ayah>>> searchAyahs(String query) async =>
      const Right([]);

  @override
  Future<Either<Failure, ({int page, String ayahKey})>> getLastReadPosition() async =>
      Right(lastRead);

  @override
  Future<Either<Failure, void>> saveLastReadPosition({
    required int page,
    required String ayahKey,
  }) async {
    lastRead = (page: page, ayahKey: ayahKey);
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> verifyDataIntegrity(String resourceKey) async =>
      const Right(true);
}

void main() {
  test('loads and saves the persisted last-read position', () async {
    final repository = _FakeQuranRepository();
    final bloc = QuranBloc(
      getAllSurahs: GetAllSurahsUseCase(repository),
      getQuranPage: GetQuranPageUseCase(repository),
      searchAyahs: SearchAyahsUseCase(repository),
      quranRepository: repository,
    );

    bloc.add(const LoadLastReadPosition());
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<QuranState>((state) =>
          state.lastReadPage == 7 && state.lastAyahKey == '2:12')),
    );

    bloc.add(const SaveLastReadPosition(page: 8, ayahKey: '2:20'));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<QuranState>((state) =>
          state.lastReadPage == 8 && state.lastAyahKey == '2:20')),
    );

    expect(repository.lastRead, (page: 8, ayahKey: '2:20'));
    await bloc.close();
  });
}
