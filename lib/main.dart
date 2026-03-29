import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/data/providers/api_provider.dart';
import 'app/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'app/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initServices();

  runApp(const SchoolMobileApp());
}

Future<void> initServices() async {
  Get.put(AuthService());
  await Get.putAsync(() => ApiProvider().init());
  InitialBinding().dependencies();
}

class SchoolMobileApp extends StatelessWidget {
  const SchoolMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart School',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      getPages: AppRoutes.pages,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  void _checkAuth() {
    final auth = Get.find<AuthService>();

    if (!auth.isAuthenticated) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    switch (auth.role) {
      case 'ADMIN':
        Get.offAllNamed(AppRoutes.admin);
        break;
      case 'TEACHER':
        Get.offAllNamed(AppRoutes.teacher);
        break;
      case 'STUDENT':
        Get.offAllNamed(AppRoutes.student);
        break;
      case 'PARENT':
        Get.offAllNamed(AppRoutes.parent);
        break;
      default:
        Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
