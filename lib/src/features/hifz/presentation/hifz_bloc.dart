import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../domain/entities/hifz.dart';
import '../domain/repositories/hifz_repository.dart';

enum HifzStatus { initial, loading, loaded, error }

class HifzState {
  final HifzStatus status;
  final List<HifzProgress> allProgress;
  final HifzProgress? currentProgress;
  final List<HifzSession> recentSessions;
  final List<HifzProgress> dueForReview;
  final HifzStats? stats;
  final String? errorMessage;

  const HifzState({this.status = HifzStatus.initial, this.allProgress = const [], this.currentProgress, this.recentSessions = const [], this.dueForReview = const [], this.stats, this.errorMessage});

  HifzState copyWith({HifzStatus? status, List<HifzProgress>? allProgress, HifzProgress? currentProgress, List<HifzSession>? recentSessions, List<HifzProgress>? dueForReview, HifzStats? stats, String? errorMessage}) => HifzState(status: status ?? this.status, allProgress: allProgress ?? this.allProgress, currentProgress: currentProgress ?? this.currentProgress, recentSessions: recentSessions ?? this.recentSessions, dueForReview: dueForReview ?? this.dueForReview, stats: stats ?? this.stats, errorMessage: errorMessage ?? this.errorMessage);
}

sealed class HifzEvent { const HifzEvent(); }
final class LoadAllProgress extends HifzEvent { const LoadAllProgress(); }
final class LoadProgressForSurah extends HifzEvent { final int surahId; const LoadProgressForSurah(this.surahId); }
final class SaveProgress extends HifzEvent { final HifzProgress progress; const SaveProgress(this.progress); }
final class RecordSession extends HifzEvent { final HifzSession session; const RecordSession(this.session); }
final class CompleteReview extends HifzEvent { final HifzProgress progress; final HifzSession session; const CompleteReview({required this.progress, required this.session}); }
final class LoadDueForReview extends HifzEvent { const LoadDueForReview(); }
final class LoadStats extends HifzEvent { const LoadStats(); }
final class DeleteProgress extends HifzEvent { final int surahId; const DeleteProgress(this.surahId); }

class HifzBloc extends Bloc<HifzEvent, HifzState> {
  HifzBloc({required HifzRepository hifzRepository}) : _repository = hifzRepository, super(const HifzState()) {
    on<LoadAllProgress>(_loadAll);
    on<LoadProgressForSurah>(_loadSurah);
    on<SaveProgress>(_saveProgress);
    on<RecordSession>(_recordSession);
    on<CompleteReview>(_completeReview);
    on<LoadDueForReview>(_loadDue);
    on<LoadStats>(_loadStats);
    on<DeleteProgress>(_deleteProgress);
  }

  final HifzRepository _repository;

  Future<void> _loadAll(LoadAllProgress event, Emitter<HifzState> emit) async {
    emit(state.copyWith(status: HifzStatus.loading));
    final result = await _repository.getAllProgress();
    result.fold((f) => emit(state.copyWith(status: HifzStatus.error, errorMessage: f.message)), (v) => emit(state.copyWith(status: HifzStatus.loaded, allProgress: v)));
  }

  Future<void> _loadSurah(LoadProgressForSurah event, Emitter<HifzState> emit) async {
    final result = await _repository.getProgress(event.surahId);
    result.fold((f) => emit(state.copyWith(status: HifzStatus.error, errorMessage: f.message)), (v) => emit(state.copyWith(status: HifzStatus.loaded, currentProgress: v)));
  }

  Future<void> _saveProgress(SaveProgress event, Emitter<HifzState> emit) async {
    final result = await _repository.saveProgress(event.progress);
    result.fold((f) => emit(state.copyWith(status: HifzStatus.error, errorMessage: f.message)), (_) => add(const LoadAllProgress()));
  }

  Future<void> _recordSession(RecordSession event, Emitter<HifzState> emit) async {
    final result = await _repository.recordSession(event.session);
    result.fold((f) => emit(state.copyWith(status: HifzStatus.error, errorMessage: f.message)), (_) => add(const LoadAllProgress()));
  }

  Future<void> _completeReview(CompleteReview event, Emitter<HifzState> emit) async {
    emit(state.copyWith(status: HifzStatus.loading));
    final progress = await _repository.saveProgress(event.progress);
    final progressFailure = progress.fold<Failure?>((f) => f, (_) => null);
    if (progressFailure != null) return emit(state.copyWith(status: HifzStatus.error, errorMessage: progressFailure.message));
    final session = await _repository.recordSession(event.session);
    final sessionFailure = session.fold<Failure?>((f) => f, (_) => null);
    if (sessionFailure != null) return emit(state.copyWith(status: HifzStatus.error, errorMessage: sessionFailure.message));
    final all = await _repository.getAllProgress();
    final recent = await _repository.getRecentSessions();
    final due = await _repository.getDueForReview();
    final stats = await _repository.getStats();
    final failure = all.fold<Failure?>((f) => f, (_) => null) ?? recent.fold<Failure?>((f) => f, (_) => null) ?? due.fold<Failure?>((f) => f, (_) => null) ?? stats.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) return emit(state.copyWith(status: HifzStatus.error, errorMessage: failure.message));
    emit(state.copyWith(status: HifzStatus.loaded, allProgress: all.getOrElse(() => const []), recentSessions: recent.getOrElse(() => const []), dueForReview: due.getOrElse(() => const []), stats: stats.getOrElse(() => throw StateError('Hifz stats unavailable'))));
  }

  Future<void> _loadDue(LoadDueForReview event, Emitter<HifzState> emit) async {
    final result = await _repository.getDueForReview();
    result.fold((f) => emit(state.copyWith(status: HifzStatus.error, errorMessage: f.message)), (v) => emit(state.copyWith(status: HifzStatus.loaded, dueForReview: v)));
  }

  Future<void> _loadStats(LoadStats event, Emitter<HifzState> emit) async {
    final result = await _repository.getStats();
    result.fold((f) => emit(state.copyWith(status: HifzStatus.error, errorMessage: f.message)), (v) => emit(state.copyWith(status: HifzStatus.loaded, stats: v)));
  }

  Future<void> _deleteProgress(DeleteProgress event, Emitter<HifzState> emit) async {
    final result = await _repository.deleteProgress(event.surahId);
    result.fold((f) => emit(state.copyWith(status: HifzStatus.error, errorMessage: f.message)), (_) => add(const LoadAllProgress()));
  }
}
