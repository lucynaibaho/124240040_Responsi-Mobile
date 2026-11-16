import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'services/local_database_service.dart';
import 'services/local_storage_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final database = await LocalDatabaseService.open();
  Get.put(database, permanent: true);

  final preferences = await SharedPreferences.getInstance();
  Get.put(LocalStorageService(preferences), permanent: true);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SpaceNews Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
    );
  }
}
