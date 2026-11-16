import 'package:get/get.dart';

import '../models/character.dart';
import '../services/local_database_service.dart';

class FavoriteController extends GetxController {
  FavoriteController(this._database);

  final LocalDatabaseService _database;
  final RxList<Character> favorites = <Character>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  void loadFavorites() {
    favorites.assignAll(_database.getBookmarks());
  }

  Future<bool> toggleFavorite(Character article) async {
    final updated = List<Character>.of(favorites);
    final existing = updated.indexWhere((item) => item.id == article.id);
    final added = existing < 0;
    if (added) {
      updated.add(article);
    } else {
      updated.removeAt(existing);
    }

    await _database.saveBookmarks(updated);
    favorites.assignAll(updated);
    return added;
  }

  bool contains(Character article) =>
      favorites.any((item) => item.id == article.id) ||
      _database.isBookmarked(article.id);

  Future<void> removeBookmark(int articleId) async {
    await _database.removeBookmark(articleId);
    favorites.removeWhere((item) => item.id == articleId);
  }
}
