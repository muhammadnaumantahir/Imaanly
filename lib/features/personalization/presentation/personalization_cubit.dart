import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/imaanly_personalization_repository.dart';
import '../domain/imaanly_personalization.dart';

class PersonalizationCubit extends Cubit<ImaanlyPersonalization> {
  PersonalizationCubit(this._repository) : super(_repository.load());

  final ImaanlyPersonalizationRepository _repository;

  Future<void> update(ImaanlyPersonalization next) async {
    emit(next);
    await _repository.save(next);
  }

  Future<void> reset() async {
    await _repository.reset();
    emit(const ImaanlyPersonalization());
  }
}
