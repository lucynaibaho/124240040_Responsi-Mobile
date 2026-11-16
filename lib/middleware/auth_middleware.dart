import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.find<AuthController>().isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
