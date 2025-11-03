import 'package:get/get.dart';
import 'app_router.dart';
import 'router_configurator.dart';

/// 路由初始化器
class RouterInitializer {
  /// 初始化路由（需要传入业务方配置）
  static void init(
    RouterConfigurator configurator, {
    bool defaultPopGesture = true,
    bool enableLog = true,
    Transition defaultTransition = Transition.rightToLeft,
  }) {
    // 初始化路由配置
    AppRouter().init(configurator);

    // 初始化GetX路由相关配置
    Get.config(
      defaultPopGesture: defaultPopGesture,
      enableLog: enableLog,
      defaultTransition: defaultTransition,
    );
  }
}
