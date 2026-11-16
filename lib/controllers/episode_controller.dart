import 'package:get/get.dart';

import '../models/episode.dart';
import '../services/api_services.dart';

class EpisodeController extends GetxController {
  EpisodeController(this._apiService);

  final ApiService _apiService;
  final RxList<Episode> episodes = <Episode>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> fetchEpisodes() async {
    isLoading.value = true;
    try {
      episodes.assignAll(await _apiService.fetchEpisodes());
    } finally {
      isLoading.value = false;
    }
  }
}
