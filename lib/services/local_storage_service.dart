import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

class LocalStorageService {
  LocalStorageService(this._preferences);

  static const _sessionKey = 'session.v1';

  final SharedPreferences _preferences;

  AppUser? getSession() {
    final encoded = _preferences.getString(_sessionKey);
    if (encoded == null) return null;

    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Data sesi lokal tidak valid.');
    }
    return AppUser.fromJson(decoded);
  }

  Future<void> saveSession(AppUser user) async {
    final saved = await _preferences.setString(_sessionKey, jsonEncode(user.toJson()));
    if (!saved) {
      throw StateError('Data sesi tidak dapat disimpan ke penyimpanan lokal.');
    }
  }

  Future<void> clearSession() async {
    final removed = await _preferences.remove(_sessionKey);
    if (!removed && _preferences.containsKey(_sessionKey)) {
      throw StateError('Sesi tidak dapat dihapus dari penyimpanan lokal.');
    }
  }
}
