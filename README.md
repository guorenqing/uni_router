# AppRouter: 基于Flutter和GetX的路由管理框架

一个功能强大的Flutter路由管理解决方案，基于GetX框架构建，支持多类型路由管理、完整的拦截机制和统一的路由调用方式，帮助开发者开发者快速构建灵活高效的路由系统。

## 特性

- **多类型路由支持**：统一管理页面路由（Page）、同步动作路由（ActionSync）和异步动作路由（ActionAsync）
- **完整拦截机制**：支持路由拦截、重定向和权限验证（如登录状态检查、权限控制）
- **Scheme URL唤起**：通过自定义Scheme（如`myapp://`）从外部唤起应用内路由
- **参数自动处理**：支持默认参数与动态参数合并，自动类型转换
- **统一结果封装**：通过`RouteResult`标准化处理成功/失败状态及返回数据
- **灵活的导航方式**：支持推入、模态展示、替换当前页、替换所有页等多种导航类型

## 安装

在`pubspec.yaml`中添加依赖：

```yaml
dependencies:
  flutter_app_router: ^1.0.0  # 直接指定版本号
```

## 快速开始

### 1. 初始化路由

在`main.dart`中初始化路由配置：

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_router/flutter_getx_router.dart';

// 导入你的路由配置
import 'router_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化路由
  RouterInitializer.init(
    AppRouterConfig(), // 你的路由配置实例
    defaultTransition: Transition.rightToLeft, // 全局默认转场动画
    enableLog: true, // 启用路由日志
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetX Router Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(), // 首页
    );
  }
}
```

### 2. 创建路由配置

实现`RouterConfigurator`接口定义你的路由规则：

```dart
import 'package:flutter_getx_router/flutter_getx_router.dart';
import 'pages/home_page.dart';
import 'pages/detail_page.dart';
import 'pages/webview_page.dart';

class AppRouterConfig implements RouterConfigurator {
  @override
  String get scheme => "myapp"; // 自定义Scheme

  @override
  List<RouteInterceptor> get interceptors => [
    LogInterceptor(), // 日志拦截器
    LoginInterceptor(), // 登录拦截器
  ];

  @override
  List<RouteConfig> get routes => [
    // 首页路由
    RouteConfig.page(
      path: '/home',
      handler: (params) => const HomePage(),
    ),

    // 详情页路由（带参数）
    RouteConfig.page(
      path: '/detail',
      handler: (params) => DetailPage(id: params['id'] ?? ''),
      defaultParamsBuilder: () => {
        'uid': UserManager.to.currentUser?.id ?? "", // 默认参数
      },
    ),

    // WebView页面
    RouteConfig.page(
      path: '/webview',
      handler: (params) => WebViewPage(
        url: params['url'],
        title: params['title'],
      ),
    ),

    // 系统浏览器打开链接（异步动作）
    RouteConfig.asyncAction(
      path: '/system_web',
      handler: (params) async {
        final url = params['url'];
        if (await canLaunchUrlString(url)) {
          await launchUrlString(url);
          return true;
        }
        throw Exception('无法打开链接: $url');
      },
    ),

    // 显示弹窗（异步动作）
    RouteConfig.asyncAction(
      path: '/alert',
      handler: (params) async {
        final result = await Get.dialog(
          AlertDialog(
            title: Text(params['title']),
            content: Text(params['message']),
          ),
        );
        return result;
      },
    ),
  ];
}
```

### 3. 实现拦截器

自定义拦截器处理权限验证等逻辑：

```dart
class LoginInterceptor implements RouteInterceptor {
  @override
  Future<InterceptorResult> intercept(String path, Map<String, dynamic>? params) async {
    // 需要登录的路由列表
    final needLoginRoutes = ['/detail', '/profile'];
    
    // 未登录且需要登录的路由，重定向到登录页
    if (needLoginRoutes.contains(path) && !UserManager.to.isLoggedIn) {
      return InterceptorResult.redirect(
        RouteConfig.page(
          path: '/login',
          defaultNavigationType: NavigationType.modal,
          handler: (params) => LoginPage(),
        ),
      );
    }
    
    return InterceptorResult.completed;
  }
}
```

### 4. 路由跳转

使用`AppRouter`进行路由操作：

```dart
// 跳转到详情页
final result = await AppRouter().navigate('/detail', params: {'id': '123'});
if (result.isSuccess) {
  print('从详情页返回: ${result.data}');
}

// 打开WebView
AppRouter().navigate('/webview', params: {
  'url': 'https://flutter.dev',
  'title': 'Flutter官网',
});

// 调用系统浏览器
AppRouter().navigate('/system_web', params: {'url': 'https://dart.dev'});

// 显示弹窗
final dialogResult = await AppRouter().navigate('/alert', params: {
  'title': '提示',
  'message': '这是一个弹窗',
});
```

### 5. 外部Scheme唤起

通过自定义Scheme从外部（如浏览器、其他应用）唤起应用内路由：

```dart
// 处理外部唤起的URL
AppRouter().handleScheme('myapp://detail?id=123&name=test');

// 在页面中测试
ElevatedButton(
  onPressed: () {
    final testUrl = 'myapp://webview?url=https://flutter.dev&title=Flutter官网';
    AppRouter().handleScheme(testUrl);
  },
  child: const Text('测试Scheme调用'),
)
```

## 路由类型

1. **Page**：页面路由，用于跳转Flutter页面
    - 支持多种导航方式（push/modal/replaceCurrent/replaceAll）
    - 可传递参数并返回结果

2. **ActionSync**：同步动作路由，用于执行同步逻辑
    - 如显示Toast、获取本地数据等

3. **ActionAsync**：异步动作路由，用于执行异步逻辑
    - 如网络请求、文件操作、弹窗交互等

## 导航类型

- `push`：推入导航栈（默认）
- `modal`：模态展示（全屏对话框样式）
- `replaceCurrent`：替换当前页面
- `replaceAll`：替换所有页面

## 许可证

[MIT](LICENSE)