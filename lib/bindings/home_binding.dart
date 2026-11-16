import 'package:get/get.dart';

import '../controllers/character_controller.dart';
import '../controllers/favorite_controller.dart';
import '../controllers/navigation_controller.dart';
import '../services/api_services.dart';
import '../services/local_database_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FavoriteController(Get.find<LocalDatabaseService>()));
    Get.put(CharacterController(Get.find<ApiService>()));
    Get.put(NavigationController());
  }
}
