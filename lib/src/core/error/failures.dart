import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Imaanly Failure Types — Sealed class pattern
/// Every async operation returns `Either<Failure, T>`
/// ZERO raw exceptions exposed to domain/presentation layers.
@freezed
sealed class Failure with _$Failure {
  // ── Network Failures ──
  const factory Failure.network({
    required String message,
    int? statusCode,
  }) = NetworkFailure;
