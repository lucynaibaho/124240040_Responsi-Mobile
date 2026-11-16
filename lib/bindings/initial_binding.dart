import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../services/api_services.dart';
import '../services/auth_services.dart';
import '../services/local_database_service.dart';
import '../services/local_storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiService(), permanent: true);
    Get.put(AuthService(
      Get.find<LocalStorageService>(),
      Get.find<LocalDatabaseService>(),
    ), permanent: true);
    Get.put(AuthController(Get.find<AuthService>()), permanent: true);
  }
}
