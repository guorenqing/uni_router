// 业务方实现配置类
import 'package:get/get.dart';
import 'package:flutter_app_router/flutter_app_router.dart';
import 'pages/login/services/user_manager.dart';
import 'pages/login/views/login_page.dart';
import 'pages/createStudent/view/create_student_page.dart';
import 'pages/home_page.dart';
import 'pages/detail_page.dart';
import 'pages/webview_page.dart';
import 'pages/flutter_router_test_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'pages/custom_alert_dialog.dart';
import 'native_method_channel.dart';

class AppRouterConfig implements RouterConfigurator {
  @override
  String get scheme => "myapp";

  @override
  List<RouteInterceptor> get interceptors => [
    LogInterceptor(),
    LoginInterceptor(),
    StudentInterceptor()
  ];

  @override
  List<RouteConfig> get routes => [
    /// 首页
    RouteConfig.page(
      path: '/home',
      handler: (params) => const HomePage(),
    ),

    /// flutter router测试页面
    RouteConfig.page(
      path: '/flutter_router_test',
      handler: (params) => const FlutterRouterTestPage(),
    ),

    /// 登录
    RouteConfig.page(
      path: '/login',
      defaultNavigationType: NavigationType.modal,
      handler: (params) => LoginPage(),
    ),

    /// 详情页
    RouteConfig.page(
        path: '/detail',
        handler: (params) => DetailPage(id: params['id'] ?? ''),
        defaultParamsBuilder: () => {
          'uid': UserManager.to.currentUser?.id ?? "",
        },
    ),

    /// 创建学员
    RouteConfig.page(
      path: '/createStudent',
      handler: (params) => CreateStudentPage(),
    ),

    /// WebView页面
    RouteConfig.page(
      path: '/webview',
      handler: (params) {
        final url = params['url'];
        if (url.isEmpty) {
          throw Exception('缺少URL参数');
        }
        return WebViewPage(
          url: url,
          title: params['title'],
          enableJavaScript: params['enableJavaScript'] ?? true,
          supportZoom: params['supportZoom'] ?? true,
          displayNavigationControls: params['displayNavigationControls'] ?? true,
        );
      }
    ),

    /// 系统浏览器打开网页
    RouteConfig.asyncAction(
      path: '/system_web',
      handler: (params) async {
        final url = params['url'];
        if (url.isEmpty) {
          throw Exception('缺少URL参数');
        }
        if (await canLaunchUrlString(url)) {
          await launchUrlString(url, mode: LaunchMode.externalApplication);
          return null;
        } else {
          throw Exception('无法打开链接: $url');
        }
      },
    ),

    /// 获取用户信息（功能调用）
    RouteConfig.syncAction(
      path: '/getUserInfo',
      handler: (params) {
        return '123';
      },
    ),

    /// 弹窗
    RouteConfig.asyncAction(
      path: '/alert',
      handler: (params) async {
        // 显示弹窗
        final title = params['title'] ;
        final message = params['message'];
        if (title == null && message == null) {
          throw Exception('title或message 必须至少有一个参数有值');
        }
        final cancelTitle = params['cancelTitle'];
        final confirmTitle = params['confirmTitle'];

        if (cancelTitle == null && confirmTitle == null) {
          throw Exception('cancelTitle或confirmTitle 必须至少有一个参数有值');
        }
        final result = await Get.dialog(
            CustomDialog(
              title: title,
              subtitle: message,
              cancelText: cancelTitle,
              confirmText: confirmTitle,
              onCancel: () {
                Get.back(result: false);
              },
              onConfirm: () {
                Get.back(result: true);
              },
            ),
            barrierDismissible: false
        );
        return result;
      },
    ),
    // Toast
    RouteConfig.syncAction(
        path: '/toast',
        handler: (params) {
          final title = params['title'];
          final message = params['message'];
          if (title != null || message != null) {
            Get.showSnackbar(
              GetSnackBar(
                // 在这里配置你的 GetSnackBar
                title: title,
                message: message,
                duration: Duration(seconds: 3),
                borderRadius: 8,
                margin: EdgeInsets.only(left: 20,right: 20),
                snackPosition: SnackPosition.TOP,
              ),
            );
            return null;
          } else {
            throw Exception('title或message 必须至少有一个参数有值');
          }
        }
    ),
    /// 原生方法调用
    RouteConfig.asyncAction(
      path: '/native',
      handler: (params) async {
        final path = params['path'];
        if (path == null || path.isEmpty) {
          throw Exception('缺少必要的 "path" 参数');
        }

        try {
          // 假设 NativeMethodChannel.invokeMethod 内部也遵循了 try-catch 并在失败时抛出异常
          final result = await NativeMethodChannel.invokeMethod(
              path,
              params['params']
          );

          // 调用成功，返回原生端的结果
          return result;

        } catch (e) {
          // 如果调用原生方法失败，捕获异常并重新抛出
          // 这样 AppRouter 就能捕获到这个失败信息
          throw Exception('调用原生方法失败: ${e.toString()}');
        }
      },
    ),
  ];
}

/// 登录拦截器
class LoginInterceptor implements RouteInterceptor {
  @override
  Future<InterceptorResult> intercept(String path, Map<String, dynamic>? params) async {
    // 不需要登录的白名单路由
    final List<String> needLoginRoutes = ['/detail'];

    // 检查是否需要登录
    if (needLoginRoutes.contains(path) && !_isLoggedIn()) {
      return InterceptorResult.redirect(
          RouteConfig.page(
            path: '/login',
            defaultNavigationType: NavigationType.modal,
            handler: (params) => LoginPage(),
          )
      );
    }

    return InterceptorResult.completed;
  }

  // 检查用户是否已登录
  bool _isLoggedIn() {
    return UserManager.to.isLoggedIn;
  }
}

/// 日志拦截器
class LogInterceptor implements RouteInterceptor {
  @override
  Future<InterceptorResult> intercept(String path, Map<String, dynamic>? params) async {
    print('''路由跳转日志:
      路径: $path
      参数: $params
      时间: ${DateTime.now()}
    ''');
    return InterceptorResult.completed;
  }
}

/// 学员拦截器
class StudentInterceptor implements RouteInterceptor {
  @override
  Future<InterceptorResult> intercept(String path, Map<String, dynamic>? params) async {
    // 不需要登录的白名单路由
    final List<String> needStudentRoutes = ['/detail'];

    // 检查是否需要登录
    if (needStudentRoutes.contains(path) && !_hasCreatedStudent()) {
      return InterceptorResult.redirect(
          RouteConfig.page(
            path: '/createStudent',
            handler: (params) => CreateStudentPage(),
          )
      );
    }

    return InterceptorResult.completed;
  }

  // 检查用户是否已经创建
  bool _hasCreatedStudent() {
    return UserManager.to.hasCreatedStudent;
  }
}

