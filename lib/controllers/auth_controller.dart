import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/app_user.dart';
import '../routes/app_pages.dart';
import '../services/auth_services.dart';
import '../theme/app_theme.dart';

class AuthController extends GetxController {
  AuthController(this._authService) {
    currentUser.value = _authService.restoreSession();
  }

  final AuthService _authService;
  final Rxn<AppUser> currentUser = Rxn<AppUser>();
  final RxBool isBusy = false.obs;

  bool get isLoggedIn => currentUser.value != null;

  Future<void> login({required String email, required String password}) async {
    isBusy.value = true;
    try {
      currentUser.value = await _authService.login(
        email: email,
        password: password,
      );
      Get.offAllNamed(AppRoutes.home);
    } on Object catch (error) {
      _showError('Login gagal', error);
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isBusy.value = true;
    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar(
        'Registrasi berhasil',
        'Silakan login untuk melanjutkan, ${user.name}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.primary,
        colorText: Colors.white,
      );
    } on Object catch (error) {
      _showError('Registrasi gagal', error);
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> logout() async {
    isBusy.value = true;
    try {
      await _authService.logout();
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.login);
    } on Object catch (error) {
      _showError('Logout gagal', error);
    } finally {
      isBusy.value = false;
    }
  }

  void _showError(String title, Object error) {
    Get.snackbar(
      title,
      error.toString(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
    );
  }
}
