import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/character.dart';

class LocalDatabaseService {
  LocalDatabaseService(this._accounts, this._bookmarks);

  static const _accountsBoxName = 'accounts';
  static const _bookmarksBoxName = 'bookmarks';

  final Box<String> _accounts;
  final Box<String> _bookmarks;

  static Future<LocalDatabaseService> open() async {
    final accounts = await Hive.openBox<String>(_accountsBoxName);
    final bookmarks = await Hive.openBox<String>(_bookmarksBoxName);
    return LocalDatabaseService(accounts, bookmarks);
  }

  Map<String, dynamic>? getAccount(String email) {
    final key = email.trim().toLowerCase();
    final encoded = _accounts.get(key);
    if (encoded == null) return null;

    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Data akun lokal tidak valid.');
    }
    return decoded;
  }

  Future<void> saveAccount({
    required String email,
    required Map<String, dynamic> account,
  }) async {
    await _accounts.put(email.trim().toLowerCase(), jsonEncode(account));
  }

  bool isBookmarked(int articleId) =>
      getBookmarks().any((item) => item.id == articleId);

  List<Character> getBookmarks() {
    final encoded = _bookmarks.get('favorites');
    if (encoded == null || encoded.isEmpty) return [];

    final decoded = jsonDecode(encoded);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Character.fromJson)
        .toList();
  }

  Future<void> saveBookmarks(List<Character> articles) async {
    await _bookmarks.put(
      'favorites',
      jsonEncode(articles.map((article) => article.toJson()).toList()),
    );
  }

  Future<void> toggleBookmark(Character article) async {
    final current = getBookmarks();
    final exists = current.any((item) => item.id == article.id);
    if (exists) {
      final next = current.where((item) => item.id != article.id).toList();
      await saveBookmarks(next);
      return;
    }

    final next = [...current, article];
    await saveBookmarks(next);
  }

  Future<void> removeBookmark(int articleId) async {
    final next = getBookmarks().where((item) => item.id != articleId).toList();
    await saveBookmarks(next);
  }
}
