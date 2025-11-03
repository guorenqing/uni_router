import 'package:flutter/material.dart';
import 'package:flutter_app_router/flutter_app_router.dart';
import 'package:get/get.dart';
import 'pages/home_page.dart';
import 'pages/login/services/user_manager.dart';
import 'router_config.dart';

void main() async{
  // 必须在异步操作之前调用，确保框架准备就绪
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化路由
  RouterInitializer.init(AppRouterConfig());
  // 初始化UserManager并注册为服务
  await Get.putAsync(() => UserManager().init(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetX Router Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // 初始路由
      // initialRoute: '/',
      // 主页
      home: const HomePage(),
      // 处理冷启动时的外部路由
      // onGenerateInitialRoutes: (initialRoute) {
      //   if (initialRoute.isNotEmpty && initialRoute != '/' && initialRoute != '/home') {
      //     WidgetsBinding.instance.addPostFrameCallback((_) {
      //       AppRouter().handleScheme(initialRoute);
      //     });
      //   }
      //   return [GetPageRoute(page: () => const HomePage())];
      // },
      // // 路由生成器
      // onGenerateRoute: (settings) {
      //   return GetPageRoute(
      //     page: () => const HomePage(),
      //   );
      // },
    );
  }
}
