import 'router_configurator.dart';

/// 拦截器结果枚举
enum InterceptorResultType {
  completed, // 继续执行原路由 (避免使用 continue 关键字)
  redirect, // 重定向到新路由，成功后继续原路由
  replace, // 替换原路由（不执行原路由）
  reject, // 拒绝并终止
}

/// 拦截器结果
class InterceptorResult {
  final InterceptorResultType type;
  final RouteConfig? routeConfig;
  final String? errorMessage;

  const InterceptorResult._(this.type, {this.routeConfig, this.errorMessage});

  /// 继续执行原路由
  static const InterceptorResult completed = InterceptorResult._(
    InterceptorResultType.completed,
  );

  /// 重定向到新路由
  factory InterceptorResult.redirect(RouteConfig routeConfig) {
    return InterceptorResult._(
      InterceptorResultType.redirect,
      routeConfig: routeConfig,
    );
  }

  /// 替换原路由
  factory InterceptorResult.replace(RouteConfig routeConfig) {
    return InterceptorResult._(
      InterceptorResultType.replace,
      routeConfig: routeConfig,
    );
  }

  /// 拒绝并终止
  factory InterceptorResult.reject(String errorMessage) {
    return InterceptorResult._(
      InterceptorResultType.reject,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    switch (type) {
      case InterceptorResultType.completed:
        return 'InterceptorResult.proceed';
      case InterceptorResultType.redirect:
        return 'InterceptorResult.redirect(${routeConfig?.path})';
      case InterceptorResultType.replace:
        return 'InterceptorResult.replace(${routeConfig?.path})';
      case InterceptorResultType.reject:
        return 'InterceptorResult.reject($errorMessage)';
    }
  }
}

/// 路由拦截器接口
abstract class RouteInterceptor {
  /// 拦截路由请求
  ///
  /// 返回结果说明：
  /// - InterceptorResult.completed: 继续执行原路由
  /// - InterceptorResult.redirect: 重定向到新路由，成功后继续原路由
  /// - InterceptorResult.replace: 替换原路由（不执行原路由）
  /// - InterceptorResult.reject: 拒绝并终止
  Future<InterceptorResult> intercept(
    String path,
    Map<String, dynamic>? params,
  );
}
