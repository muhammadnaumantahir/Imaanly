import 'package:shared_preferences/shared_preferences.dart';

import '../domain/imaanly_personalization.dart';

class ImaanlyPersonalizationRepository {
  ImaanlyPersonalizationRepository(this._preferences);

  static const String _key = 'imaanly.personalization.v1';
  final SharedPreferences _preferences;

  ImaanlyPersonalization load() {
    final raw = _preferences.getString(_key);
    if (raw == null || raw.isEmpty) return const ImaanlyPersonalization();
    try {
      return ImaanlyPersonalization.decode(raw);
    } catch (_) {
      return const ImaanlyPersonalization();
    }
  }

  Future<void> save(ImaanlyPersonalization value) {
    return _preferences.setString(_key, value.encode());
  }

  Future<void> reset() => _preferences.remove(_key);

  String exportJson() => load().encode();

  Future<bool> importJson(String raw) async {
    try {
      final value = ImaanlyPersonalization.decode(raw);
      await save(value);
      return true;
    } catch (_) {
      return false;
    }
  }
}
