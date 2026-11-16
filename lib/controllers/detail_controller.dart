import 'package:get/get.dart';

import '../models/character.dart';
import '../services/api_services.dart';
import 'favorite_controller.dart';

class DetailController extends GetxController {
  DetailController(this._apiService, this._favoriteController);

  final ApiService _apiService;
  final FavoriteController _favoriteController;
  final Rx<Character?> selectedCharacter = Rx<Character?>(null);
  final RxBool isLoading = false.obs;

  Character? get character => selectedCharacter.value;

  bool get isFavorite =>
      selectedCharacter.value != null &&
      _favoriteController.contains(selectedCharacter.value!);

  Future<void> fetchCharacter(int id) async {
    isLoading.value = true;
    try {
      selectedCharacter.value = await _apiService.fetchCharacter(id);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleFavorite() {
    final current = selectedCharacter.value;
    if (current == null) {
      return;
    }
    _favoriteController.toggleFavorite(current);
    update();
  }
}
