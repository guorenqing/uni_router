import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'route_types.dart';
import 'route_result.dart';
import 'route_interceptor.dart';
import 'router_configurator.dart';
import 'route_call_context.dart';

/// 路由管理类
class AppRouter {
  // 单例模式
  static final AppRouter _instance = AppRouter._internal();

  factory AppRouter() => _instance;

  AppRouter._internal();

  late RouterConfigurator _configurator;
  final Random _random = Random();

  // 存储每个请求的独立上下文
  final Map<String, RouteCallContext> _routeCallContexts = {};

  /// 初始化配置
  void init(RouterConfigurator configurator) {
    _configurator = configurator;
  }

  List<RouteInterceptor> get _interceptors => _configurator.interceptors;

  /// 生成请求ID
  String _generateRequestId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(1000000);
    return '${timestamp}_$random';
  }

  /// 深拷贝参数
  Map<String, dynamic> _deepCopyParams(
    Map<String, dynamic>? defaultParams,
    Map<String, dynamic>? params,
  ) {
    final result = <String, dynamic>{};

    // 拷贝默认参数
    if (defaultParams != null) {
      defaultParams.forEach((key, value) {
        result[key] = _deepCopyValue(value);
      });
    }

    // 拷贝传入参数（覆盖默认参数）
    if (params != null) {
      params.forEach((key, value) {
        result[key] = _deepCopyValue(value);
      });
    }

    return result;
  }

  /// 深拷贝值
  dynamic _deepCopyValue(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    } else if (value is List) {
      return List.from(value);
    } else {
      return value; // 基本类型直接返回
    }
  }

  /// 处理Scheme URL
  Future<RouteResult> handleScheme(String url) async {
    try {
      if (url.startsWith('${_configurator.scheme}://')) {
        final uri = Uri.parse(url);
        final path = '/${uri.host}${uri.path}';
        final Map<String, dynamic> params = {};

        // 提取查询参数
        final queryParams = uri.queryParameters;
        queryParams.forEach((key, value) {
          // 自动转换布尔值
          if (value.toLowerCase() == 'true') {
            params[key] = true;
          } else if (value.toLowerCase() == 'false') {
            params[key] = false;
          } else {
            params[key] = value;
          }
        });

        return await navigate(path, params: params);
      }

      return RouteResult.failure('非法的Scheme URL');
    } catch (e) {
      return RouteResult.failure('Scheme解析失败: ${e.toString()}');
    }
  }

  /// 路由跳转 - 每个请求有独立上下文
  Future<RouteResult> navigate(
    String path, {
    Map<String, dynamic>? params,
    NavigationType? navigationType,
  }) async {
    final requestId = _generateRequestId();
    try {
      print('[$requestId] 开始路由跳转: $path');

      // 查找路由配置
      final routeConfig = _findRoute(path);
      if (routeConfig == null) {
        final error = '[$requestId] 未找到路由: $path';
        print(error);
        return RouteResult.failure(error);
      }

      // 创建请求上下文
      final context = RouteCallContext(
        id: requestId,
        path: path,
        params: _deepCopyParams(null, params), // 立即深拷贝传入参数
        navigationType: navigationType ?? routeConfig.defaultNavigationType,
        createdAt: DateTime.now(),
      );

      _routeCallContexts[requestId] = context;

      // 合并参数（使用上下文中的参数）
      Map<String, dynamic>? defaultParams = routeConfig.defaultParamsBuilder
          ?.call();
      Map<String, dynamic> safeParams = _deepCopyParams(
        defaultParams,
        context.params,
      );

      // 更新上下文参数
      context.params.clear();
      context.params.addAll(safeParams);

      // 执行拦截器（传递请求上下文）
      final interceptorResult = await _processInterceptors(context);
      if (interceptorResult != null) {
        print('[$requestId] 拦截器重定向结果: $interceptorResult');
        return interceptorResult;
      }

      // 拦截器执行后默认参数可能发生变化
      defaultParams = routeConfig.defaultParamsBuilder?.call();
      safeParams = _deepCopyParams(defaultParams, params);

      // 更新上下文参数
      context.params.clear();
      context.params.addAll(safeParams);

      // 根据路由类型处理
      switch (routeConfig.type) {
        case RouteType.page:
          return await _handlePageRoute(context, routeConfig);

        case RouteType.actionSync:
          return _handleSyncAction(context, routeConfig);

        case RouteType.actionAsync:
          return await _handleAsyncAction(context, routeConfig);
      }
    } catch (e) {
      final error = '[$requestId] 路由处理失败: ${e.toString()}';
      print(error);
      return RouteResult.failure(error);
    } finally {
      // _routeCallContexts.remove(requestId);
      // _cleanupExpiredContexts(); // 可选清理
    }
  }

  /// 处理页面路由
  Future<RouteResult> _handlePageRoute(
    RouteCallContext context,
    RouteConfig config,
  ) async {
    try {
      print('[$context.id] 执行页面路由处理器');
      // final page = config.handler(context.params);

      print('[$context.id] 开始页面跳转');
      // Get.to会等待用户操作完成（Get.back(result)）
      // Widget pageBuilder() =  { return config.handler(context.params);}
      // Widget pageBuilder() => config.handler(context.params);
      // 关键：在函数外部捕获当前参数值，避免闭包问题
      final currentParams = Map<String, dynamic>.from(context.params);

      // 使用函数声明，但参数使用外部捕获的值
      Widget pageBuilder() {
        print('[$context.id] 构建页面，参数: $currentParams');
        return config.handler(currentParams); // 使用捕获的参数
      }

      dynamic result;
      switch (context.navigationType) {
        case NavigationType.none:
        case NavigationType.push:
          result = await Get.to(
            pageBuilder,
            arguments: currentParams,
            preventDuplicates: false,
            routeName: context.path,
          );
        case NavigationType.modal:
          result = await Get.to(
            pageBuilder,
            arguments: context.params,
            fullscreenDialog: true,
            transition: Transition.downToUp,
            preventDuplicates: false,
            routeName: context.path,
          );
        case NavigationType.replaceCurrent:
          result = await Get.off(
            pageBuilder,
            arguments: context.params,
            preventDuplicates: false,
            routeName: context.path,
          );
        case NavigationType.replaceAll:
          result = await Get.offAll(
            pageBuilder,
            arguments: context.params,
            routeName: context.path,
          );
      }
      print('[$context.id] 页面返回结果: $result');

      return RouteResult.success(data: result);
    } catch (e) {
      final error = '[$context.id] 页面跳转失败: ${e.toString()}';
      print(error);
      return RouteResult.failure(error);
    }
  }

  /// 处理同步操作
  RouteResult _handleSyncAction(RouteCallContext context, RouteConfig config) {
    try {
      print('[$context.id] 执行同步操作处理器');
      final result = config.handler(context.params);
      print('[$context.id] 同步操作完成: $result');
      return RouteResult.success(data: result);
    } catch (e) {
      final error = '[$context.id] 同步操作失败: ${e.toString()}';
      print(error);
      return RouteResult.failure(error);
    }
  }

  /// 处理异步操作
  Future<RouteResult> _handleAsyncAction(
    RouteCallContext context,
    RouteConfig config,
  ) async {
    try {
      print('[$context.id] 执行异步操作处理器');
      final result = await config.handler(context.params);
      print('[$context.id] 异步操作完成: $result');
      return RouteResult.success(data: result);
    } catch (e) {
      final error = '[$context.id] 异步操作失败: ${e.toString()}';
      print(error);
      return RouteResult.failure(error);
    }
  }

  /// 处理拦截器 - 使用请求上下文
  Future<RouteResult?> _processInterceptors(RouteCallContext context) async {
    for (var interceptor in _interceptors) {
      print('[$context.id] 执行拦截器: ${interceptor.runtimeType}');

      // 为拦截器提供参数的深拷贝，避免拦截器修改原始参数
      final interceptorParams = _deepCopyParams(null, context.params);
      final interceptorResult = await interceptor.intercept(
        context.path,
        interceptorParams,
      );
      // 根据拦截器结果类型处理
      switch (interceptorResult.type) {
        case InterceptorResultType.completed:
          // 继续执行下一个拦截器
          print('[$context.id] 拦截器允许通过，继续下一个拦截器');
          continue;

        case InterceptorResultType.redirect:
          final redirectConfig = interceptorResult.routeConfig!;
          print('[$context.id] 拦截器要求重定向到: ${redirectConfig.path}');

          // 执行重定向（会创建新的请求上下文）
          final redirectResult = await navigate(
            redirectConfig.path,
            params: redirectConfig.defaultParamsBuilder?.call(),
            navigationType: redirectConfig.defaultNavigationType,
          );

          // 检查原路径是否还需要拦截
          final shouldContinue = await _checkInterceptorCompletion(
            context,
            interceptor,
          );
          if (!shouldContinue) {
            final error = '[$context.id] 用户已取消: ${context.path}';
            print(error);
            return RouteResult.failure(error);
          }

          // 如果重定向失败，直接返回失败结果
          if (!redirectResult.isSuccess) {
            print('[$context.id] 重定向失败: $redirectResult');
            return redirectResult;
          }

          print('[$context.id] 重定向成功，继续下一个拦截器');
          continue;

        case InterceptorResultType.replace:
          final replaceConfig = interceptorResult.routeConfig!;
          print('[$context.id] 拦截器要求替换路由为: ${replaceConfig.path}');

          // 直接执行替换路由，不返回原路由
          return await navigate(
            replaceConfig.path,
            params: replaceConfig.defaultParamsBuilder?.call(),
          );

        case InterceptorResultType.reject:
          final errorMessage = interceptorResult.errorMessage!;
          print('[$context.id] 拦截器拒绝: $errorMessage');
          return RouteResult.failure(errorMessage);
      }
    }

    print('[$context.id] 所有拦截器检查通过');
    return null;
  }

  /// 检查拦截器是否完成
  Future<bool> _checkInterceptorCompletion(
    RouteCallContext context,
    RouteInterceptor interceptor,
  ) async {
    final interceptorParams = _deepCopyParams(null, context.params);
    final interceptorResult = await interceptor.intercept(
      context.path,
      interceptorParams,
    );
    final shouldContinue =
        interceptorResult.type == InterceptorResultType.completed;
    print('[$context.id] 拦截器完成检查: $shouldContinue');
    return shouldContinue;
  }

  /// 关闭当前页面
  void pop({dynamic result}) {
    print('路由pop: $result');
    Get.back(result: result);
  }

  /// 关闭所有页面并跳转到指定页面
  Future<RouteResult> replaceAll(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    return navigate(
      path,
      params: params,
      navigationType: NavigationType.replaceAll,
    );
  }

  /// 关闭当前页面并跳转到新页面
  Future<RouteResult> replaceCurrent(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    return navigate(
      path,
      params: params,
      navigationType: NavigationType.replaceCurrent,
    );
  }

  /// 查找路由配置
  RouteConfig? _findRoute(String path) {
    final route = _configurator.routes.firstWhereOrNull(
      (route) => route.path.toLowerCase() == path.toLowerCase().trim(),
    );

    if (route == null) {
      print(
        '路由查找失败: $path, 可用路由: ${_configurator.routes.map((r) => r.path).toList()}',
      );
    } else {
      print('路由查找成功: $path -> ${route.path}');
    }

    return route;
  }

  /// 清理过期的请求上下文
  void _cleanupExpiredContexts() {
    final now = DateTime.now();
    final expiredIds = _routeCallContexts.entries
        .where(
          (entry) =>
              now.difference(entry.value.createdAt) > Duration(minutes: 5),
        )
        .map((entry) => entry.key)
        .toList();

    for (final id in expiredIds) {
      _routeCallContexts.remove(id);
      print('[$id] 清理过期请求上下文');
    }
  }

  /// 获取当前活跃的请求数量（用于调试）
  int get activeRequestCount => _routeCallContexts.length;

  /// 获取当前活跃的请求ID列表（用于调试）
  List<String> get activeRequestIds => _routeCallContexts.keys.toList();

  /// 清理所有资源
  void dispose() {
    _routeCallContexts.clear();
    print('AppRouter disposed');
  }
}
