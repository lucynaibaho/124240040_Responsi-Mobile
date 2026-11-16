import 'package:get/get.dart';

import '../models/character.dart';
import '../services/api_services.dart';

class CharacterController extends GetxController {
  CharacterController(this._apiService);

  final ApiService _apiService;
  final RxList<Character> characters = <Character>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> fetchCharacters({String? status, String? name}) async {
    isLoading.value = true;
    try {
      final items = await _apiService.fetchCharacters(status: status, name: name);
      characters.assignAll(items);
    } finally {
      isLoading.value = false;
    }
  }
}
