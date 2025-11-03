import 'package:flutter/material.dart';
import 'route_types.dart';
import 'route_interceptor.dart';
import 'route_types.dart';

/// 路由配置抽象类，由业务方实现
abstract class RouterConfigurator {
  /// 应用Scheme（如"myapp"）
  String get scheme;

  /// 路由配置列表
  List<RouteConfig> get routes;

  /// 拦截器列表
  List<RouteInterceptor> get interceptors;
}

/// 路由配置项基类
class RouteConfig {
  final String path;
  final RouteType type;
  final NavigationType defaultNavigationType;
  final Map<String, dynamic> Function()? defaultParamsBuilder;
  final dynamic Function(Map<String, dynamic> params) handler;

  RouteConfig({
    required this.path,
    required this.type,
    required this.handler,
    required this.defaultNavigationType,
    this.defaultParamsBuilder,
  });

  // 1. Page 类型 - 用于页面跳转
  factory RouteConfig.page({
    required String path,
    required Widget Function(Map<String, dynamic> params) handler,
    NavigationType defaultNavigationType = NavigationType.push,
    Map<String, dynamic> Function()? defaultParamsBuilder,
  }) {
    return RouteConfig(
      path: path,
      type: RouteType.page,
      handler: handler,
      defaultNavigationType: defaultNavigationType,
      defaultParamsBuilder: defaultParamsBuilder,
    );
  }

  // 2. 异步 Action 类型 - 用于需要异步处理的业务逻辑
  factory RouteConfig.asyncAction({
    required String path,
    required Future<dynamic> Function(Map<String, dynamic> params) handler,
    Map<String, dynamic> Function()? defaultParamsBuilder,
  }) {
    return RouteConfig(
      path: path,
      type: RouteType.actionAsync,
      handler: handler,
      defaultNavigationType: NavigationType.none, // Action 通常不需要导航类型
      defaultParamsBuilder: defaultParamsBuilder,
    );
  }

  // 3. 同步 Action 类型 - 用于同步业务逻辑
  factory RouteConfig.syncAction({
    required String path,
    required dynamic Function(Map<String, dynamic> params) handler,
    Map<String, dynamic> Function()? defaultParamsBuilder,
  }) {
    return RouteConfig(
      path: path,
      type: RouteType.actionSync,
      handler: handler,
      defaultNavigationType: NavigationType.none, // Action 通常不需要导航类型
      defaultParamsBuilder: defaultParamsBuilder,
    );
  }
}
