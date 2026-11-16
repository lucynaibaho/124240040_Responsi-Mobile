import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../models/app_user.dart';
import 'local_database_service.dart';
import 'local_storage_service.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService(this._storage, this._database);

  final LocalStorageService _storage;
  final LocalDatabaseService _database;

  AppUser? restoreSession() => _storage.getSession();

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (_database.getAccount(normalizedEmail) != null) {
      throw const AuthException('Email sudah terdaftar. Silakan masuk.');
    }

    final salt = _newSalt();
    final user = AppUser(name: name.trim(), email: normalizedEmail);
    await _database.saveAccount(
      email: normalizedEmail,
      account: {
        ...user.toJson(),
        'salt': salt,
        'passwordHash': _hashPassword(salt, password),
      },
    );
    return user;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final account = _database.getAccount(normalizedEmail);
    if (account == null ||
        account['salt'] is! String ||
        account['passwordHash'] is! String ||
        account['passwordHash'] !=
            _hashPassword(account['salt'] as String, password)) {
      throw const AuthException('Email atau kata sandi tidak sesuai.');
    }

    final user = AppUser.fromJson(account);
    await _storage.saveSession(user);
    return user;
  }

  Future<void> logout() => _storage.clearSession();

  String _newSalt() {
    final random = Random.secure();
    return List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  String _hashPassword(String salt, String password) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }
}
