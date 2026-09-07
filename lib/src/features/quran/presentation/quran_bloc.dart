import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/entities.dart';
import '../domain/repositories/quran_repository.dart';
import '../domain/usecases/get_all_surahs.dart';
import '../domain/usecases/get_quran_page.dart';
import '../domain/usecases/search_ayahs.dart';

enum QuranStatus { initial, loading, loaded, error }

class QuranState {
  final QuranStatus status;
  final List<Surah> surahs;
  final QuranPage? currentPage;
  final int currentPageIndex;
  final int lastReadPage;
  final String? lastAyahKey;
  final String? errorMessage;

  const QuranState({
    this.status = QuranStatus.initial,
    this.surahs = const [],
    this.currentPage,
    this.currentPageIndex = 0,
    this.lastReadPage = 1,
    this.lastAyahKey,
    this.errorMessage,
  });

  QuranState copyWith({
    QuranStatus? status,
    List<Surah>? surahs,
    QuranPage? currentPage,
    int? currentPageIndex,
    int? lastReadPage,
    String? lastAyahKey,
    String? errorMessage,
  }) =>
      QuranState(
        status: status ?? this.status,
        surahs: surahs ?? this.surahs,
        currentPage: currentPage ?? this.currentPage,
        currentPageIndex: currentPageIndex ?? this.currentPageIndex,
        lastReadPage: lastReadPage ?? this.lastReadPage,
        lastAyahKey: lastAyahKey ?? this.lastAyahKey,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

sealed class QuranEvent {
  const QuranEvent();
}

final class LoadSurahs extends QuranEvent {
  const LoadSurahs();
}

final class LoadQuranPage extends QuranEvent {
  final int pageNumber;
  const LoadQuranPage(this.pageNumber);
}

final class GoToPage extends QuranEvent {
  final int pageIndex;
  const GoToPage(this.pageIndex);
}

final class LoadLastReadPosition extends QuranEvent {
  const LoadLastReadPosition();
}

final class SaveLastReadPosition extends QuranEvent {
  final int page;
  final String ayahKey;
  const SaveLastReadPosition({required this.page, required this.ayahKey});
}

final class SearchAyahs extends QuranEvent {
  final String query;
  const SearchAyahs(this.query);
}

class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final GetAllSurahsUseCase _getAllSurahs;
  final GetQuranPageUseCase _getQuranPage;
  final SearchAyahsUseCase _searchAyahs;
  final QuranRepository _quranRepository;

  QuranBloc({
    required GetAllSurahsUseCase getAllSurahs,
    required GetQuranPageUseCase getQuranPage,
    required SearchAyahsUseCase searchAyahs,
    required QuranRepository quranRepository,
  })  : _getAllSurahs = getAllSurahs,
        _getQuranPage = getQuranPage,
        _searchAyahs = searchAyahs,
        _quranRepository = quranRepository,
        super(const QuranState()) {
    on<LoadSurahs>(_onLoadSurahs);
    on<LoadQuranPage>(_onLoadQuranPage);
    on<GoToPage>(_onGoToPage);
    on<LoadLastReadPosition>(_onLoadLastReadPosition);
    on<SaveLastReadPosition>(_onSaveLastReadPosition);
    on<SearchAyahs>(_onSearchAyahs);
  }

  Future<void> _onLoadSurahs(LoadSurahs event, Emitter<QuranState> emit) async {
    emit(state.copyWith(status: QuranStatus.loading));
    final result = await _getAllSurahs();
    result.fold(
      (failure) => emit(state.copyWith(
        status: QuranStatus.error,
        errorMessage: failure.message,
      )),
      (surahs) => emit(state.copyWith(
        status: QuranStatus.loaded,
        surahs: surahs,
      )),
    );
  }

  Future<void> _onLoadQuranPage(
    LoadQuranPage event,
    Emitter<QuranState> emit,
  ) async {
    final pageNumber = event.pageNumber.clamp(1, 604).toInt();
    emit(state.copyWith(status: QuranStatus.loading));

    final result = await _getQuranPage(pageNumber);
    await result.fold<Future<void>>(
      (failure) async {
        emit(state.copyWith(
          status: QuranStatus.error,
          errorMessage: failure.message,
        ));
      },
      (page) async {
        final firstAyahKey = page.ayahs.isNotEmpty
            ? page.ayahs.first.key
            : (state.lastAyahKey ?? '1:1');
        final saveResult = await _quranRepository.saveLastReadPosition(
          page: page.pageNumber,
          ayahKey: firstAyahKey,
        );

        saveResult.fold(
          (failure) => emit(state.copyWith(
            status: QuranStatus.error,
            currentPage: page,
            lastReadPage: page.pageNumber,
            errorMessage: failure.message,
          )),
          (_) => emit(state.copyWith(
            status: QuranStatus.loaded,
            currentPage: page,
            lastReadPage: page.pageNumber,
            lastAyahKey: firstAyahKey,
            errorMessage: null,
          )),
        );
      },
    );
  }

  void _onGoToPage(GoToPage event, Emitter<QuranState> emit) {
    emit(state.copyWith(currentPageIndex: event.pageIndex));
  }

  Future<void> _onLoadLastReadPosition(
    LoadLastReadPosition event,
    Emitter<QuranState> emit,
  ) async {
    final result = await _quranRepository.getLastReadPosition();
    await result.fold<Future<void>>(
      (failure) async {
        emit(state.copyWith(
          status: QuranStatus.error,
          errorMessage: failure.message,
        ));
      },
      (position) async {
        emit(state.copyWith(
          lastReadPage: position.page.clamp(1, 604).toInt(),
          lastAyahKey: position.ayahKey,
        ));
        add(LoadQuranPage(position.page));
      },
    );
  }

  Future<void> _onSaveLastReadPosition(
    SaveLastReadPosition event,
    Emitter<QuranState> emit,
  ) async {
    final page = event.page.clamp(1, 604).toInt();
    final result = await _quranRepository.saveLastReadPosition(
      page: page,
      ayahKey: event.ayahKey,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: QuranStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        lastReadPage: page,
        lastAyahKey: event.ayahKey,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onSearchAyahs(
    SearchAyahs event,
    Emitter<QuranState> emit,
  ) async {
    if (event.query.isEmpty) return;
    final result = await _searchAyahs(event.query);
    result.fold(
      (failure) => emit(state.copyWith(
        status: QuranStatus.error,
        errorMessage: failure.message,
      )),
      (_) {},
    );
  }
}
